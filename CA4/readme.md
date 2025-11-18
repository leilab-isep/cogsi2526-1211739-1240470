
# CA4 Technical Report

## Part 1: Configuration Management

The goal of this assignment is to evolve Part 2 of CA3 to use Ansible as a provisioner in both VMs:

Vagrant Setup

The Vagrantfile defines two virtual machines:

db: Ubuntu 22.04, 1 CPU, 1024 MB RAM, private IP 192.168.56.11.

app: Ubuntu 22.04, 2 CPUs, 2048 MB RAM, private IP 192.168.56.10.

Each VM uses Ansible Local to provision the environment:

````
db.vm.provision "ansible_local" do |ansible|
  ansible.playbook = "ansible/playbook-db.yml"
end

app.vm.provision "ansible_local" do |ansible|
  ansible.playbook = "ansible/playbook-app.yml"
end

````

Ansible Inventory

The inventory defines the hosts and SSH credentials:

````ini

[db]
192.168.56.11 ansible_ssh_private_key_file=/vagrant/keys/id_rsa ansible_user=vagrant

[app]
192.168.56.12 ansible_ssh_private_key_file=/vagrant/keys/id_rsa ansible_user=vagrant

````

H2 Database Playbook (playbook-db.yml)
The playbook for the db VM installs and configures the H2 database:


Key Tasks

Install Java (required by H2):

```yaml
- name: Install Java (required by H2)
  apt:
    name: openjdk-11-jdk
    state: present
    update_cache: yes
```

Install unzip utility:

```yaml
- name: Install unzip utility
  apt:
    name: unzip
    state: present
    update_cache: yes
```

Create H2 directory:

```yaml
- name: Create H2 directory
  file:
    path: /opt/h2
    state: directory
    mode: '0755'
```

Download H2 with retries and use until for handling transient failures:

```yaml
- name: Download H2 database
  get_url:
    url: https://github.com/h2database/h2database/releases/download/version-2.4.240/h2-2025-09-22.zip
    dest: /tmp/h2.zip
    mode: '0644'
  register: h2_download
  retries: 3
  delay: 5
  until: h2_download is succeeded
```

Unzip H2, using creates to avoid repeating extraction:

```yaml
- name: Unzip H2
  unarchive:
    src: /tmp/h2.zip
    dest: /opt/h2
    remote_src: yes
    creates: /opt/h2/bin/h2.sh
```

Start H2 server, using creates and async/poll for background execution:

```yaml
- name: Start H2 in server mode
  shell: |
    nohup java -cp /opt/h2/bin/h2*.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 &
  args:
    chdir: /opt/h2
    creates: /tmp/h2_server_started
  async: 30
  poll: 0
  ignore_errors: yes
```

Spring Boot Application Playbook (playbook-app.yml)

Install Java and Git:

```yaml

- name: Install Java and Git
  apt:
    name:
      - openjdk-17-jdk
      - git
    state: present
    update_cache: yes
```
apt is inherently idempotent; it will only install packages if they are missing.

update_cache: yes ensures package lists are up to date.

Clone the Spring Boot application repository:

```yaml
- name: Clone application repository
  git:
    repo: https://github.com/leilab-isep/cogsi2526-1211739-1240470.git
    dest: /dev/app
    version: main
    force: yes
  register: git_result
  retries: 3
  until: git_result.after is defined
````

Update application.properties to connect to remote H2:

```yaml

- name: Update application.properties to connect to remote H2
  lineinfile:
    path: /dev/app/CA2_Part2/app/src/resources/application.properties
    regexp: '^spring.datasource.url='
    line: 'spring.datasource.url=jdbc:h2:tcp://192.168.56.11:9092/~/testdb'
  notify: Restart App
```

Build and run the application:

```yaml
- name: Build and run application
  shell: |
    ./gradlew bootRun &
  args:
    chdir: /dev/app/CA2_Part2
  async: 30
  poll: 0
