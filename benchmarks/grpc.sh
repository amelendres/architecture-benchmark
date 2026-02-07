#!/usr/bin/env bash
set -e
# set -euo pipefail

RPS=${1:-1000}
DURATION=${2:-30}
CONNECTIONS=${3:-4}
CONCURRENY=${4:-100}
CPUS=${5:-4}
FILENAME=grpc_ghz-${RPS}qps-${DURATION}s-${CONNECTIONS}cnx-${CONCURRENY}c-${CPUS}cpus

RESULTS=results/$FILENAME.json
RAW=results/$FILENAME-raw.json

mkdir -p results

ghz \
  --proto ../services/bff-grpc/src/main/proto/dashboard.proto \
  --call DashboardService.GetDashboard \
  --data '{"user_id":"1"}' \
  --rps $RPS \
  --connections $CONNECTIONS \
  --concurrency $CONCURRENY \
  --duration ${DURATION}s \
  --cpus $CPUS \
  --insecure \
  --format json \
  localhost:9090  > $RAW

# require jq and awk
command -v jq >/dev/null || { echo "jq required"; exit 1; }

p50_ns=$(jq '.latencyDistribution[] | select(.percentage==50) | .latency' "$RAW")
p75_ns=$(jq '.latencyDistribution[] | select(.percentage==75) | .latency' "$RAW")
p90_ns=$(jq '.latencyDistribution[] | select(.percentage==90) | .latency' "$RAW")
p95_ns=$(jq '.latencyDistribution[] | select(.percentage==95) | .latency' "$RAW")
p99_ns=$(jq '.latencyDistribution[] | select(.percentage==99) | .latency' "$RAW")
p99_9_ns=$(jq '.latencyDistribution[] | select(.percentage==99.9) | .latency' "$RAW")
avg_ns=$(jq '.average' "$RAW")
rps=$(jq '.rps' "$RAW")

# fallback to 0 if missing
p50_ns=${p50_ns:-0}
p75_ns=${p75_ns:-0}
p90_ns=${p90_ns:-0}
p95_ns=${p95_ns:-0}
p99_ns=${p99_ns:-0}
p99_9_ns=${p99_9_ns:-0}
avg_ns=${avg_ns:-0}
rps=${rps:-0}

p50=$(awk -v n="$p50_ns" 'BEGIN{printf "%.2f", n/1e6}')
p75=$(awk -v n="$p75_ns" 'BEGIN{printf "%.2f", n/1e6}')
p90=$(awk -v n="$p90_ns" 'BEGIN{printf "%.2f", n/1e6}')
p95=$(awk -v n="$p95_ns" 'BEGIN{printf "%.2f", n/1e6}')
p99=$(awk -v n="$p99_ns" 'BEGIN{printf "%.2f", n/1e6}')
p99_9=$(awk -v n="$p99_9_ns" 'BEGIN{printf "%.2f", n/1e6}')
avg=$(awk -v n="$avg_ns" 'BEGIN{printf "%.2f", n/1e6}')
rps_f=$(awk -v r="$rps" 'BEGIN{printf "%.2f", r}')

cat > $RESULTS <<EOF
{
  "p50": $p50,
  "p75": $p75,
  "p90": $p90,
  "p95": $p95,
  "p99": $p99,
  "p99.9": $p99_9,
  "avg": $avg,
  "rps": $rps_f
} 
EOF
