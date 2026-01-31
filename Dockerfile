# Build stage
FROM python:3.9-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"
ENV CC=clang-18
ENV CXX=clang++-18

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    cmake \
    lsb-release \
    gnupg \
    ca-certificates \
    patch \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Clang 18
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-18 main" | tee /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y clang-18 libomp-18-dev && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-18 100 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /app

# Clone repository
RUN git clone --recursive https://github.com/microsoft/BitNet.git .

# Fix the compilation error in ggml-bitnet-mad.cpp
RUN sed -i 's/int8_t \* y_col = y + col \* by;/const int8_t * y_col = y + col * by;/g' src/ggml-bitnet-mad.cpp

# Install dependencies with uv
RUN uv pip install --system -r requirements.txt

# Download model
RUN huggingface-cli download microsoft/BitNet-b1.58-2B-4T-gguf \
    --local-dir models/BitNet-b1.58-2B-4T

# Build the project
RUN python setup_env.py -md models/BitNet-b1.58-2B-4T -q i2_s

# Runtime stage
FROM python:3.9-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    libgomp1 \
    libomp5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built artifacts from builder
COPY --from=builder /app/build /app/build
COPY --from=builder /app/models /app/models
COPY --from=builder /app/run_inference.py /app/run_inference.py
COPY --from=builder /app/*.py /app/

# Copy Python dependencies
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

COPY demo.sh interactive.sh /app/
RUN chmod +x /app/*.sh

EXPOSE 8080

CMD ["/bin/bash", "/app/demo.sh"]