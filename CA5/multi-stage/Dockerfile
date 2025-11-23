# syntax=docker/dockerfile:1

########## Stage 1 – Builder ##########
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
    git \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Clone the repository
RUN git clone https://github.com/leilab-isep/cogsi2526-1211739-1240470.git .

WORKDIR /src/CA2

# Build JAR (skip GUI tests)
RUN chmod +x gradlew && ./gradlew clean build -x test


########## Stage 2 – Runtime ##########
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only the final JAR
COPY --from=builder /src/CA2/build/libs/*.jar app.jar

EXPOSE 59001

CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"]
