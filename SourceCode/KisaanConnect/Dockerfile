# Stage 1: Build the Maven WAR with JDK 21
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy pom.xml and pre-fetch dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy source tree and compile WAR
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Tomcat 9 Runtime on Java 21
FROM tomcat:9.0-jre21-temurin

WORKDIR /usr/local/tomcat

# Remove default boilerplate applications
RUN rm -rf webapps/ROOT webapps/examples webapps/docs webapps/manager webapps/host-manager

# Deploy application as ROOT.war
COPY --from=builder /app/target/KisaanConnect-1.0-SNAPSHOT.war webapps/ROOT.war

# Dynamic port binding entrypoint for Railway
RUN echo '#!/bin/sh' > /usr/local/tomcat/bin/railway-entrypoint.sh && \
    echo 'PORT="${PORT:-8080}"' >> /usr/local/tomcat/bin/railway-entrypoint.sh && \
    echo 'sed -i "s/port=\"8080\"/port=\"$PORT\"/g" /usr/local/tomcat/conf/server.xml' >> /usr/local/tomcat/bin/railway-entrypoint.sh && \
    echo 'echo "Starting Tomcat 9 on dynamic port: $PORT"' >> /usr/local/tomcat/bin/railway-entrypoint.sh && \
    echo 'exec catalina.sh run' >> /usr/local/tomcat/bin/railway-entrypoint.sh && \
    chmod +x /usr/local/tomcat/bin/railway-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/tomcat/bin/railway-entrypoint.sh"]
