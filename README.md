
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
- wrk2
- ghz
- jq
- python

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
Benchmarks:\
* [Install wrk2](./benchmarks/README.md)
```shell
docker build -t wrk2-arm64 benchmarks
docker run -v ./benchmarks:/wrk2/ --network=bff-benchmark_default --name wrk2 --rm -it wrk2-arm64 bash
```

Inside the container execute:
```shell
./webflux.sh
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
## Resurces

[Docker OpenTelemetry](https://grafana.com/docs/opentelemetry/docker-lgtm/)
[Grafana otel lgtm](https://github.com/grafana/docker-otel-lgtm/)
[Dockerfile](https://github.com/grafana/docker-otel-lgtm/blob/main/examples/java/Dockerfile)

