FROM ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:2.23.0 AS agent

FROM eclipse-temurin:25.0.1_8-jre-alpine-3.23

WORKDIR /usr/src/app/

COPY --from=agent --chown=cnb /javaagent.jar /app/javaagent.jar
ENV JAVA_TOOL_OPTIONS=-javaagent:/app/javaagent.jar
COPY build/libs/*.jar app.jar

EXPOSE 50051
ENTRYPOINT [ "java", "-jar", "app.jar" ]