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

spring.datasource.url=jdbc:h2:file:/vagrant/h2data/demo-db
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
