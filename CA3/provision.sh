#!/usr/bin/env bash
set -e

echo "🔄 Updating and installing system packages..."
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk wget unzip zip git curl

echo "📦 Installing Maven..."
sudo apt-get install -y maven

echo "📦 Installing Gradle..."
GRADLE_VERSION=8.10.2
wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp
sudo unzip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip -d /opt/gradle
sudo ln -sf /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle

echo "✅ Versions installed:"
java -version
mvn -v
gradle -v
git --version

echo "📂 Navigating into repo"
cd /vagrant

# Make sure all Gradle wrapper scripts are executable
chmod +x gradlew || true

# Build & run the Spring REST Services project
if [ -d "CA2_Part2" ]; then
  echo "🏗️ Building Spring REST (CA2_Part2)..."
  cd CA2_Part2
  ./gradlew clean build || gradle clean build

  echo "🌐 Launching Spring Boot app..."
  nohup ./gradlew bootRun > spring.log 2>&1 &
  cd ..
else
  echo "⚠️ CA2_Part2 directory not found; skipping Spring build"
fi

# Build chat/demo project if exists
if [ -d "basic_demo" ]; then
  echo "💬 Building chat demo (basic_demo)..."
  cd basic_demo
  gradle clean build || ./gradlew clean build
  cd ..
else
  echo "⚠️ basic_demo directory not found; skipping chat build"
fi

echo "✅ Provisioning done."
echo "You can access Spring REST app on http://localhost:8080"
echo "Use 'vagrant ssh' → cd /vagrant/basic_demo to start chat server"
