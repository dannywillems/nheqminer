# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

nheqminer is an Equihash CPU and GPU miner for Zcash, originally developed by NiceHash. It supports multiple solver backends for both CPU and NVIDIA CUDA GPUs, connecting to mining pools via the Stratum protocol.

## Remote Execution

Commands should be run on the remote machine `d` via SSH:
```bash
ssh d 'fish -c "cd /home/m/zcash/nheqminer; and <command>"'
```

## Build Commands

### Linux Build (CMake)

```bash
# First, assemble the xenoncat AVX objects (required for CPU_XENONCAT solver)
cd cpu_xenoncat/asm_linux && sh assemble.sh && cd ../..

# Build
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### CMake Solver Options

Control which solvers are built via CMake options (defaults in CMakeLists.txt):
- `USE_CPU_TROMP` (OFF) - Older CPU solver
- `USE_CPU_XENONCAT` (ON) - Faster CPU solver (requires fasm-assembled objects)
- `USE_CUDA_TROMP` (OFF) - Older CUDA solver
- `USE_CUDA_DJEZO` (ON) - Faster CUDA solver

Example to enable a specific solver:
```bash
cmake -DUSE_CPU_TROMP=ON -DUSE_CUDA_DJEZO=OFF ..
```

### Dependencies

- Boost 1.62+ (system, log_setup, log, date_time, filesystem, thread)
- CMake 3.5+
- CUDA SDK v8+ (for GPU solvers)
- fasm (for assembling cpu_xenoncat on non-Ubuntu systems)

## Running

```bash
# Benchmark CPU
./nheqminer -b

# Mine with CPU (6 threads)
./nheqminer -l equihash.eu.nicehash.com:3357 -u YOUR_BTC_ADDRESS.worker1 -t 6

# Mine with CPU + CUDA GPUs
./nheqminer -l equihash.eu.nicehash.com:3357 -u YOUR_BTC_ADDRESS.worker1 -t 6 -cd 0 1

# Show CUDA device info
./nheqminer -ci
```

## Architecture

### Solver Abstraction

The codebase uses a plugin-like architecture for equihash solvers:

- `ISolver` (nheqminer/ISolver.h) - Abstract interface all solvers implement
- `Solver<T>` (nheqminer/Solver.h) - Template wrapper for solver contexts
- `AvailableSolvers.h` - Concrete solver class definitions (CPUSolverTromp, CPUSolverXenoncat, CUDASolverDjezo, CUDASolverTromp)
- `MinerFactory` - Creates solver instances based on command-line configuration

Each solver directory contains its own implementation:
- `cpu_tromp/` - CPU solver by tromp
- `cpu_xenoncat/` - Optimized CPU solver with AVX/AVX2 assembly (requires fasm)
- `cuda_tromp/` - CUDA GPU solver by tromp
- `cuda_djezo/` - Optimized CUDA GPU solver by djeZo

### Stratum Client

- `libstratum/StratumClient.h` - Template-based stratum protocol client
- `libstratum/ZcashStratum.h` - Zcash-specific types (ZcashJob, ZcashMiner, EquihashSolution)

The `ZcashMiner` class manages solver threads and communicates solutions back to the `ZcashStratumClient` via callbacks.

### Key Data Flow

1. `main.cpp` parses CLI args, detects CPU features (AVX/AVX2), creates `MinerFactory`
2. `MinerFactory::GenerateSolvers()` instantiates appropriate solver objects
3. `ZcashStratumClient` connects to pool, receives jobs, passes to `ZcashMiner`
4. `ZcashMiner` distributes work to solver threads
5. Solutions are submitted back through `StratumClient::submit()`

### Supporting Libraries

- `blake2/` - BLAKE2b hash implementation (used by Equihash)
- `nheqminer/json/` - json_spirit for Stratum JSON-RPC
- `nheqminer/primitives/` - Block header structures from Bitcoin/Zcash
