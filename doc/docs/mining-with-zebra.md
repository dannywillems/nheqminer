---
sidebar_position: 3
title: Mining with Zebra
---

# Mining with Zebra

nheqminer connects to a mining endpoint over the Stratum protocol and submits
Equihash solutions. This page lists the command-line parameters and describes
how to mine toward a [Zebra](https://zebra.zfnd.org/) (`zebrad`) node.

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

## How nheqminer talks to a node

nheqminer is a Stratum client. It does not call a node's RPC directly.
Zebra exposes the mining RPC methods (`getblocktemplate`, `submitblock`),
not Stratum. To mine toward a `zebrad` node you therefore need a Stratum
endpoint in front of it: either a mining pool, or a solo Stratum bridge that
speaks `getblocktemplate`/`submitblock` to `zebrad` and Stratum to the miner.

The data flow is:

```text
nheqminer  --Stratum-->  Stratum endpoint  --getblocktemplate/submitblock-->  zebrad
```

## Configuring zebrad

Enable Zebra's RPC endpoint and set the address that receives the coinbase.
The exact configuration keys depend on your Zebra version; the snippet below
is illustrative. Check the
[Mining with Zebra](https://zebra.zfnd.org/user/mining.html) guide for the
keys that match your build.

```toml
[rpc]
# Address the mining RPC listens on. Keep it on localhost unless the
# Stratum bridge runs on another host on a trusted network.
listen_addr = "127.0.0.1:8232"

[mining]
# Transparent address that receives the block reward.
miner_address = "t1ExampleTransparentAddress"
```

Then point the Stratum endpoint at this RPC, and point nheqminer at the
Stratum endpoint:

```bash
./build/nheqminer -l 127.0.0.1:STRATUM_PORT -u t1ExampleTransparentAddress.worker1 -t 4
```

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
