#!/bin/bash
set -e

if [ "$1" = 'wrk' ]; then
   echo "...with docker wrk2\\n\\n"
    exec "$@"
fi

exec "$@"