
# Architecture Benchmark

Benchmark of different microservices patterns
* HTTP
* HTTP Reactive
* gRPC
* GraphQL

Here an example for gRPC
```md
Frontend (HTTP/JSON)
   |
   v
API Gateway (HTTP → gRPC)
   |
   v
gRPC BFF (Java)
   |
   |--> User Service (gRPC)
   |--> Order Service (gRPC)
   |--> Notification Service (gRPC)
```

# BFF Benchmark: GraphQL vs WebFlux vs gRPC

Run apples-to-apples benchmarks for BFF orchestration patterns.
This repository benchmarks three BFF approaches for orchestration workloads:

- GraphQL (Spring GraphQL)
- HTTP JSON (Spring WebFlux)
- gRPC (Spring Boot gRPC)

## Scenario
A dashboard endpoint that fans out to:
- User service
- Order service
- Notification service

Each downstream service adds a fixed 5ms latency.

## Requirements
- Docker
- Docker Compose
- [jq](https://github.com/jqlang/jq?tab=readme-ov-file#installation)
- [fortio](https://github.com/fortio/fortio?tab=readme-ov-file#installation)
- python
- [grpcurl](https://grpcurl.com/)
- [httpie](https://httpie.io/)

## How to Run - local
Build:
```shell
./gradlew build
```

Start:
```shell
./gradlew services:bff-grpc:bootRun services:mock-grpc-service:bootRun
```

```shell
grpcurl -d '{"id":"1"}' -plaintext localhost:50051 MockService.Get
```

```shell
grpcurl -d '{"user_id":"1"}' -plaintext localhost:9090 DashboardService.GetDashboard
```

## How to Run - Docker

### gRPC
Start
```shell
docker compose -f compose.grpc.yaml up --build
```

Benchmark
```shell
./benchmarks/grpc.sh
```

### Webflux
Start
```shell
docker compose -f compose.webflux.yaml up

http :8081/dashboard
```

### graphQL

`./benchmarks/graphql.sh`



### OTEL
Webflux
```shell
docker compose -f compose.webflux.otel.yaml up

http :8081/dashboard
```

gRPC
```shell
docker compose -f compose.grpc.otel.yaml up

http :8081/dashboard
```

## Benchmarks Runner
Fortio UI:

```shell
# start fortio server
docker run --network=architecture-benchmark_default -p 8080:8080 -p 8079:8079 fortio/fortio server
```
Open [fortio ui](http://localhost:8080/fortio) and run the load to test
* grpc: http://bff-grpc:8080/dashboard
* webflux: http://bff-webflux:8080/dashboard


Terminal:
```shell
#fortio load -logger-force-color -qps 5000 -c 6 -t 30s -nocatchup -uniform  http://localhost:8081/dashboard
cd benchmark
./benchmark.sh http-webflux localhost:8081 1000 10 6
./benchmark.sh http-webflux localhost:8081 5000 20 6

./benchmark.sh grpc localhost:9090 1000 10 6 10
./benchmark.sh grpc localhost:9090 5000 20 6 100
```

## Resurces

[Docker OpenTelemetry](https://grafana.com/docs/opentelemetry/docker-lgtm/)
[Grafana otel lgtm](https://github.com/grafana/docker-otel-lgtm/)
[Dockerfile](https://github.com/grafana/docker-otel-lgtm/blob/main/examples/java/Dockerfile)

