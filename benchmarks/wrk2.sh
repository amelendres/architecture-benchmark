#!/bin/bash
# wrk2 wrapper script for ARM64 macOS
# This script runs wrk2 in a Docker container
# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
echo "Error: Docker is not running. Please start Docker Desktop."
exit 1
fi
# Check if the wrk2-arm64 image exists
if ! docker image inspect wrk2-arm64 > /dev/null 2>&1; then
echo "Error: wrk2-arm64 Docker image not found. Please build it first."
echo "Run: docker build -t wrk2-arm64 ."
exit 1
fi
# Run wrk2 in Docker container
#docker run -v .:/wrk2/ --network=architecture-benchmark_default --name wrk2 --rm wrk2-arm64 "$@"
docker run -v .:/wrk2/ --network=architecture-benchmark_default --name wrk2 --rm -it wrk2-arm64 bash

