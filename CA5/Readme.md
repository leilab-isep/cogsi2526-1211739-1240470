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

docker run -p 59001:59001 --name my-chat-server chat-server
    
```

that gave the following output:

````bash 

PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470> docker build -t chat-server -f CA5/Version2/Dockerfile .
[+] Building 24.4s (8/8) FINISHED                                                                                                                                                                                         docker:desktop-linux 
 => [internal] load build definition from Dockerfile                                                                                                                                                                                      0.1s 
 => => transferring dockerfile: 451B                                                                                                                                                                                                      0.0s 
 => [internal] load metadata for docker.io/library/eclipse-temurin:17-jre                                                                                                                                                                 2.9s 
 => [internal] load .dockerignore                                                                                                                                                                                                         0.1s 
 => => transferring context: 2B                                                                                                                                                                                                           0.0s 
 => [1/3] FROM docker.io/library/eclipse-temurin:17-jre@sha256:75ab7d1b4b18483e9245342cbee253b558952c1def5c1c18956196330a01683e                                                                                                          13.3s 
 => => resolve docker.io/library/eclipse-temurin:17-jre@sha256:75ab7d1b4b18483e9245342cbee253b558952c1def5c1c18956196330a01683e                                                                                                           0.1s 
 => => sha256:469f7f46f06bf8f05ffa00c679b9cfed78488d3273e4ad9a245a063d965a2083 158B / 158B                                                                                                                                                0.4s 
 => => sha256:2581bc3ff3b6d9f257d5b3f64a3d86de4713b0ffefbb3189693db6e3785a9e79 2.28kB / 2.28kB                                                                                                                                            0.6s 
 => => sha256:ec1e0321681ccbedcbfd0d195ec926ba8b1fb3ac6881aedeb6107b5d2dfa3f28 47.06MB / 47.06MB                                                                                                                                          4.0s 
 => => sha256:a12c659f8ac16f8d9fc5114f9b2bbc77d6367df6b5f9070ec314a45711853b3a 16.97MB / 16.97MB                                                                                                                                          4.4s 
 => => sha256:20043066d3d5c78b45520c5707319835ac7d1f3d7f0dded0138ea0897d6a3188 29.72MB / 29.72MB                                                                                                                                          7.3s
 => => extracting sha256:20043066d3d5c78b45520c5707319835ac7d1f3d7f0dded0138ea0897d6a3188                                                                                                                                                 2.5s
 => => extracting sha256:a12c659f8ac16f8d9fc5114f9b2bbc77d6367df6b5f9070ec314a45711853b3a                                                                                                                                                 1.2s
 => => extracting sha256:ec1e0321681ccbedcbfd0d195ec926ba8b1fb3ac6881aedeb6107b5d2dfa3f28                                                                                                                                                 1.4s
 => => extracting sha256:469f7f46f06bf8f05ffa00c679b9cfed78488d3273e4ad9a245a063d965a2083                                                                                                                                                 0.0s
 => => extracting sha256:2581bc3ff3b6d9f257d5b3f64a3d86de4713b0ffefbb3189693db6e3785a9e79                                                                                                                                                 0.0s 
 => [internal] load build context                                                                                                                                                                                                         0.3s 
 => => transferring context: 1.88MB                                                                                                                                                                                                       0.2s 
 => [2/3] WORKDIR /app                                                                                                                                                                                                                    6.6s 
 => [3/3] COPY CA2/build/libs/basic_demo-0.1.0.jar app.jar                                                                                                                                                                                0.2s 
 => exporting to image                                                                                                                                                                                                                    0.8s 
 => => exporting layers                                                                                                                                                                                                                   0.4s 
 => => exporting manifest sha256:67f2257c2e8308583c1ea259e97a2efbf06d12e39806a07c6f82ee42c7dbde03                                                                                                                                         0.0s 
 => => exporting config sha256:714b724925a3a045596cd0209bb231dfa1d4808b2fe2f8a333403846081d9e01                                                                                                                                           0.0s 
 => => exporting attestation manifest sha256:fd671b0f94ce278635b87ed3107e07fe4d1cc32087655042f1b16d4164c737ae                                                                                                                             0.1s 
 => => exporting manifest list sha256:fae77019402d49770b61470eaf719e4e41b9b1d486b98d75d2308740fcf96817                                                                                                                                    0.0s 
 => => naming to docker.io/library/chat-server:latest                                                                                                                                                                                     0.0s 
 => => unpacking to docker.io/library/chat-server:latest                                                                                                                                                                                  0.1s 

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/wy7xp9eobgbpc2l04tsq9djuk

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview
PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470> 
PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470>     docker run -p 59001:59001 --name my-chat-server chat-server
Pass the server port as the sole command line argument
PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470>     
PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470> docker build -t chat-server -f CA5/Version2/Dockerfile .       
[+] Building 12.5s (8/8) FINISHED                                                                                                                                                                                         docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                                                                                                                      0.1s
 => => transferring dockerfile: 440B                                                                                                                                                                                                      0.0s 
 => [internal] load metadata for docker.io/library/eclipse-temurin:17-jre                                                                                                                                                                11.8s 
 => [internal] load .dockerignore                                                                                                                                                                                                         0.0s
 => => transferring context: 2B                                                                                                                                                                                                           0.0s 
 => [1/3] FROM docker.io/library/eclipse-temurin:17-jre@sha256:75ab7d1b4b18483e9245342cbee253b558952c1def5c1c18956196330a01683e                                                                                                           0.1s 
 => => resolve docker.io/library/eclipse-temurin:17-jre@sha256:75ab7d1b4b18483e9245342cbee253b558952c1def5c1c18956196330a01683e                                                                                                           0.1s 
 => [internal] load build context                                                                                                                                                                                                         0.0s 
 => => transferring context: 144B                                                                                                                                                                                                         0.0s 
 => CACHED [2/3] WORKDIR /app                                                                                                                                                                                                             0.0s 
 => CACHED [3/3] COPY CA2/build/libs/basic_demo-0.1.0.jar app.jar                                                                                                                                                                         0.0s 
 => exporting to image                                                                                                                                                                                                                    0.2s 
 => => exporting layers                                                                                                                                                                                                                   0.0s 
 => => exporting manifest sha256:64376db3b12be5a748c97da2d2992948501a25c51f5fccdbc92e4872fb42f4a4                                                                                                                                         0.0s
 => => exporting config sha256:d3f543694c9ea64390286145bd880aa44fefd62f1fd00d0887ac8604fb935357                                                                                                                                           0.0s 
 => => exporting attestation manifest sha256:f146d8f6df01bcfc6ba81aa4bfac75db77c4a01190b161618a7ec4a1e37f5d11                                                                                                                             0.0s
 => => exporting manifest list sha256:59d66efa4bd4906c09fd0808be207b6eb38f0e5aa742485f34f9aac5a8713f72                                                                                                                                    0.0s 
 => => naming to docker.io/library/chat-server:latest                                                                                                                                                                                     0.0s 
 => => unpacking to docker.io/library/chat-server:latest                                                                                                                                                                                  0.0s 

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/j2pygu1fc1ew9v0vghlemwd20

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview


````

### Monitorization

In order To Monitor the container resource usage in real time, observing CPU, memory, network, and disk I/O activity while the container runs we use the command:

```bash

