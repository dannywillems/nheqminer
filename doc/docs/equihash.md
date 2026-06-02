---
sidebar_position: 1
title: Equihash
---

# Equihash

Equihash is a memory-hard proof-of-work function introduced by Biryukov and
Khovratovich in 2016. Zcash uses it as its mining algorithm. It is built on
the generalized birthday problem: finding it requires a large amount of
memory, while checking a found solution is cheap.

## Parameters

Equihash is parameterized by two integers, written $\text{Equihash}(n, k)$:

- $n$ is the bit length of the hash strings that are combined.
- $k$ is the number of XOR rounds; a solution combines $2^k$ strings.

Zcash uses $n = 200$ and $k = 9$.

A solver is given a header and generates a list of $N$ strings of $n$ bits
each:

$$
N = 2^{\,n/(k+1)\,+\,1}.
$$

Using Wagner's algorithm it must find $2^k$ distinct indices into that list
whose strings XOR to zero, with the round-by-round collision conditions that
bind the solution to the algorithm. Each round cancels

$$
\frac{n}{k+1} \text{ bits.}
$$

## Solution size

A solution is a list of $2^k$ indices. Each index is

$$
\frac{n}{k+1} + 1 \text{ bits wide.}
$$

For Zcash's $\text{Equihash}(200, 9)$:

- $2^9 = 512$ indices,
- each $\dfrac{200}{10} + 1 = 21$ bits wide,
- giving $512 \times 21 = 10752$ bits $= 1344$ bytes.

The 1344-byte solution is the value carried in the Zcash block header. This
miner produces exactly that.

## Why memory-hard

Wagner's algorithm holds the full list of roughly $N$ entries (about $2^{21}$
for Zcash) in memory and repeatedly sorts and merges it. Memory use is on the
order of the list size times the per-entry size, which is tens to a few
hundred MiB depending on how the solver is implemented. Optimized solvers
such as the xenoncat solver used here reduce the constant factors with
AVX/AVX2 code, but the memory-bound shape of the problem is fixed by $n$ and
$k$.

Verification is the opposite: given a candidate solution, a verifier only
recomputes the $2^k$ hashes and checks the XOR and ordering conditions, which
is fast and uses little memory.

## Difficulty

Equihash defines what a valid solution is, not how rare a block is. As in
Bitcoin, a separate difficulty target is applied: the block header together
with its Equihash solution must hash below the network target. A miner keeps
changing the nonce, solving Equihash, and checking the result against the
target until one is below it.

## References

- A. Biryukov and D. Khovratovich, "Equihash: Asymmetric Proof-of-Work
  Based on the Generalized Birthday Problem", NDSS 2016.
  https://www.internetsociety.org/sites/default/files/blogs-media/equihash-asymmetric-proof-of-work-based-generalized-birthday-problem.pdf
- Zcash Protocol Specification, Equihash section.
  https://zips.z.cash/protocol/protocol.pdf
