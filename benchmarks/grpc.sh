#!/usr/bin/env bash
set -e
# set -euo pipefail

RPS=${1:-1000}
CONCURRENY=${2:-100}
DURATION=${3:-30}
CPUS=${4:-6}
FILENAME=grpc-${RPS}rps-${CONCURRENY}-${DURATION}s-${CPUS}cpus

RESULTS=benchmarks/results/$FILENAME.json
RAW=benchmarks/results/$FILENAME-raw.json

mkdir -p benchmarks/results

ghz \
  --proto services/bff-grpc/src/main/proto/dashboard.proto \
  --call DashboardService.GetDashboard \
  --data '{"user_id":"1"}' \
  --rps $RPS \
  --concurrency $CONCURRENY \
  --duration ${DURATION}s \
  --cpus $CPUS \
  --insecure \
  --format json \
  localhost:9090  > $RAW

# require jq and awk
command -v jq >/dev/null || { echo "jq required"; exit 1; }

p50_ns=$(jq '.latencyDistribution[] | select(.percentage==50) | .latency' "$RAW")
p95_ns=$(jq '.latencyDistribution[] | select(.percentage==95) | .latency' "$RAW")
p99_ns=$(jq '.latencyDistribution[] | select(.percentage==99) | .latency' "$RAW")
avg_ns=$(jq '.average' "$RAW")
rps=$(jq '.rps' "$RAW")

# fallback to 0 if missing
p50_ns=${p50_ns:-0}
p95_ns=${p95_ns:-0}
p99_ns=${p99_ns:-0}
avg_ns=${avg_ns:-0}
rps=${rps:-0}

p50=$(awk -v n="$p50_ns" 'BEGIN{printf "%.2f", n/1e6}')
p95=$(awk -v n="$p95_ns" 'BEGIN{printf "%.2f", n/1e6}')
p99=$(awk -v n="$p99_ns" 'BEGIN{printf "%.2f", n/1e6}')
avg=$(awk -v n="$avg_ns" 'BEGIN{printf "%.2f", n/1e6}')
rps_f=$(awk -v r="$rps" 'BEGIN{printf "%.2f", r}')

cat > $RESULTS <<EOF
{
  "p50": $p50,
  "p95": $p95,
  "p99": $p99,
  "avg": $avg,
  "rps": $rps_f
} 
EOF
