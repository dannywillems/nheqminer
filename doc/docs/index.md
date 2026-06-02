---
sidebar_position: 0
slug: /
title: Overview
---

# nheqminer

nheqminer is an Equihash CPU miner for Zcash. It solves the Equihash
proof-of-work puzzle and submits solutions to a mining endpoint over the
Stratum protocol.

This site is live documentation. The build commands shown on the
[Build](./build) page are the exact scripts that run in continuous
integration, so the published instructions are verified on every change
rather than copied by hand.

## What you get here

- [Equihash](./equihash): what the algorithm is and what its parameters
  mean.
- [Build](./build): the CI-verified scripts to build the miner on
  Debian/Ubuntu or with Docker.
- [Mining with Zebra](./mining-with-zebra): the command-line parameters and
  how to point the miner at a Zebra (zebrad) node.

## Quick start

Build the CPU miner on Debian or Ubuntu:

```bash
./scripts/build-debian.sh
```

Run a benchmark to confirm it works:

```bash
./build/nheqminer -b
```

Mine against a Stratum endpoint with 4 CPU threads:

```bash
./build/nheqminer -l HOST:PORT -u ADDRESS.worker1 -t 4
```

See [Mining with Zebra](./mining-with-zebra) for what `HOST:PORT` and
`ADDRESS` should be.

## Scope

This documentation focuses on the CPU solver (xenoncat, AVX/AVX2), which is
what the CI builds and tests. The project also ships NVIDIA CUDA solvers;
those are summarized on the [Mining with Zebra](./mining-with-zebra) page
but are not built in CI.
