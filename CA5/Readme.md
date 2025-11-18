### Version 2:
Build the Server JAR on Host Machine
First, we need to build the application using Gradle. Compiling the code and package it into a runnable JAR file.

Inside CA2 folder run the gradle tasks:

```bash
    
    .\gradlew build

    
```

This will create the JAR file in the build/libs directory.

Then we create a new Dockerfile to define the steps to build the Docker image.

```dockerfile


# Use an official OpenJDK 17 JRE (Java Runtime Environment) image
FROM eclipse-temurin:17-jre

# Set the working directory inside the container
WORKDIR /app

COPY CA2/build/libs/basic_demo-0.1.0.jar app.jar

# Expose the port the server will listen on
EXPOSE 59001

# Command to run the server application when the container starts
CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"]


````

* FROM *eclipse-temurin:17-jre  : This starts the image from a lightweight, official base image that already has Java 17 installed. We use the JRE (Java Runtime Environment) because we only need to run the application, not compile it.

* WORKDIR /app : This sets the default directory inside the container to /app. All subsequent commands (COPY, CMD) will be run from this location.

* COPY build/libs/basic_demo-0.1.0.jar app.jar  : This is the key step. It copies the JAR built on the host machine from build/libs/basic_demo-0.1.0.jar into the container's /app directory and renames it to app.jar for simplicity.

* EXPOSE 59001: This informs Docker that the container will listen on port 59001 at runtime. 

* CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"] : This is the command that will execute when the container starts.


Next we run this command to build the image
```bash

    docker build -t chat-server -f CA5/Version2/Dockerfile .
    
```

* -t chat-server: Tags the image as chat-server.
* -f CA5/Version2/Dockerfile: Specifies the path to the Dockerfile.
* .: Sets the build context to the current directory (the project root), which allows the COPY CA2/build/... command to work correctly.

we then run the nex command to run the container:

```bash

    docker build -t chat-server -f CA5/Version2/Dockerfile .
    
```

