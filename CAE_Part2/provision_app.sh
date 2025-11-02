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
