
# What we can reuse vs. what we must write

| Area                             | Reuse (battle-tested Rust libs)                                                                                                                     | What we still need to build (Ecliptica-specific)                                                                                                                                                                               |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **P2P & transport**              | **rust-libp2p / gossipsub** for pub/sub gossip; **quinn** for QUIC transport. ([docs.rs][1])                                                        | P2P wiring for shard/beacon topologies, message types, backpressure & QoS; gossip topics for DAG blocks/headers; QUIC session tuning for validators.                                                                           |
| **Post-quantum crypto**          | **pqcrypto** (PQClean bindings) for ML-KEM/ML-DSA/SPHINCS+; **liboqs-rust** for OQS backends (optional perf path). ([crates.io][2])                 | Deterministic-encapsulation adapter for ML-KEM RNG; key‐envelope formats; rotation/migration logic; PQ VRF replacement (or beacon-driven randomness).                                                                          |
| **Merkle / SMT**                 | **rs-merkle**, **Nervos sparse-merkle-tree**, other SMT crates. ([docs.rs][3])                                                                      | Ecliptica state schema; proofs for encrypted notes; cross-shard receipt proofs; pruning/snapshot strategy.                                                                                                                     |
| **Erasure coding / DA sampling** | **reed-solomon-erasure** / RaptorQ-style crates (ecosystem exists); Merkle commitments with **rs-merkle**. ([docs.rs][3])                           | DA network protocol (sampling rules, chunk markets), shard header commitments, light-client sampling logic.                                                                                                                    |
| **ZK/STARKs**                    | **Winterfell** (STARK prover/verifier, `no_std`-friendly); **RISC Zero zkVM** (STARK-based zkVM with recursion). ([GitHub][4])                      | Our encrypted-ledger constraint system; per-epoch shard proofs; **recursive aggregation** across shards (if using Winterfell, we implement recursion or call into RISC-Zero’s recursion layer); proof-posting protocol & fees. |
| **Consensus building blocks**    | Open-source HotStuff-style frameworks exist (e.g., research code); libp2p + QUIC give comms; but **no off-the-shelf ShardBFT + DAG** turnkey stack. | **ShardBFT** (HotStuff-derived) with leader rotation & timeouts; **DAG mempool** (Narwhal/Bullshark-like) for throughput; vote certificates, timeouts, view-change; beacon finality chain.                                     |
| **Beacon / finality**            | —                                                                                                                                                   | Beacon chain logic; verification of shard proofs; **recursive STARK** builder to emit the Ecliptica Finality Proof (EFP); validator-set commitments.                                                                           |
| **Wallet / viewing keys**        | SHA3/SHAKE crates; pqcrypto KEM/sigs. ([crates.io][2])                                                                                              | **HD Viewing-Key (LWE-PRF) tree**, deterministic KEM RNG, selective-disclosure formats, encrypted staking receipts.                                                                                                            |
| **Storage**                      | **RocksDB** / **Parity-DB** bindings are mature in Rust.                                                                                            | State manager (versions/snapshots), compaction & cold-storage, archival/export tools.                                                                                                                                          |
| **RPC / APIs**                   | **axum**/**tower** for HTTP/WS; **libp2p** for p2p RPC; protobuf via **prost**.                                                                     | Canonical binary serialization; proof/receipt APIs; light-client endpoints; cross-shard bridge APIs.                                                                                                                           |
| **WASM runtime**                 | **wasmtime** for contract VM; deterministic configs are well-trodden.                                                                               | Contract SDK (CosmWasm-like), gas metering, host/syscall surface, capability model.                                                                                                                                            |
| **Light client**                 | Winterfell and RISC Zero verifiers in Rust (client-side), Dilithium verify via pqcrypto/liboqs. ([lib.rs][5])                                       | **no\_std** mobile verifier that checks EFP + committee certs + DA samples; packaging for iOS/Android.                                                                                                                         |

---

## What this means in practice

### We can lean on:

* **Networking:** `libp2p_gossipsub` for pubsub and **Quinn** for QUIC transport. These are production-proven and actively maintained. ([docs.rs][1])
* **PQ crypto:** **pqcrypto** (PQClean) for Kyber/Dilithium/SPHINCS+, or **liboqs-rust** for a perf-oriented backend. Both track NIST PQC. ([crates.io][2])
* **Proof systems:** **Winterfell** for STARK circuits and a lightweight verifier; or **RISC Zero** if you prefer a zkVM with **built-in recursion** and a well-documented verifier path. ([GitHub][4])
* **State commitments:** **rs-merkle** and **Nervos SMT** give robust trees and proofs today. ([docs.rs][3])

### We’ll still need to author:

1. **ShardBFT + DAG mempool** (ordering + fast-path HotStuff) — no turnkey Rust crate exists that matches our exact privacy+shard requirements.
2. **Encrypted-ledger ZK circuits** — to prove range/nonce/consistency over **encrypted** notes/commitments.
3. **Recursive finality (EFP)** — aggregate all shard proofs into one succinct proof each epoch (either via custom Winterfell recursion or by orchestrating RISC Zero recursion with a compact header format). ([GitHub][4])
4. **HD Viewing-Key stack (LWE-PRF)** and **deterministic ML-KEM encapsulation** adapter.
5. **DA protocol** (erasure coding + sampling rules) and fees.
6. **Light-client SDK** (no\_std) that verifies EFP + Dilithium committee certs and performs DA sampling efficiently on mobile.

---

## Suggested “buy vs build” for v0 → v1

* **v0 (prototype):**

  * P2P = libp2p/gossipsub; transport = Quinn. ([docs.rs][1])
  * PQ = pqcrypto (portable) first; keep **liboqs** behind a feature flag. ([crates.io][2])
  * ZK = start with **Winterfell** circuits + verifier; use RISC Zero only for recursion experiments. ([GitHub][4])
  * SMT = Nervos sparse-merkle-tree + rs-merkle for simple commitments. ([GitHub][6])

* **v1 (testnet):**

  * Implement ShardBFT + DAG mempool.
  * Ship per-epoch STARK proofs and a **beacon verifier** that accepts either: (a) recursive Winterfell proof, or (b) RISC Zero receipt. ([GitHub][4])
  * Release light-client SDK (`no_std`) verifying EFP + Dilithium certs.

---

## Handy links (for your engineers)

* libp2p gossipsub docs & crate: ([docs.rs][1])
* Quinn (QUIC) docs & repo: ([docs.rs][7])
* pqcrypto (PQClean bindings) & PQClean project: ([crates.io][2])
* liboqs-rust (OQS bindings): ([GitHub][8])
* Winterfell (STARK prover/verifier): ([GitHub][4])
* RISC Zero zkVM (STARK-based, recursion): ([docs.rs][9])
* Nervos sparse-merkle-tree & rs-merkle: ([GitHub][6])

---

### Bottom line

We can **stand on solid Rust shoulders** for networking, PQ crypto, Merkle/SMT, and STARK tooling. The **core innovation we must author** is the Ecliptica-specific layer: **ShardBFT + DAG**, **encrypted-ledger ZK circuits**, **recursive finality (EFP)**, and the **HD viewing-key**/deterministic-KEM plumbing that powers privacy.


[1]: https://docs.rs/libp2p-gossipsub/latest/libp2p_gossipsub/?utm_source=chatgpt.com "libp2p_gossipsub - Rust"
[2]: https://crates.io/crates/pqcrypto?utm_source=chatgpt.com "pqcrypto - Post-Quantum cryptographic algorithms"
[3]: https://docs.rs/rs_merkle/?utm_source=chatgpt.com "rs_merkle - Rust"
[4]: https://github.com/facebook/winterfell?utm_source=chatgpt.com "facebook/winterfell: A STARK prover and verifier ..."
[5]: https://lib.rs/crates/winterfell?utm_source=chatgpt.com "Winterfell — unregulated finances, in Rust // ..."
[6]: https://github.com/nervosnetwork/sparse-merkle-tree?utm_source=chatgpt.com "nervosnetwork/sparse-merkle-tree"
[7]: https://docs.rs/quinn/latest/quinn/?utm_source=chatgpt.com "quinn - Rust"
[8]: https://github.com/open-quantum-safe/liboqs-rust?utm_source=chatgpt.com "open-quantum-safe/liboqs-rust: Rust bindings for liboqs"
[9]: https://docs.rs/risc0-zkvm/?utm_source=chatgpt.com "risc0_zkvm - Rust"
