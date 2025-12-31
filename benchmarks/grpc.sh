#!/usr/bin/env bash
set -e
# set -euo pipefail

RESULTS=${1:-benchmarks/results/grpc-results.json}
TO_COMPARE=${1:-benchmarks/results/grpc.json}

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
  localhost:9090  > $RESULTS

# require jq and awk
command -v jq >/dev/null || { echo "jq required"; exit 1; }

p50_ns=$(jq '.latencyDistribution[] | select(.percentage==50) | .latency' "$RESULTS")
p95_ns=$(jq '.latencyDistribution[] | select(.percentage==95) | .latency' "$RESULTS")
p99_ns=$(jq '.latencyDistribution[] | select(.percentage==99) | .latency' "$RESULTS")
rps=$(jq '.rps' "$RESULTS")

# fallback to 0 if missing
p50_ns=${p50_ns:-0}
p95_ns=${p95_ns:-0}
p99_ns=${p99_ns:-0}
rps=${rps:-0}

p50=$(awk -v n="$p50_ns" 'BEGIN{printf "%.2f", n/1e6}')
p95=$(awk -v n="$p95_ns" 'BEGIN{printf "%.2f", n/1e6}')
p99=$(awk -v n="$p99_ns" 'BEGIN{printf "%.2f", n/1e6}')
rps_f=$(awk -v r="$rps" 'BEGIN{printf "%.2f", r}')

cat > $TO_COMPARE <<EOF
{
  "p50": $p50,
  "p95": $p95,
  "p99": $p99,
  "rps": $rps_f
} 
EOF
