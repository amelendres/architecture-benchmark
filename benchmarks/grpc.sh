#!/usr/bin/env bash
set -e
mkdir -p benchmarks/results

ghz \
  --proto services/bff-grpc/src/main/proto/dashboard.proto \
  --call DashboardService.GetDashboard \
  --data '{"user_id":"1"}' \
  --concurrency 100 \
  --rps 1000 \
  --duration 30s \
  --insecure \
  --cpus 8 \
  --format json \
  localhost:9090  > benchmarks/results/grpc-results.json

cat benchmarks/results/grpc-results.json | jq 'del(.histogram,.details)' > benchmarks/results/grpc.json
