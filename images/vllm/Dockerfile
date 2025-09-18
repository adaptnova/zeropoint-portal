# vllm Application Image
ARG BASE_IMAGE=adaptnova/zeropoint-portal/base/cuda:latest
FROM ${BASE_IMAGE} AS builder

# Switch to root to install packages
USER root

# Install vllm build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    python3.11-dev \
    && rm -rf /var/lib/apt/lists/*

# Switch back to app user
USER app

# Set C++ standard
ENV CMAKE_ARGS="-DCMAKE_CXX_STANDARD=17"

# Install build tools
RUN python3.11 -m pip install --upgrade pip setuptools wheel

# Install setuptools_scm
RUN python3.11 -m pip install setuptools_scm

# Clone vllm and build a wheel
RUN git clone https://github.com/vllm-project/vllm.git /opt/vllm
WORKDIR /opt/vllm
RUN python3.11 -m pip wheel . -w /tmp/wheels

# Final runtime image
FROM ${BASE_IMAGE}

# Switch to root to copy files
USER root

# Create a virtual environment
RUN python3.11 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install the vllm wheel
COPY --from=builder /tmp/wheels /tmp/wheels
RUN python3.11 -m pip install /tmp/wheels/vllm-*.whl && rm -rf /tmp/wheels

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch back to app user
USER app

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python", "-m", "vllm.entrypoints.api_server"]
