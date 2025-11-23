# Stage 1: Build the application using Gradle
FROM gradle:jdk17 AS build
WORKDIR /home/gradle/src
COPY . .
RUN gradle build --no-daemon

# Stage 2: Create the final, lightweight image
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
# Correct path for a multi-project build's subproject JAR
COPY --from=build /home/gradle/src/app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
