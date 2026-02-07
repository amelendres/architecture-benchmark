#!/usr/bin/env bash
set -euo pipefail

TYPE=${1:-"grpc"}

# docker compose -f compose.$TYPE.yaml up -d

until [ "$(docker inspect -f {{.State.Health.Status}} bff-$TYPE)" == "healthy" ]
do
    echo "$TYPE svc starting ..."
    sleep 3
done

echo "$TYPE is healthy"