
# Use an official OpenJDK 17 JRE (Java Runtime Environment) image
FROM openjdk:17-jre-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the pre-built JAR file from the host machine's build/libs directory
# into the container at the /app directory.
# The JAR name is based on your build.gradle (project name-version.jar)
COPY build/libs/CA2-0.1.0.jar app.jar

# Expose the port the server will listen on
EXPOSE 59001

# Command to run the server application when the container starts
CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "0.0.0.0", "59001"]
