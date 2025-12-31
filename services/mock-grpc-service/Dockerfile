FROM eclipse-temurin:25.0.1_8-jre-alpine-3.23
WORKDIR /app
COPY build/libs/app.jar app.jar
EXPOSE 50051
ENTRYPOINT [ "java", "-jar", "app.jar" ]