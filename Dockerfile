# CUDA 12.5.1 devel for H200 support
FROM nvidia/cuda:12.5.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:${PATH}" \
    HF_HOME=/root/.cache/huggingface \
    OWUI_DATA_DIR=/opt/open-webui/data \
    VLLM_MODEL=NousResearch/Hermes-4-70B-FP8 \
    VLLM_PORT=8000 \
    OWUI_PORT=7500 \
    RAY_DASHBOARD_PORT=8265 \
    SYNCTHING_PORT=8384 \
    JUPYTER_PORT=8080 \
    CADDY_PORT=1111 \
    NODE_EXPORTER_PORT=9100 \
    TORCH_CUDA_ARCH_LIST="9.0" \
    VLLM_FLASH_ATTN_VERSION=2

# Base OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3.11-venv python3.11-distutils python3-pip python3.11-dev \
    git curl ca-certificates build-essential pkg-config wget \
    supervisor nginx-light \
    prometheus-node-exporter \
    syncthing \
    && rm -rf /var/lib/apt/lists/*

# Install newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.sh -O /tmp/cmake.sh \
    && chmod +x /tmp/cmake.sh \
    && /tmp/cmake.sh --skip-license --prefix=/usr/local \
    && rm /tmp/cmake.sh

# Python venv
RUN python3.11 -m venv /opt/venv && \
    python -m pip install --upgrade pip setuptools wheel

# PyTorch nightly for H200 support
RUN python -m pip uninstall -y torch torchvision torchaudio
RUN python -m pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 --force-reinstall

# Performance libs (best-effort pins for Hopper)
RUN python -m pip install "triton==3.0.0"
# RUN python -m pip install "flash-attn==2.7.2" --no-build-isolation || true
# RUN python -m pip install "xformers==0.0.28.post3" --no-build-isolation || true

# vLLM from source for H200 support
RUN python -m pip install setuptools_scm
ENV CMAKE_ARGS="-DCMAKE_CXX_STANDARD=17"
RUN git clone https://github.com/vllm-project/vllm.git /opt/vllm
WORKDIR /opt/vllm
RUN python -m pip install -e . --no-build-isolation
WORKDIR /workspace

# Open-WebUI (pin)
RUN python -m pip install "open-webui==0.6.28" "uvicorn[standard]" "fastapi"

# JupyterLab for convenience
RUN python -m pip install "jupyterlab==4.2.5"

# Caddy (static binary)
RUN curl -fsSL https://caddyserver.com/api/download?os=linux&arch=amd64&idempotency=123 \
    -o /usr/local/bin/caddy && chmod +x /usr/local/bin/caddy

# Cloudflared (quick tunnel for public URL)
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared

# OpenTelemetry Collector
RUN curl -fsSL https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.115.1/otelcol_0.115.1_linux_amd64.deb \
    -o /tmp/otelcol.deb && dpkg -i /tmp/otelcol.deb && rm -f /tmp/otelcol.deb

# Runtime dirs
RUN mkdir -p /workspace/models /var/log/supervisor "${OWUI_DATA_DIR}" /etc/caddy \
    /etc/openwebui /opt/portal

# Copy configs
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY Caddyfile /etc/caddy/Caddyfile
COPY otel-collector.yaml /etc/otelcol/config.yaml
COPY portal/index.html /opt/portal/index.html
COPY openwebui-presets/hermes_prompts.json ${OWUI_DATA_DIR}/prompts/hermes_prompts.json
COPY openwebui-presets/hermes_presets.json ${OWUI_DATA_DIR}/presets/hermes_presets.json

RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose all service ports
EXPOSE 1111 7500 8000 8265 8384 8080 9100

# Healthcheck: vLLM models endpoint
HEALTHCHECK --interval=30s --timeout=5s --retries=30 \
  CMD curl -fsS http://127.0.0.1:${VLLM_PORT}/v1/models >/dev/null || exit 1

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]