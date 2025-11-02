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
