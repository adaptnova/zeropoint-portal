# Golden CUDA Base Image
# Pinned to nvidia/cuda:12.5.1-devel-ubuntu22.04
FROM nvidia/cuda:12.5.1-devel-ubuntu22.04@sha256:db2e4b709df8db28d0465ef73938899191a885413937c026622974b9474b4b78

# Install essential packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd -r app && useradd -r -g app -s /bin/bash -d /home/app app
RUN mkdir -p /home/app && chown -R app:app /home/app

# Set the user
USER app
WORKDIR /home/app
