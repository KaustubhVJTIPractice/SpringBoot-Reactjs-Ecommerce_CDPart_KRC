# =========================
# Build Stage
# =========================
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy Maven config first for dependency caching
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy full source
COPY . .

# Build Spring Boot fat JAR
RUN mvn clean package -DskipTests


# =========================
# Runtime Stage (Distroless)
# =========================
FROM gcr.io/distroless/java21-debian12

WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Run as non-root user
USER nonroot

# Spring Boot default port
EXPOSE 8080

# Start application
ENTRYPOINT ["java","-jar","app.jar"]
