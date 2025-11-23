# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Install dependencies: git + JDK + basic tools
RUN apt-get update && apt-get install -y \
    git \
    openjdk-17-jdk \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Workdir for the repo
WORKDIR /app

# Clone your repo
RUN git clone https://github.com/leilab-isep/cogsi2526-1211739-1240470.git .

# Go into CA2 Gradle project
WORKDIR /app/CA2

# Build inside the container, but SKIP TESTS (ChatClientTest needs GUI)
RUN chmod +x gradlew && ./gradlew clean build -x test

# The chat server listens on TCP 59001
EXPOSE 59001

# When the container starts, launch the chat server
CMD ["./gradlew", "runServer", "--args='59001'"]
