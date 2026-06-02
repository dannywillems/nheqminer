#!/usr/bin/env bash
#
# Build the nheqminer Docker image (CPU xenoncat solver) from the
# repository Dockerfile. Works on any platform with Docker installed, and
# needs no local Boost, CMake, or fasm.
#
# This script runs in CI to verify the container build, and the
# documentation site embeds it verbatim.
#
# Usage:
#   ./scripts/build-docker.sh [image-tag]
#
# Arguments:
#   image-tag   Tag for the built image (default: nheqminer:local).
#

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
image_tag="${1:-nheqminer:local}"

docker build --tag "${image_tag}" "${repo_root}"

echo "Built image: ${image_tag}"
