#!/usr/bin/env bash
set -euo pipefail

# grpc=localhost:9090
# http-webflux=localhost:8081

TYPE=${1:-"grpc"}
HOST=${2:-"localhost:9090"}
RPS=${3:-1000}
DURATION=${4:-10}
CONCURRENY=${5:-6}
STREAM=${6:-50}


FILENAME=${TYPE}-${RPS}qps-${DURATION}s-${CONCURRENY}c
if [ "$TYPE" == "grpc" ]; then
  FILENAME+=-${STREAM}streams
fi

RAW=./results/$FILENAME-raw.json
RESULTS=./results/$FILENAME.json
# STREAMS=${$CONCURRENY*2}
mkdir -p results

case $TYPE in 
    "http_webflux") 
        fortio load -qps $RPS -c $CONCURRENY -t ${DURATION}s -json $RAW -nocatchup -uniform $HOST/dashboard
        ;;  
    "grpc") 
        # fortio load -grpc -grpc-method DashboardService.GetDashboard -payload '{"user_id":"1"}' -loglevel debug \
        fortio load -grpc -grpc-method DashboardService/GetDashboard -payload '{"user_id":"1"}' \
                -qps $RPS -c $CONCURRENY -s $STREAM -t ${DURATION}s \
                -json $RAW -nocatchup -uniform $HOST
                ;;
    *)
        echo "Unknown TYPE: $TYPE"
        exit 1 
        ;;
esac

p50_ns=$(jq '.DurationHistogram.Percentiles[] | select(.Percentile==50) | .Value' "$RAW")
p75_ns=$(jq '.DurationHistogram.Percentiles[] | select(.Percentile==75) | .Value' "$RAW")
p90_ns=$(jq '.DurationHistogram.Percentiles[] | select(.Percentile==90) | .Value' "$RAW")
p95_ns=$(jq '.DurationHistogram.Percentiles[] | select(.Percentile==95) | .Value' "$RAW")
p99_ns=$(jq '.DurationHistogram.Percentiles[] | select(.Percentile==99) | .Value' "$RAW")
p99_9_ns=$(jq '.DurationHistogram.Percentiles[] | select(.Percentile==99.9) | .Value' "$RAW")
avg_ns=$(jq '.DurationHistogram.Avg' "$RAW")
qps=$(jq '.ActualQPS' "$RAW")

# fallback to 0 if missing
p50_ns=${p50_ns:-0}
p75_ns=${p75_ns:-0}
p90_ns=${p90_ns:-0}
p95_ns=${p95_ns:-0}
p99_ns=${p99_ns:-0}
p99_9_ns=${p99_9_ns:-0}
avg_ns=${avg_ns:-0}
qps=${qps:-0}

p50=$(awk -v n="$p50_ns" 'BEGIN{printf "%.2f", n*1e3}')
p75=$(awk -v n="$p75_ns" 'BEGIN{printf "%.2f", n*1e3}')
p90=$(awk -v n="$p90_ns" 'BEGIN{printf "%.2f", n*1e3}')
p95=$(awk -v n="$p95_ns" 'BEGIN{printf "%.2f", n*1e3}')
p99=$(awk -v n="$p99_ns" 'BEGIN{printf "%.2f", n*1e3}')
p99_9=$(awk -v n="$p99_9_ns" 'BEGIN{printf "%.2f", n*1e3}')
avg=$(awk -v n="$avg_ns" 'BEGIN{printf "%.2f", n*1e3}')
rps=$(awk -v r="$qps" 'BEGIN{printf "%.2f", r}')

cat > $RESULTS <<EOF
{
  "p50": $p50,
  "p75": $p75,
  "p90": $p90,
  "p95": $p95,
  "p99": $p99,
  "p99.9": $p99_9,
  "avg": $avg,
  "rps": $rps
}
EOF

