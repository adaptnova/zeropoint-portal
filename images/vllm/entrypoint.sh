#!/bin/sh
set -e

# Default to running the vllm api server if no command is provided
if [ "$1" = "" ]; then
    exec python -m vllm.entrypoints.api_server
else
    exec "$@"
fi