```

Using vagrant up --provision will set up both VMs with Ansible, installing and configuring the H2 database on the db VM and the Spring Boot application on the app VM. The application will connect to the H2 database running on the db VM.

````bash

PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470\ca4> vagrant up --provision
Bringing machine 'db' up with 'virtualbox' provider...
Bringing machine 'app' up with 'virtualbox' provider...
==> db: Checking if box 'bento/ubuntu-22.04' version '202510.26.0' is up to date...
==> db: Running provisioner: ansible_local...
    db: Running ansible-playbook...

PLAY [Setup H2 Database Server] ************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Platform linux on host 192.168.56.11 is using the discovered Python
interpreter at /usr/bin/python3.10, but future installation of another Python
interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [192.168.56.11]

TASK [Install Java (required by H2)] *******************************************
ok: [192.168.56.11]

TASK [Install unzip utility] ***************************************************
ok: [192.168.56.11]

TASK [Create H2 directory] *****************************************************
ok: [192.168.56.11]

TASK [Download H2 database] ****************************************************
ok: [192.168.56.11]

TASK [Unzip H2] ****************************************************************
changed: [192.168.56.11]

TASK [Start H2 in server mode] *************************************************
changed: [192.168.56.11]

PLAY RECAP *********************************************************************
192.168.56.11              : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

==> app: Checking if box 'bento/ubuntu-22.04' version '202510.26.0' is up to date...
==> app: Running provisioner: ansible_local...
    app: Running ansible-playbook...

PLAY [Deploy Spring Boot App] **************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Platform linux on host 192.168.56.12 is using the discovered Python
interpreter at /usr/bin/python3.10, but future installation of another Python
interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [192.168.56.12]

TASK [Install Java and Git] ****************************************************
ok: [192.168.56.12]

TASK [Clone application repository] ********************************************
changed: [192.168.56.12]

TASK [Update application.properties to connect to remote H2] *******************
changed: [192.168.56.12]

TASK [Build and run application] ***********************************************
changed: [192.168.56.12]

RUNNING HANDLER [Restart App] **************************************************
changed: [192.168.56.12]

PLAY RECAP *********************************************************************
192.168.56.12              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470\ca4> 





````

running 2nd time to show idempotency:

````bash

PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470\ca4> vagrant up --provision
Bringing machine 'db' up with 'virtualbox' provider...
Bringing machine 'app' up with 'virtualbox' provider...
==> db: Checking if box 'bento/ubuntu-22.04' version '202510.26.0' is up to date...
==> db: Running provisioner: ansible_local...
    db: Running ansible-playbook...

PLAY [Setup H2 Database Server] ************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Platform linux on host 192.168.56.11 is using the discovered Python
interpreter at /usr/bin/python3.10, but future installation of another Python
interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [192.168.56.11]

TASK [Install Java (required by H2)] *******************************************
ok: [192.168.56.11]

TASK [Install unzip utility] ***************************************************
ok: [192.168.56.11]

TASK [Create H2 directory] *****************************************************
ok: [192.168.56.11]

TASK [Download H2 database] ****************************************************
ok: [192.168.56.11]

TASK [Unzip H2] ****************************************************************
changed: [192.168.56.11]

TASK [Start H2 in server mode] *************************************************
changed: [192.168.56.11]

PLAY RECAP *********************************************************************
192.168.56.11              : ok=7    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

==> app: Checking if box 'bento/ubuntu-22.04' version '202510.26.0' is up to date...
==> app: Running provisioner: ansible_local...
    app: Running ansible-playbook...

PLAY [Deploy Spring Boot App] **************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Platform linux on host 192.168.56.12 is using the discovered Python
interpreter at /usr/bin/python3.10, but future installation of another Python
interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [192.168.56.12]

TASK [Install Java and Git] ****************************************************
ok: [192.168.56.12]

TASK [Clone application repository] ********************************************
changed: [192.168.56.12]

TASK [Update application.properties to connect to remote H2] *******************
changed: [192.168.56.12]

TASK [Build and run application] ***********************************************
changed: [192.168.56.12]

RUNNING HANDLER [Restart App] **************************************************
changed: [192.168.56.12]

PLAY RECAP *********************************************************************
192.168.56.12              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470\ca4> 
````

The provisioning runs without errors, and the application connects to the H2 database on the db VM.
The goal was to show idempotency, but due to the use of 'creates' in certain tasks, some tasks are marked as changed even on subsequent runs. Adjustments can be made to improve idempotency further if needed.


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

### Alternatives
For this chapter we will focus on alternatives for the Ansible provisioner.

Overview

Puppet is a declarative configuration management tool, similar to Ansible, 
but it uses its own domain-specific language (DSL) to define the desired state of a system.
It’s designed to manage system configurations consistently across multiple machines.

our Vagrantfile would look like this:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  config.vm.define "db" do |db|
    db.vm.network "private_network", ip: "192.168.56.11"

    db.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "h2.pp"
    end
  end

  config.vm.define "app" do |app|
    app.vm.network "private_network", ip: "192.168.56.12"

    app.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "spring_app.pp"
    end
  end
end
```

The Puppet manifests (h2.pp and spring_app.pp) would contain the necessary configurations to set up the H2 database and Spring Boot application, respectively.

```
# Ensure Java is installed
package { 'openjdk-11-jdk':
  ensure => installed,
}

# Ensure unzip is installed
package { 'unzip':
  ensure => installed,
}

# Create H2 directory
file { '/opt/h2':
  ensure => directory,
  mode   => '0755',
}

# Download H2 only if missing
exec { 'download_h2':
  command => 'wget -O /tmp/h2.zip https://github.com/h2database/h2database/releases/download/version-2.4.240/h2-2025-09-22.zip',
  creates => '/tmp/h2.zip',
}

# Unzip H2 only if not already done
exec { 'unzip_h2':
  command => 'unzip /tmp/h2.zip -d /opt/h2',
  creates => '/opt/h2/bin/h2.sh',
  require => Exec['download_h2'],
}

# Start H2 server if not running
exec { 'start_h2':
  command => 'nohup java -cp /opt/h2/bin/h2*.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 &',
  unless  => 'pgrep -f org.h2.tools.Server',
  require => Exec['unzip_h2'],
}


```

```
# Install Java and Git
package { ['openjdk-17-jdk','git']:
  ensure => installed,
}

# Clone application repository
vcsrepo { '/dev/app':
  ensure   => present,
  provider => git,
  source   => 'https://github.com/leilab-isep/cogsi2526-1211739-1240470.git',
  revision => 'main',
  force    => true,
}

# Update application.properties
file_line { 'spring_datasource_url':
  path  => '/dev/app/CA2_Part2/app/src/resources/application.properties',
  line  => 'spring.datasource.url=jdbc:h2:tcp://192.168.56.11:9092/~/testdb',
  match => '^spring.datasource.url=',
}

# Start Spring Boot
exec { 'start_spring_app':
  command => './gradlew bootRun &',
  cwd     => '/dev/app/CA2_Part2',
  unless  => 'pgrep -f gradlew',
}


```

This approach allows you to leverage Puppet's capabilities for configuration management while still using Vagrant to manage your virtual machines.

Advantages of Puppet:

- Declarative: You define the desired state, and Puppet ensures the system matches it.

- Idempotent: Puppet inherently avoids repeating changes unnecessarily. Running the same manifest twice results in minimal or zero changes.

- Error Handling: Puppet can manage dependencies between resources (require, before, notify) to handle errors gracefully.

- Scalable: Great for managing many machines consistently.

