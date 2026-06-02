#!/usr/bin/env bash
#
# Build nheqminer with the CPU xenoncat (AVX/AVX2) solver on Debian or
# Ubuntu.
#
# This script is the single source of truth for the Linux build: it runs in
# CI to verify the steps, and the documentation site embeds it verbatim, so
# the published instructions are always the ones that are actually tested.
#
# Usage:
#   ./scripts/build-debian.sh [build-dir]
#
# Arguments:
#   build-dir   Directory to build in (default: <repo>/build).
#
# Environment:
#   SKIP_DEPS=1   Skip the apt-get dependency installation step.
#

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
build_dir="${1:-${repo_root}/build}"

# Run a command as root, using sudo only when not already root. This keeps
# the script working both on CI runners (non-root + passwordless sudo) and
# inside containers (root, no sudo installed).
run_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# 1. Install the build dependencies: Boost, CMake, and the fasm assembler.
if [ "${SKIP_DEPS:-0}" != "1" ]; then
    run_root apt-get update
    run_root apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        fasm \
        libboost-system-dev \
        libboost-log-dev \
        libboost-date-time-dev \
        libboost-filesystem-dev \
        libboost-thread-dev
fi

# 2. Assemble the xenoncat AVX1 and AVX2 equihash objects with fasm.
cd "${repo_root}/cpu_xenoncat/asm_linux"
fasm -m 1280000 equihash_avx1.asm
fasm -m 1280000 equihash_avx2.asm

# 3. Configure the build with the CPU xenoncat solver only (no CUDA).
cmake -S "${repo_root}" -B "${build_dir}" \
    -DUSE_CPU_XENONCAT=ON \
    -DUSE_CPU_TROMP=OFF \
    -DUSE_CUDA_DJEZO=OFF \
    -DUSE_CUDA_TROMP=OFF

# 4. Compile.
cmake --build "${build_dir}" -j"$(nproc)"

echo "Build complete: ${build_dir}/nheqminer"
