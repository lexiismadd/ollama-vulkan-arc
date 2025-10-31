# Simpler build from source approach
FROM ubuntu:24.04 AS builder

# Install all build dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    wget \
    golang-go \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Vulkan development files
RUN apt-get update && apt-get install -y \
    libvulkan-dev \
    vulkan-tools \
    && rm -rf /var/lib/apt/lists/*

# Configure git
RUN git config --global user.email "builder@ollama.local" && \
    git config --global user.name "Ollama Builder"

# Clone Ollama
WORKDIR /build
ARG OLLAMA_VERSION=v0.12.7
RUN git clone --depth 1 --branch ${OLLAMA_VERSION} https://github.com/ollama/ollama.git

# Build Ollama
WORKDIR /build/ollama
ENV CGO_ENABLED=1
RUN go generate ./... && \
    go build -o ollama .

# Runtime stage
FROM ubuntu:24.04

# Install runtime deps
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Install Intel GPU drivers
RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | \
    tee /etc/apt/sources.list.d/intel-gpu-noble.list

RUN apt-get update && apt-get install -y \
    intel-opencl-icd \
    intel-level-zero-gpu \
    level-zero \
    libvulkan1 \
    mesa-vulkan-drivers \
    && rm -rf /var/lib/apt/lists/*

# Copy Ollama binary
COPY --from=builder /build/ollama/ollama /usr/local/bin/ollama

# Environment
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_NUM_GPU=999
ENV ZES_ENABLE_SYSMAN=1

RUN mkdir -p /root/.ollama

WORKDIR /root
EXPOSE 11434

ENTRYPOINT ["/usr/local/bin/ollama"]
CMD ["serve"]