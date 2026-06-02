#!/usr/bin/env bash
#
# Assemble the xenoncat AVX equihash objects with the bundled fasm assembler.
# Produces the object files linked into the CPU_XENONCAT solver.
#
# Usage:
#   sh assemble.sh
#

set -euo pipefail

./fasm -m 1280000 equihash_avx1.asm
./fasm -m 1280000 equihash_avx2.asm
