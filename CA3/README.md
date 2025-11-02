# Part 1

### Setting Up the Vagrant Environment for Spring REST & Gradle Demo Projects
## Overview

We will describe how to create and provision a Vagrant-managed virtual machine (VM) to automate the setup and execution of the Java project:


# 1. Prerequisites

Before we start, we must ensure that we have the following tools installed on our host machine:

Vagrant
VirtualBox (or another Vagrant provider)
Git

To verify installation:

```

vagrant --version
virtualbox --help
git --version

```

# 2. Project Structure

Inside our working directory, we will create the files for CA3 implementation the structure should look like this:

```

CA3/
│
├── Vagrantfile
└── provision.sh

```

3. Writing the Vagrantfile

The `Vagrantfile` is the configuration file for Vagrant. 
It defines the VM's settings and how it should be provisioned. 
Below is a sample `Vagrantfile` that sets up a Ubuntu VM and provisions it using a shell script.

````plantuml

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-22.04"
  config.vm.hostname = "cogsi-dev"

  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.synced_folder "../", "/vagrant"
  config.vm.synced_folder "./h2data", "/vagrant/h2data"

   config.vm.provider "virtualbox" do |vb|
     vb.name = "cogsi-vm"
     vb.memory = "4096"
   end


  # SHELL
  config.vm.provision "shell" do |s|
      s.path = "provision.sh"
      s.env = {
        "CLONE_REPO" => "true",
        "BUILD_PROJECTS" => "true",
        "START_SERVICES" => "false"
      }
  end
end


````

Port 8080 is forwarded so we can open the Spring REST app in the browser from our host machine.
Environment variables let us control what the provisioning script does (clone, build, start services, etc.).

# 4. Writing the Provisioning Script
The `provision.sh` script will be responsible for installing necessary software, cloning the GitHub repositories, building the projects using Gradle, and starting the Spring REST services.

````bash
#!/usr/bin/env bash
set -e

echo "🔧 Starting provisioning with env vars:"
echo "  CLONE_REPO=${CLONE_REPO}"
echo "  BUILD_PROJECTS=${BUILD_PROJECTS}"
echo "  START_SERVICES=${START_SERVICES}"

echo "📦 Installing required dependencies..."
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk maven wget unzip zip git curl

# Install Gradle manually
GRADLE_VERSION=8.10.2
if ! command -v gradle >/dev/null 2>&1; then
  wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp
  sudo unzip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /opt/gradle
  sudo ln -sf /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle
fi

echo "✅ Installed versions:"
java -version
mvn -v
gradle -v
git --version

# Ensure H2 persistent storage directory exists
echo "💾 Creating persistent H2 data directory..."
mkdir -p /vagrant/h2data
chmod 777 /vagrant/h2data

# Clone repository if enabled
if [ "${CLONE_REPO}" = "true" ]; then
  if [ ! -d "/vagrant/cogsi2526-1211739-1240470" ]; then
    echo "📥 Cloning repository..."
    git clone https://github.com/leilab-isep/cogsi2526-1211739-1240470.git /vagrant/cogsi2526-1211739-1240470
  else
    echo "⚠️ Repository already exists, skipping clone."
  fi
else
  echo "⏩ Skipping repository clone (CLONE_REPO=false)"
fi

# Build projects if enabled
if [ "${BUILD_PROJECTS}" = "true" ]; then
  cd /vagrant/cogsi2526-1211739-1240470 || exit 1

  if [ -d "CA2_Part2" ]; then
    echo "🏗️ Building Spring REST project..."
    cd CA2_Part2
    ./gradlew clean build || gradle clean build
    cd ..
  fi

  if [ -d "basic_demo" ]; then
    echo "💬 Building Gradle chat demo..."
    cd basic_demo
    gradle clean build || ./gradlew clean build
    cd ..
  fi
else
  echo "⏩ Skipping builds (BUILD_PROJECTS=false)"
fi

# Start Spring Boot app if enabled
if [ "${START_SERVICES}" = "true" ]; then
  echo "🚀 Starting Spring Boot service..."
  cd /vagrant/cogsi2526-1211739-1240470/CA2_Part2
  nohup ./gradlew bootRun > /vagrant/spring.log 2>&1 &
