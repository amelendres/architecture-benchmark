FROM eclipse-temurin:21-jre-alpine
COPY build/libs/*.jar app.jar
# EXPOSE 50051
ENTRYPOINT ["java","-jar","/app.jar"]