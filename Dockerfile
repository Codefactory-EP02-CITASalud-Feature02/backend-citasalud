FROM maven:3.9.5-eclipse-temurin-21 AS build
WORKDIR /workspace

# Copy Maven files first for dependency caching
COPY pom.xml mvnw mvnw.cmd ./
COPY .mvn .mvn
RUN mvn -B -N

# Copy sources and build
COPY src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Copy packaged jar from build stage
ARG JAR_FILE=target/CITASaludApplication-0.0.1-SNAPSHOT.jar
COPY --from=build /workspace/${JAR_FILE} ./app.jar

EXPOSE 8080

ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