else
  echo "⏩ Skipping service start-up (START_SERVICES=false)"
fi

echo "✅ Provisioning completed successfully!"

````

This script performs the following tasks:
Installs OpenJDK 17, Maven, Git, and Gradle.
Creates a directory for persistent H2 database storage.
Clones the specified GitHub repository if it doesn't already exist.
Builds the Spring REST and Gradle chat demo projects.
Starts the Spring Boot application if specified.

# 5. Ensuring Persistent H2 Database Storage
To ensure that the H2 database used by the Spring Boot application persists data across VM restarts, we will configure it to store its data files in the synced folder we created earlier (`/vagrant/h2data`).
Inside the Spring Boot project (application.properties), we need to update the H2 configuration to store data in the synced folder:

````properties

# app/src/main/resources/application.properties

spring.datasource.url=jdbc:h2:file:/vagrant/h2data/testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update

spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

server.port=8080


````

# 6. Bringing Up the Vagrant VM
With everything set up, we can now bring up the Vagrant VM.
From the `CA3` directory, run:

```` bash

vagrant up

````

Access the Spring App:

After the Spring Boot app starts, open your browser and visit:

````

http://localhost:8080

````

# 7 . Controlling Provisioning Steps

We can control which steps the provisioning script executes by modifying the environment variables in the `Vagrantfile` or by passing them directly when running `vagrant up`.:

````bash

# Skip cloning (use existing repo)
vagrant provision --env CLONE_REPO=false

# Skip building, just start services
vagrant provision --env BUILD_PROJECTS=false START_SERVICES=true

````

# 8. Stopping and Destroying the VM

Pause VM (keep state):

````bash

vagrant suspend

````

Shut down VM:

````bash

vagrant halt

````

Remove VM completely:

````bash

vagrant destroy

````

Your project files and H2 database persist in the synced /vagrant folder.



# Part 2

The goal of Part 2 of this assignment is to use Vagrant to setup
a virtual environment with two VMs to execute the Gradle
version of the Building REST services with Spring application.

## Setting Up the Vagrant Environment for Multi-VM Spring REST & Gradle Demo Projects

we set up a multi-VM environment using Vagrant to run:

A Spring Boot REST Application on one VM (app)

An H2 Database Server on another VM (db)

````Vagrantfile
Vagrant.configure("2") do |config|
  # Base box for both
  config.vm.box = "ubuntu/jammy64"

  # Shared key configuration
  private_key_path = "keys/id_rsa"
  public_key_path  = "keys/id_rsa.pub"

  # Define the database VM
  config.vm.define "db" do |db|
    db.vm.hostname = "db-vm"
    db.vm.network "private_network", ip: "192.168.56.10"
    db.vm.provider "virtualbox" do |vb|
      vb.name = "db-vm"
      vb.memory = 1024
      vb.cpus = 1
    end

    # Provision db VM
    db.vm.provision "shell", path: "provision_db.sh"

    # Inject SSH key
    db.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      cat /vagrant/#{public_key_path} >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
  end

  # Define the app VM
  config.vm.define "app" do |app|
    app.vm.hostname = "app-vm"
    app.vm.network "private_network", ip: "192.168.56.11"
    app.vm.provider "virtualbox" do |vb|
      vb.name = "app-vm"
      vb.memory = 2048
      vb.cpus = 2
    end

    # Provision app VM
    app.vm.provision "shell", path: "provision_app.sh"

    # Inject SSH key
    app.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      cat /vagrant/#{public_key_path} >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
  end
end


````

This `Vagrantfile` sets up two VMs: `db` for the database and `app` for the Spring Boot application.
Each VM has its own provisioning script (`provision_db.sh` and `provision_app.sh`) to install necessary software and configure the environment.
Make sure to create the `keys` directory and generate SSH keys before running `vagrant up`:

# 2. Generating Custom SSH Keys

To improve security, replace the default insecure Vagrant key with a custom key pair.

Running the following commands in the `keys` directory will generate a new SSH key pair:

````bash

mkdir -p keys
ssh-keygen -t rsa -b 2048 -f keys/id_rsa -N ""

````

This creates `id_rsa` (private key) and `id_rsa.pub` (public key) in the `keys` directory.

