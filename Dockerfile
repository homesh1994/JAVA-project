# syntax=docker/dockerfile:1

# Stage 1 (to create a "build" image, ~360MB)
FROM eclipse-temurin:17-jdk-alpine AS builder

# Verify if Java is available
RUN java -version

# Copy the source code into the container
COPY . /usr/src/myapp/
WORKDIR /usr/src/myapp/

# Install Maven and verify its availability
RUN apk --no-cache add maven \
    && mvn --version

# Build the Java application using Maven
RUN mvn package

# Stage 2 (to create a downsized "container executable", ~180MB)
FROM eclipse-temurin:17-jre-alpine

# Install CA certificates
RUN apk --no-cache add ca-certificates

# Set the working directory
WORKDIR /root/

# Copy the compiled JAR file from the previous stage
COPY --from=builder /usr/src/myapp/target/app.jar .

# Expose the port
EXPOSE 8123

# Define the entry point to run the Java application
ENTRYPOINT ["java", "-jar", "./app.jar"]
