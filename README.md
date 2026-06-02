# nheqminer

nheqminer is an Equihash CPU miner for Zcash.

## documentation

Full documentation is published as a website:

**https://dannywillems.github.io/nheqminer/**

It covers what Equihash is and its parameters, the build instructions, and how
to configure the miner to mine against a Zebra (`zebrad`) node. The build
commands shown there are the exact scripts that run in CI
(`scripts/build-debian.sh` and `scripts/build-docker.sh`), so they are
verified on every change.

## quick start

Build on Debian or Ubuntu and run a benchmark:

```bash
./scripts/build-debian.sh
./build/nheqminer -b
```

See the [documentation](https://dannywillems.github.io/nheqminer/) for mining
configuration and all command-line options.
