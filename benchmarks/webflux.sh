#!/usr/bin/env bash
set -e
set -euo pipefail

RPS=${1:-1000}
CONCURRENY=${2:-100}
DURATION=${3:-10}
CPUS=${4:-6}
HOST=${5:-"localhost:8081"}
# Use bff-webflux:8080 to run inside docker container

FILENAME=http-webflux-${RPS}rps-${CONCURRENY}-${DURATION}s-${CPUS}cpus

RESULTS=./results/$FILENAME.json
SUMARY=./results/$FILENAME-summary.json

mkdir -p results

sleep 2.5
wrk -R${RPS} -c${CONCURRENY} -d${DURATION}s -t${CPUS} -L -s export.lua http://$HOST/dashboard
sleep .5
mv ./results/http.json $RESULTS 
mv ./results/http_summary.json $SUMARY

