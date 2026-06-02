---
sidebar_position: 3
title: Mining with Zebra
---

# Mining with Zebra

nheqminer connects to a mining endpoint over the Stratum protocol and submits
Equihash solutions. This page lists the command-line parameters and describes
how to mine toward a [Zebra](https://zebra.zfnd.org/) (`zebrad`) node.

## What is Stratum

Stratum is the network protocol between a miner and a mining pool. Instead of
each miner polling a node's `getblocktemplate` RPC, the pool pushes work to the
miner (a `mining.notify` message carrying the header fields to hash and a
target), and the miner submits shares at a difficulty the pool sets below the
network difficulty. This keeps many miners busy and lets the pool measure each
miner's contribution without waiting for a full block.

Zcash uses a Stratum V1 variant (line-based JSON-RPC over TCP) defined by
[ZIP 301](https://zips.z.cash/zip-0301), which differs from Bitcoin's Stratum
because of the different block header format and proof-of-work algorithm.
nheqminer speaks this protocol.

## Running the miner

After [building](./build), the binary is `build/nheqminer`. The basic form
is:

```bash
./build/nheqminer -l HOST:PORT -u ADDRESS.worker1 -t 4
```

Confirm the build first with a benchmark, which needs no network:

```bash
./build/nheqminer -b
```

## Parameters

| Flag             | Meaning                                                |
| ---------------- | ------------------------------------------------------ |
| `-h`             | Print help and quit.                                   |
| `-l [host:port]` | Stratum server and port to connect to.                 |
| `-u [username]`  | Username for the endpoint (often a payout address).    |
| `-a [port]`      | Local API port (default `0`, meaning do not bind).     |
| `-d [level]`     | Debug print level (`0` = all, `5` = fatal, default 2). |
| `-b [hashes]`    | Benchmark mode (default 200 iterations).               |
| `-t [num]`       | Number of CPU threads.                                 |
| `-e [ext]`       | Force CPU extension (`0` = SSE2, `1` = AVX, `2` = AVX2). |

NVIDIA CUDA flags also exist (`-ci`, `-cv`, `-cd`, `-cb`, `-ct`) for the GPU
solvers. They require building with a CUDA solver enabled and are out of scope
for the CPU build documented here.

Example with CPU and two CUDA devices:

```bash
./build/nheqminer -l HOST:PORT -u ADDRESS.worker1 -t 4 -cd 0 1
```

## Connecting to a Stratum instance

nheqminer is a Stratum client; it does not call a node's RPC directly. Zebra
exposes the mining RPC methods (`getblocktemplate`, `submitblock`), not
Stratum. To mine toward a `zebrad` node you run a Stratum server (a pool) in
front of it. The data flow is:

```text
nheqminer  --Stratum (ZIP 301)-->  Stratum server (s-nomp)  --getblocktemplate-->  zebrad
```

`s-nomp` is the Stratum server used here; it connects to Zebra's RPC and
exposes a Stratum port for miners. See the walkthrough linked below for the
exact fork and setup.

### 1. Configure zebrad

Set a transparent mining address (Zebra accepts p2pkh or p2sh transparent
addresses) and enable the RPC endpoint. The default RPC port is `8232` on
mainnet and `18232` on testnet.

```toml
network = "Testnet"

[rpc]
# Keep this on localhost unless the Stratum server runs elsewhere on a
# trusted network.
listen_addr = "127.0.0.1:18232"
# Zebra v2.0.0+ enables cookie authentication by default; the s-nomp fork
# connects without it, so disable it.
enable_cookie_auth = false

[mining]
# Transparent address that receives the block reward.
miner_address = "t1ExampleTransparentAddress"
```

### 2. Run the Stratum server

Run `s-nomp` pointed at Zebra's RPC port. It exposes a Stratum port that
miners connect to.

### 3. Point nheqminer at the Stratum port

```bash
./build/nheqminer -l 127.0.0.1:STRATUM_PORT -u t1ExampleTransparentAddress.worker1 -t 4
```

:::tip Full walkthrough

For an end-to-end setup (the `zebrad.toml` config, running `s-nomp`, and a
testnet mining run), see the blog post:
[Zcash mining with Zebra and Stratum](https://dannywillems.github.io/blog/2026/06/02/zcash-mining-zebra-stratum/).

:::

## Notes

- Keep the `zebrad` RPC bound to localhost or a trusted network. Exposing a
  node's RPC to the public internet is a common misconfiguration.
- The username (`-u`) is passed through to the endpoint. What it should be
  (a payout address, a pool account, or an arbitrary worker name) depends on
  the Stratum endpoint you connect to.
- Solo mining finds blocks at a rate proportional to your share of the
  network hash rate, so a single CPU miner may go a long time between blocks
  on mainnet. A local test network (regtest/testnet) is the usual way to
  exercise the full path end to end.
