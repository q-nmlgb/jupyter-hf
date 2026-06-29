FROM nvidia/cuda:12.5.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Paris \
    CONDA_AUTO_UPDATE_CONDA=false \
    HOME=/root \
    PATH=/root/miniconda/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    GRADIO_ALLOW_FLAGGING=never \
    GRADIO_NUM_PORTS=1 \
    GRADIO_SERVER_NAME=0.0.0.0 \
    GRADIO_THEME=huggingface \
    SYSTEM=spaces \
    SHELL=/bin/bash

# Base utilities
RUN rm -f /etc/apt/sources.list.d/*.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    git \
    wget \
    procps \
    git-lfs \
    zip \
    unzip \
    htop \
    vim \
    nano \
    bzip2 \
    libx11-6 \
    build-essential \
    libsndfile-dev \
    software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# nvtop
RUN add-apt-repository ppa:flexiondotorg/nvtop && \
    apt-get update && \
    apt-get install -y --no-install-recommends nvtop && \
    rm -rf /var/lib/apt/lists/*

# Node.js 21
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g configurable-http-proxy && \
    rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /root

# User setup

# Miniconda Python 3.12 (latest stable)
USER root
RUN curl -fsSL -o /root/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py312_24.7.1-0-Linux-x86_64.sh && \
    bash /root/miniconda.sh -b -p /root/miniconda && \
    rm -f /root/miniconda.sh && \
    conda clean -ya

WORKDIR /root

# Back to root for system packages / startup
USER root

RUN --mount=target=/root/packages.txt,source=packages.txt \
    apt-get update && \
    xargs -r -a /root/packages.txt apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=target=/root/on_startup.sh,source=on_startup.sh,readwrite \
    bash /root/on_startup.sh

RUN mkdir -p /data && chown root:root /data

# Python packages
USER root
RUN --mount=target=requirements.txt,source=requirements.txt \
    pip install --no-cache-dir --upgrade -r requirements.txt

# App files
COPY --chown=root:root . /root

RUN chmod +x /root/start_server.sh
      

WORKDIR /root
# Jupyter template path for Python 3.12
COPY --chown=root:root login.html /root/miniconda/lib/python3.12/site-packages/jupyter_server/templates/login.html

CMD ["./start_server.sh"]
