FROM eclipse-temurin:25.0.1_8-jre-alpine-3.23
WORKDIR /app
COPY build/libs/app.jar app.jar

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-jar", "app.jar"]