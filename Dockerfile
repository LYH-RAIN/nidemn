FROM python:3.12-slim-bookworm
ENV UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Install uv (from official binary), nodejs, npm, and git
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl  \
    vim \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Confirm npm and node versions (optional debugging info)
RUN node -v && npm -v

# Copy your mcpo source code (assuming in src/mcpo)
COPY . /app
WORKDIR /app

# Create virtual environment explicitly in known location
ENV VIRTUAL_ENV=/app/.venv
RUN uv venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN echo 'export UV_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"' >> ~/.bashrc && \
    /bin/bash -c "source ~/.bashrc"
RUN #git clone https://github.com/open-webui/mcpo.git
RUN git clone https://github.com/LYH-RAIN/mcpo.git
WORKDIR /app/mcpo

RUN uv add --default-index https://pypi.tuna.tsinghua.edu.cn/simple requests

# Install mcpo (assuming pyproject.toml is properly configured)
RUN uv pip install . && rm -rf ~/.cache
RUN uv pip install gunicorn && rm -rf ~/.cache

#RUN mv /app/prepare.sh /app/mcpo && chmod +x prepare.sh && ./prepare.sh

# Verify mcpo installed correctly
RUN which mcpo

# Expose port (optional but common default)
EXPOSE 8000

# 设置环境变量以自动使用合适的 worker 数量
ENV WORKERS_AUTO=true

# 使用 Python 直接运行模块，利用 argparse 解析参数
# 这将自动检测 CPU 核心并使用适当数量的 workers
# Default help CMD (can override at runtime)
CMD mcpo --config /app/config.json --port 8000 --host 0.0.0.0 --api-key $API_KEY
