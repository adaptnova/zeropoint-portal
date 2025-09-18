#!/usr/bin/env bash
set -euo pipefail

export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Start Ray head first (for dashboard + potential scaling later)
ray start --head \
  --port=6379 \
  --dashboard-host=0.0.0.0 \
  --dashboard-port="${RAY_DASHBOARD_PORT}" || true

exec "$@"
