# nheqminer Dockerfile
# Equihash CPU miner for Zcash mining pools

FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    cmake=3.25.1-1 \
    libboost-system-dev=1.74.0.3 \
    libboost-log-dev=1.74.0.3 \
    libboost-date-time-dev=1.74.0.3 \
    libboost-filesystem-dev=1.74.0.3 \
    libboost-thread-dev=1.74.0.3 \
    fasm=1.73.30-1 \
    ca-certificates=20230311+deb12u1 \
    && rm -rf /var/lib/apt/lists/*

# Copy source to /src/nheqminer (CMakeLists.txt expects build dir as sibling)
WORKDIR /src/nheqminer
COPY . .

# Assemble xenoncat AVX objects using system fasm
WORKDIR /src/nheqminer/cpu_xenoncat/asm_linux
RUN fasm -m 1280000 equihash_avx1.asm && fasm -m 1280000 equihash_avx2.asm

# Build nheqminer (CPU only, no CUDA in container)
# Build directory must be sibling to source for CMakeLists.txt paths to work
WORKDIR /src/build
RUN cmake ../nheqminer \
    -DUSE_CPU_XENONCAT=ON \
    -DUSE_CPU_TROMP=OFF \
    -DUSE_CUDA_DJEZO=OFF \
    -DUSE_CUDA_TROMP=OFF \
    && make -j"$(nproc)"

# Runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libboost-system1.74.0=1.74.0+ds1-21 \
    libboost-log1.74.0=1.74.0+ds1-21 \
    libboost-date-time1.74.0=1.74.0+ds1-21 \
    libboost-filesystem1.74.0=1.74.0+ds1-21 \
    libboost-thread1.74.0=1.74.0+ds1-21 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/build/nheqminer /usr/local/bin/

RUN useradd --create-home --shell /bin/false miner
USER miner

# Default: run with help to show usage
ENTRYPOINT ["nheqminer"]
CMD ["-h"]
