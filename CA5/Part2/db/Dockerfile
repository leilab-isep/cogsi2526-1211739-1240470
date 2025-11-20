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

# Command to start the H2 server
# -tcpAllowOthers: Allows connections from other containers
# -ifNotExists: Creates the database if it doesn't exist on startup
# -baseDir: Specifies the location for database files
CMD ["java", "-cp", "h2.jar", "org.h2.tools.Server", \
     "-tcp", "-tcpAllowOthers", "-ifNotExists", \
     "-web", "-webAllowOthers", \
     "-baseDir", "/opt/h2-data"]