that we set up in the provisioning scripts.

````bash

    db.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      cat /vagrant/#{public_key_path} >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL

````

In db_provision.sh, we start the H2 database with:

````bash

nohup java -cp h2-1.4.200.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -baseDir /vagrant/h2data > /vagrant/h2_server.log 2>&1 &

````
This launches H2 in server mode on port 9092, accepting remote connections.
The app connects using the following configuration:

````properties

spring.datasource.url=jdbc:h2:tcp://192.168.56.10:9092/~/testdb

````

To ensure that the app VM waits for the DB service to be ready before starting the Spring Boot application.
In the app_provision.sh, we added a waiting loop:

````bash

echo "⏳ Waiting for database to be ready..."
until nc -z 192.168.56.10 9092; do
  echo "Waiting for H2 DB..."
  sleep 5
done

````

The app only launches once the database port (9092) is reachable — preventing connection errors at startup.

In db_provision.sh, we configured ufw to allow only the app VM:

````bash

sudo ufw allow from 192.168.56.11 to any port 9092 proto tcp
sudo ufw enable

````
This ensures the H2 database is not accessible from the host or any other machine — only from the app VM.
WE Configured a static IP address for the virtual machine to ensure stable and reliable access to the deployed application.

Updated the database connection string to point to the static IP, ensuring consistent and secure communication between the application and the database.

# 3. Provisioning Scripts
We need to create two provisioning scripts: `provision_db.sh` for the database VM and `provision_app.sh` for the application VM.

### provision_db.sh
````bash

#!/usr/bin/env bash
set -e

echo "🔄 Updating packages..."
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk ufw wget unzip

# Create persistent folder for H2 data
sudo mkdir -p /vagrant/h2data
sudo chmod 777 /vagrant/h2data

echo "Downloading H2 Database..."
wget -q https://repo1.maven.org/maven2/com/h2database/h2/2.1.214/h2-2.1.214.jar -O /opt/h2.jar

# Start H2 in server mode
echo "🚀 Starting H2 in server mode..."
nohup java -cp /opt/h2.jar org.h2.tools.Server \
  -tcp -tcpAllowOthers \
  -tcpPort 9092 \
  -baseDir /vagrant/h2data > /var/log/h2.log 2>&1 &

# Configure firewall
echo "🔒 Configuring firewall..."
sudo ufw allow from 192.168.56.11 to any port 9092
sudo ufw --force enable
sudo ufw status

echo "✅ H2 running on tcp://192.168.56.10:9092"


````

### provision_app.sh

````bash

#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk wget unzip zip git curl gradle

echo "📂 Navigating to project folder..."
cd /vagrant/CA2_Part2

# Wait for DB VM to start
echo "⏳ Waiting for database to be ready..."
until nc -z 192.168.56.10 9092; do
  echo "Waiting for H2 DB..."
  sleep 5
done

# Build and start Spring Boot app
echo "🏗️ Building Spring Boot app..."
gradle clean build -x test

echo "🚀 Starting Spring Boot app..."
nohup gradle bootRun > /vagrant/spring.log 2>&1 &

echo "✅ App running on http://localhost:8080"


````

We set custom resource limits in the Vagrantfile (example values): To ensure smooth operation of both VMs, we allocate sufficient memory and CPU resources:

````ruby

    db.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end

    app.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

````

Firewall Rules for Security

In db_provision.sh, we configured ufw to allow only the app VM:

````bash

echo "🔒 Configuring firewall..."
sudo ufw allow from 192.168.56.11 to any port 9092
sudo ufw --force enable
sudo ufw status

````

This ensures the H2 database is not accessible from the host or any other machine — only from the app VM.   

# Alternative

ChatGPT said:

An alternative to Vagrant is Docker, a containerization platform that allows developers to package applications and their dependencies into lightweight, portable containers. Unlike Vagrant, which creates full virtual machines, Docker uses the host system’s kernel to run isolated environments, resulting in faster startup times and lower resource consumption. Docker provides greater scalability and is ideal for modern DevOps workflows, continuous integration, and microservice architectures. Additionally, it integrates well with orchestration tools like Kubernetes, making it a more efficient choice for deploying and managing applications across multiple environments.

