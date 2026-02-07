FROM eclipse-temurin:21-jre-alpine
COPY --from=ghcr.io/grpc-ecosystem/grpc-health-probe:v0.4.38 /ko-app/grpc-health-probe /bin/grpc_health_probe

COPY build/libs/*.jar app.jar

ENTRYPOINT ["java","-jar","/app.jar"]