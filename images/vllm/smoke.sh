#!/bin/sh
set -e

echo "Starting vllm api server for smoke test..."
python -m vllm.entrypoints.api_server &
PID=$!

# Wait for the server to start
sleep 10

# Check if the server is running
if ! kill -0 $PID; then
    echo "Smoke test failed: vllm server did not start."
    exit 1
fi

echo "Smoke test passed: vllm server started successfully."
kill $PID