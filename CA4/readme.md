
# CA4 Technical Report

## Part 1: Configuration Management

### Use Ansible to configure PAM to enforce a complex password policy

In this activity, we used **Ansible** to automate the configuration of **Pluggable Authentication Modules (PAM)** on the virtual machines defined in our **Vagrant** environment.
The goal was to enforce a **complex password policy** with the following requirements:

* Minimum password length of **12 characters**
* At least **3 of 4** character classes: uppercase, lowercase, digits, symbols
* Reject passwords that contain the **username or dictionary words**
* Prevent reuse of the **last 5 passwords**
* Lock the account for **10 minutes after 5 failed login attempts**

This ensures that all user accounts within the system follow secure authentication practices without requiring manual configuration on each machine.

---

### 1. Infrastructure Setup (Vagrant and Inventory)

Two virtual machines were defined in the `Vagrantfile`, representing the **application** and **database** servers.
The `inventory.ini` file (used as `hosts.ini`) defines these hosts for Ansible:

```ini
[app]
192.168.56.10 ansible_user=vagrant ansible_ssh_private_key_file=../keys/id_rsa

[db]
192.168.56.11 ansible_user=vagrant ansible_ssh_private_key_file=../keys/id_rsa
```

To confirm that Ansible correctly recognized the hosts, we executed:

```bash
ansible-inventory -i ansible/inventory.ini --list
```

The output listed both nodes under their respective groups:

```json
{
  "app": { "hosts": ["192.168.56.10"] },
  "db":  { "hosts": ["192.168.56.11"] },
  "all": { "children": ["app", "db", "ungrouped"] }
}
```

This confirms that the environment was correctly initialized for configuration management.

---

### 2. Creating the PAM Hardening Playbook

We created a new Ansible task file named **`pam-hardening.yml`** to apply the password policy on all hosts.
The file was stored under the `ansible/` directory and imported into both `playbook-app.yml` and `playbook-db.yml`.

```yaml
---
- name: Ensure libpam-pwquality is installed
  ansible.builtin.package:
    name: libpam-pwquality
    state: present

- name: Configure pam_pwquality for password complexity
  ansible.builtin.lineinfile:
    path: /etc/pam.d/common-password
    regexp: '^password\s+requisite\s+pam_pwquality\.so'
    line: >
      password requisite pam_pwquality.so retry=3
      minlen=12 minclass=3 reject_username enforce_for_root
    state: present
    backup: yes

- name: Enforce password history (remember last 5)
  ansible.builtin.lineinfile:
    path: /etc/pam.d/common-password
    regexp: '^password\s+\[success=1\s+default=ignore\]\s+pam_unix\.so'
    line: >
      password [success=1 default=ignore] pam_unix.so obscure
      use_authtok sha512 shadow remember=5
    state: present
    backup: yes

- name: Add pam_tally2 rule to lock account after 5 failed logins
  ansible.builtin.blockinfile:
    path: /etc/pam.d/common-auth
    insertafter: BOF
    block: |
      auth required pam_tally2.so deny=5 onerr=fail unlock_time=600 audit
    marker: "# {mark} ANSIBLE PAM TALLY2 LOCKOUT"

- name: Ensure pam_tally2 is used in account management
  ansible.builtin.blockinfile:
    path: /etc/pam.d/common-account
    insertafter: BOF
    block: |
      account required pam_tally2.so
    marker: "# {mark} ANSIBLE PAM TALLY2 ACCOUNT"
```

Each line enforces a specific security rule, ensuring consistency across all systems.

---

### 3. Running the Playbook

After defining the configuration, the virtual machines were provisioned using Vagrant, which automatically invoked Ansible:

```bash
vagrant up
```

Alternatively, to reapply the configuration without recreating the VMs:

```bash
vagrant provision
```

During execution, Ansible installed the **libpam-pwquality** package and modified the following files:

* `/etc/pam.d/common-password`
* `/etc/pam.d/common-auth`
* `/etc/pam.d/common-account`

The playbook output confirmed that the tasks were executed successfully, with no failed steps.

---

### 4. Verifying the Configuration

After provisioning, we verified that the configuration was applied correctly.

1. **Check modified PAM files:**

```bash
grep pam_pwquality /etc/pam.d/common-password
grep remember /etc/pam.d/common-password
grep pam_tally2 /etc/pam.d/common-auth
grep pam_tally2 /etc/pam.d/common-account
```

Output example:

```
password requisite pam_pwquality.so retry=3 minlen=12 minclass=3 reject_username enforce_for_root
password [success=1 default=ignore] pam_unix.so obscure use_authtok sha512 shadow remember=5
auth required pam_tally2.so deny=5 onerr=fail unlock_time=600 audit
account required pam_tally2.so
```

2. **Test password complexity rules:**

We created a test user:

```bash
sudo useradd testuser
sudo passwd testuser
```

The following behaviors were observed:

| Test              | Password       | Expected Result               | Outcome |
| ----------------- | -------------- | ----------------------------- | ------- |
| Too short         | `abc123`       | Rejected (too short)          | ✅       |
| Lacks complexity  | `aaaaaaaaaaaa` | Rejected (not enough classes) | ✅       |
| Contains username | `testuser123!` | Rejected (contains username)  | ✅       |
| Strong password   | `Aa1!Aa1!Aa1!` | Accepted                      | ✅       |

3. **Test password reuse restriction:**

Changing back to a previous password resulted in an error indicating it was already used, confirming `remember=5` worked.

4. **Test account lockout:**

After 5 failed login attempts, the user was automatically locked for 10 minutes.
This was verified using:

```bash
sudo pam_tally2 --user testuser
```

which showed:

```
testuser   5   0
```