docker stats my-chat-server

```

that gave the following output:

````bash 

S C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470\CA2>     docker stats my-chat-server
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.30%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.19%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.19%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.19%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.17%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.17%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.17%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.17%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.20%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.20%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O       BLOCK I/O   PIDS
57f320406648   my-chat-server   0.17%     64.2MiB / 6.698GiB   0.94%     1.21kB / 0B   0B / 0B     20
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT   MEM %     NET I/O   BLOCK I/O   PIDS
57f320406648   my-chat-server   --        -- / --             --        --        --          --
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT   MEM %     NET I/O   BLOCK I/O   PIDS
57f320406648   my-chat-server   --        -- / --             --        --        --          --
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT   MEM %     NET I/O   BLOCK I/O   PIDS
57f320406648   my-chat-server   --        -- / --             --        --        --          --
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT   MEM %     NET I/O   BLOCK I/O   PIDS
57f320406648   my-chat-server   --        -- / --             --        --        --          --

got 3 SIGTERM/SIGINTs, forcefully exiting
PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470\CA2> 



````

* CONTAINER ID / NAME: The ID and name of your container (my-chat-server).
* CPU %: The percentage of the host machine's CPU that the container is currently using. 
* MEM USAGE / LIMIT: Shows how much memory the container is actively using versus the total amount of memory it is allowed to use from your host machine.
* MEM %: The memory usage as a percentage of the total limit.
* NET I/O: Network activity. It shows the total amount of data the container has received (left) and sent (right) over the network. Changes can be seen as clients connect and chat.
* BLOCK I/O: Disk I/O activity. This shows the total amount of data the container has read from and written to the host's hard drive. 
* PIDS: The number of processes or threads running inside the container.


### Tagging and Upload to Docker Hub

In order to publish the images to docker hub we have to be authenticated on the Docker Hub. 

````bash

docker login

````
And then insert our login credentials.

Docker Hub requires images to be tagged in a specific format: <your-dockerhub-username>/<repository-name>:<tag>.

so we run the followin command:

````bash

docker tag chat-server <username>/chat-server:1.0

````

* docker tag: The command to create a new tag for an image.
* chat-server: The source image to be tagged.
* •<username>/chat-server:1.0: The new, fully-qualified tag.


With the image correctly tagged, we can push it to Docker Hub repository.

````bash

docker push <username>/chat-server:1.0

````

Docker will upload the image layers to Docker Hub. Once it's finished, we can go to your Docker Hub profile in a web browser and see the new chat-server repository with the 1.0 tag.


## Part2

The goal of this part is to containerize the "Building REST Services with Spring" application and its H2 database using Docker and Docker Compose.
This creates a portable, isolated, and reproducible environment.

### Project Structure

We created a multi-service application defined by the following key files:
* db/Dockerfile: Defines the image for our H2 database server.
* app/Dockerfile: Defines the image for our Spring Boot application.
* docker-compose.yml: Orchestrates the building and running of both services.

###  The Database Service (db)

To have a dedicated database container, we created a custom H2 image.

db/Dockerfile:

```dockerfile

