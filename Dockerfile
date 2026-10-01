FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app
COPY . .

# Install dependencies (no dev/onnx extras needed for serving)
RUN uv sync --no-dev

# Download gliformer-base (600MB, CPU-optimised)
# Switch to gliformer-large-v1 if you have >4GB RAM and want better accuracy
RUN uv run hf download knowledgator/gliformer-base-v1 --local-dir models/gliformer-base-v1

ENV JEFF_MODEL=models/gliformer-base-v1
ENV JEFF_MODEL_NAME=gliformer-base-v1
ENV JEFF_MODEL_ALIASES=jev-latest,jev
ENV JEFF_DEVICE=cpu
ENV JEFF_HOST=0.0.0.0
ENV JEFF_PORT=8000
# Set JEFF_API_KEYS via Dokploy env var — do not hardcode here

EXPOSE 8000

CMD ["uv", "run", "jeff"]
