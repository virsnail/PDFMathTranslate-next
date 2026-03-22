FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
WORKDIR /app
EXPOSE 7860
ENV PYTHONUNBUFFERED=1
ENV GRADIO_ANALYTICS_ENABLED=False
ENV HF_HUB_OFFLINE=1
ENV TRANSFORMERS_OFFLINE=1
ENV DO_NOT_TRACK=1

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    libgl1 libglib2.0-0 libxext6 libsm6 libxrender1 build-essential && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN uv pip install --system --no-cache -r pyproject.toml && \
    babeldoc --version && babeldoc --warmup

COPY . .

# 注意：删除了原版的 random.org 外部请求行
ARG CACHE_BUST=1
RUN echo "cache bust: $CACHE_BUST"

RUN uv pip install --system --no-cache . && \
    uv pip install --system --no-cache --compile-bytecode -U babeldoc "pymupdf<1.25.3" && \
    babeldoc --version && babeldoc --warmup

RUN pdf2zh --version
CMD ["pdf2zh", "--gui"]