# Use a Java runtime as a base image
FROM eclipse-temurin:17-jre-jammy

# H2 Database version to use
ARG H2_VERSION=2.2.224

# Set working directory
WORKDIR /opt

# Download and extract the H2 database JAR
ADD https://repo1.maven.org/maven2/com/h2database/h2/${H2_VERSION}/h2-${H2_VERSION}.jar h2.jar

# Expose the default H2 TCP port (9092) and web console port (8082)
EXPOSE 9092
EXPOSE 8082

# The directory where database files will be stored. This will be mounted as a volume.
VOLUME ["/opt/h2-data"]

CMD ["java", "-cp", "h2.jar", "org.h2.tools.Server", \
     "-tcp", "-tcpAllowOthers", "-ifNotExists", \
     "-web", "-webAllowOthers", \
     "-baseDir", "/opt/h2-data"]


```

This Dockerfile creates a self-contained H2 database server, ready to accept connections.

### The Web Application Service (web)
For the Spring Boot application, we used an optimized, multi-stage Dockerfile. 
This allows us to build the application inside a Docker container without needing Java or Gradle installed on the host machine.

app/Dockerfile:

```dockerfile

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


```

We also updated application.properties to read database connection details from environment variables, making the application configurable at runtime.

### Orchestration with Docker Compose

The docker-compose.yml file is the centerpiece that defines and connects our services.

docker-compose.yml:

```yaml

services:
  web:
    build:
      context: .
      dockerfile: app/Dockerfile
    ports:
      - "8080:8080"
    depends_on:
      db:
        condition: service_healthy
    environment:
      - SPRING_DATASOURCE_URL=jdbc:h2:tcp://db:9092/./mydb
      - SPRING_DATASOURCE_USERNAME=sa
      - SPRING_DATASOURCE_PASSWORD=password
      - SPRING_JPA_HIBERNATE_DDL_AUTO=update
  db:
    build:
      context: .
      dockerfile: db/Dockerfile
    ports:
      - "9092:9092"
      - "8082:8082"
    volumes:
      - db-data:/opt/h2-data
    healthcheck:
      test: ["CMD", "java", "-cp", "h2.jar", "org.h2.tools.Shell", "-url", "jdbc:h2:tcp://localhost:9092/./mydb", "-user", "sa", "-password", "password", "-sql", "SELECT 1"]
      interval: 10s
      timeout: 5s
      retries: 5
    command: java -cp h2.jar org.h2.tools.Server -ifNotExists -tcp -tcpAllowOthers -web -webAllowOthers -baseDir /opt/h2-data

volumes:
  db-data:

```

This configuration achieves several key goals:
* Network Connectivity: The web service can reach the db service using the hostname db.
* Health Check: The web service uses depends_on with condition: service_healthy to wait until the database is fully running before it starts, preventing connection errors.
* Data Persistence: A named volume db-data is used to store the database files outside the container's lifecycle, ensuring data is not lost when the container is removed.
* Environment Variables: The database URL, username, and password are all passed to the web service via the environment block, making the configuration clean and portable.

### Building and Running

With all files in place, the entire application stack can be built and started with a single command from the CA5/Part2 directory:

```bash

docker-compose up -build


```

Once running, the services are accessible:
* REST API: http://localhost:8080
* H2 Database Console: http://localhost:8082

We use the same steps used on part1 to publish the image to the docker hub.
