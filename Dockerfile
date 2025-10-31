# Multi-stage build for Ollama with Vulkan support
# Stage 1: Build Ollama with Vulkan
FROM ubuntu:24.04 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    wget \
    libcap-dev \
    golang-go \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Vulkan SDK
RUN wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | tee /etc/apt/trusted.gpg.d/lunarg.asc && \
    wget -qO /etc/apt/sources.list.d/lunarg-vulkan-noble.list http://packages.lunarg.com/vulkan/lunarg-vulkan-noble.list && \
    apt-get update && \
    apt-get install -y vulkan-sdk && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for build
ENV CGO_ENABLED=1
ENV LDFLAGS=-s
ENV VULKAN_SDK=/usr

# Clone Ollama repository
WORKDIR /build
ARG OLLAMA_VERSION=v0.12.6
RUN git clone --depth 1 --branch ${OLLAMA_VERSION} https://github.com/ollama/ollama.git

# Build Ollama with Vulkan support
WORKDIR /build/ollama
RUN make -f Makefile.sync clean sync && \
    cmake --preset CPU && \
    cmake --build --parallel --preset CPU && \
    cmake --install build --component CPU --strip && \
    cmake --preset Vulkan && \
    cmake --build --parallel --preset Vulkan && \
    cmake --install build --component Vulkan --strip && \
    source scripts/env.sh && \
    mkdir -p dist/bin && \
    go build -trimpath -buildmode=pie -o dist/bin/ollama .

# Stage 2: Runtime image
FROM ubuntu:24.04

# Install runtime dependencies and Intel GPU drivers
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add Intel GPU repository and install drivers
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

# Copy built Ollama from builder stage
COPY --from=builder /build/ollama/dist/bin/ollama /usr/local/bin/ollama
COPY --from=builder /build/ollama/dist/lib/ollama /usr/local/lib/ollama

# Set environment variables for Intel Arc GPU
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib/ollama:/usr/local/lib/ollama/vulkan:$LD_LIBRARY_PATH
ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_NUM_GPU=999
ENV ZES_ENABLE_SYSMAN=1

# Create directory for models
RUN mkdir -p /root/.ollama

WORKDIR /root
EXPOSE 11434

# Run Ollama server
ENTRYPOINT ["/usr/local/bin/ollama"]
CMD ["serve"]