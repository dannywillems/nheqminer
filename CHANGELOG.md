# Changelog

All notable changes to this project are documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Add project guidance for Claude Code in CLAUDE.md ([68bdb13])
- Add a Dockerfile and .dockerignore to build the CPU miner in a
  container ([ec49af3])
- Ignore markdown files in the Docker build context ([291a0b7])
- Add a CI workflow that builds the CPU xenoncat solver and a PR hygiene
  workflow, both targeting the zebra-mining branch ([3f60289], [#1])
- Add hadolint Dockerfile linting ([fdfa532], [#2])
- Add shellcheck linting for shell scripts ([e94d0e0], [#3])

### Changed

- Run the Docker container as a non-root user ([369cf0d])
- Pin all apt package versions in the Dockerfile (hadolint DL3008)
  ([fdfa532], [#2])

### Fixed

- Quote the nproc command substitution in the Dockerfile build step
  (hadolint SC2046) ([fdfa532], [#2])
- Add a shebang and `set -euo pipefail` to
  cpu_xenoncat/asm_linux/assemble.sh (shellcheck SC2148) ([e94d0e0],
  [#3])

<!-- Commit links -->

[68bdb13]: https://github.com/dannywillems/nheqminer/commit/68bdb13
[ec49af3]: https://github.com/dannywillems/nheqminer/commit/ec49af3
[291a0b7]: https://github.com/dannywillems/nheqminer/commit/291a0b7
[369cf0d]: https://github.com/dannywillems/nheqminer/commit/369cf0d
[3f60289]: https://github.com/dannywillems/nheqminer/commit/3f60289
[fdfa532]: https://github.com/dannywillems/nheqminer/commit/fdfa532
[e94d0e0]: https://github.com/dannywillems/nheqminer/commit/e94d0e0

<!-- PR links -->

[#1]: https://github.com/dannywillems/nheqminer/pull/1
[#2]: https://github.com/dannywillems/nheqminer/pull/2
[#3]: https://github.com/dannywillems/nheqminer/pull/3
