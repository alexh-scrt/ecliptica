
# Ecliptica Tech Stack

## 1) Language & Toolchain

* **Language:** Rust (stable)
* **MSRV:** 1.77+ (pin in `rust-toolchain.toml`)
* **Targets:** `x86_64-unknown-linux-gnu`, `aarch64-unknown-linux-gnu`
* **Build:** `cargo`, `cargo-nextest`, `cargo-deny`, `cargo-audit`, `cargo-udeps`
* **Sandboxing:** `wasmtime` for contract VM; `seccomp`/`cgroups` for node ops
* **Reproducibility:** Nix or Bazel build (pinning exact versions + SBOM)

> **Policy:** `#![forbid(unsafe_code)]` in consensus/state/VM; allow `unsafe` only in leaf crypto/FFI crates with audits.

---

## 2) Workspace & Project Layout

```
/ecliptica
  /node/            # P2P, mempool, consensus, RPC
  /state/           # SMT, state manager, snapshots, pruning
  /crypto/          # PQ KEM/sigs, PRF/KDF, hash, RNG adapters
  /zk/              # STARK prover/verifier + circuits
  /vm/              # WASM runtime, gas, host env
  /contracts/       # SDK + examples (Rust -> WASM)
  /storage/         # DB abstractions (RocksDB/ParityDB)
  /telemetry/       # metrics, tracing, logging, profiling hooks
  /tools/           # loadgen, network simulator, key tool, faucet
  /cli/             # ecliptica-cli wallet, key mgmt, tx builder
  /docs/            # specs, ADRs, threat models
```

---

## 3) Core Rust Crates (by domain)

### A. Runtime & Concurrency

* **Async:** `tokio` (single runtime across node)
* **Parallelism:** `rayon` (CPU-bound tasks, batch decap/verify), `crossbeam`
* **SIMD:** `std::simd` (stable) + optional `core::arch::*` (AVX2/AVX-512 feature flags)
* **Time:** `time`, `quanta` (monotonic), avoid `chrono` in consensus code

### B. Networking & RPC

* **P2P:** `libp2p` (GossipSub, identify, NAT traversal)
* **Transport:** QUIC (`quinn`) for validator/aggregator links
* **RPC:** `axum` + `tower` + `serde_json` (HTTP/WS for clients), optional gRPC (`tonic`) for internal services
* **Serialization:** `serde` + `bincode` (canonical), `rmp-serde` optional; define strict schema + versioning

### C. Storage & State

* **KV Store:** `rocksdb` (via `rust-rocksdb`) or `parity-db` (append-only, predictable)
* **State Accumulator:** Sparse Merkle Tree (custom crate) using `sha3`/`blake3`
* **Snapshotting:** `zstd` compression, content-addressable chunks
* **Schema:** `prost` (for durable on-disk schema evolution if needed)

### D. Post-Quantum Cryptography

* **Primary KEM:** ML-KEM (Kyber) via:

  * **Option 1 (portable):** `pqcrypto-kyber` (PQClean-backed)
  * **Option 2 (perf):** `oqs` / `oqs-sys` (Open Quantum Safe) with CPU-optimized backends
* **Signatures:** ML-DSA (Dilithium) via `pqcrypto-dilithium` or `oqs::sig`
* **Long-term anchor (optional):** `pqcrypto-sphincsplus`
* **Hashes/XOFs:** `sha3` (SHA3-256, SHAKE-256), `tiny-keccak`
* **KDF/PRF:** HKDF (SHAKE-256); LWE-PRF implemented as a crate within `/crypto/prf`
* **Deterministic Encapsulation Adapter:** custom module that seeds DRBG from domain-separated bytes → calls KEM encaps (keeps ciphertext format spec-compliant)
* **RNG:** `rand_chacha` (seeded, deterministic for consensus code)

> **Feature flags:** `pq_backend=pqclean|liboqs`, `simd=avx2|avx512|neon`.

### E. ZK (STARK stack)

* **Proof System:** `winterfell` or `miden-crypto` (STARKs)
* **ZK Hash:** Rescue-Prime (in-circuit) + Poseidon optional; out-of-circuit use SHAKE-256
* **Field/Math:** `ark-ff`, `ark-poly` (only in zk domain)
* **Circuit DSL:** internal builders (keep dependencies lean)
* **Parallel Proving:** `rayon` + NUMA-aware worker pools

### F. VM & Smart Contracts

* **WASM Runtime:** `wasmtime` (deterministic config; disable floating point or gate it out of consensus)
* **Contract SDK:** Rust-to-WASM (like CosmWasm ergonomics), macros for message encoding + gas accounting
* **Gas & Metering:** host functions gated; deterministic memory limits; no syscalls
* **ABI:** Protobuf/JSON for external calls; binary canon for on-chain

### G. Consensus & Mempool

* **Consensus:** Sharded optimistic-BFT (custom) built on:

  * `consensus-core` crate with deterministic timers, leader rotation
  * `ed25519-dalek` only for non-critical tools; **consensus uses ML-DSA**
* **Mempool:** priority + fairness queues; `dashmap` for concurrent indexing
* **Cross-shard:** SMT commitments + light proofs (binary canonical format)

---

## 4) Observability, Ops & Security

### A. Telemetry & Tracing

* **Logging:** `tracing`, `tracing-subscriber`, JSON logs
* **Metrics:** `metrics` + `metrics-exporter-prometheus`
* **Profiling:** `pprof` (integrated), `inferno` flamegraphs, Linux `perf` markers
* **Health:** `/metrics`, `/status`, `/readyz` via `axum`

### B. Security Tooling

* **Audits:** `cargo-audit`, `cargo-deny`, `cargo-geiger` (unsafe hotspot scan)
* **Fuzzing:** `cargo-fuzz` (AFL++/libFuzzer targets for tx parser, SMT, KEM adapters)
* **Property tests:** `proptest` (state transitions, serialization invariants)
* **Sanitizers:** Miri, ASAN/TSAN in CI (nightly jobs)
* **Supply chain:** `cosign` attestations, SBOM via `cargo-auditable`, SLSA provenance
* **Key storage:** HSM/KMS adapters (YubiHSM2/PKCS#11; softHSM for dev)

---

## 5) CI/CD & Release Engineering

* **CI:** GitHub Actions (matrix: x86\_64, aarch64; Linux; SIMD feature flags)
* **Steps:** fmt → clippy (deny warnings) → tests → nextest → fuzz smoke → audit/deny → docs build
* **Repro builds:** Nix/Bazel job; compare artifact hashes; store SBOMs
* **Artifacts:** deb/rpm tarballs, Docker images (`distroless`, `musl` optional)
* **Release gates:** perf regression budget (criterion), consensus reproducibility check, KAT (known answer tests) for PQ KEM/sigs

---

## 6) Determinism & Canonicalization Policies

* **No floating point** in consensus path; fixed-width ints only
* **Canonical serialization:** little-endian, versioned envelopes, strict length checks
* **RNG determinism:** domain-separated seeds; no OS randomness in consensus
* **Time:** use block heights & logical clocks instead of wall-clock
* **Schema evolution:** protobuf with explicit field IDs; migration tools

---

## 7) Developer Experience

* **Scaffolding:** `cargo-generate` templates for modules, contracts, and ZK gadgets
* **Localnet:** docker-compose with multi-shard topology + grafana/prometheus
* **Fixtures:** deterministic key/chain seeds; golden files for encodings
* **Docs:** `mdbook` for specs + ADRs; `mermaid` diagrams; rustdoc strict
* **Linting:** `clippy` pedantic, `taplo` for TOML, `typos` for repo

---

## 8) Default Versions & Flags (pin early; bump via RFCs)

* Rust: `1.77` (MSRV), toolchain pinned
* `tokio=1.*`, `axum=0.7.*`, `libp2p=0.53.*`
* `rocksdb=0.22.*` or `parity-db=0.5.*`
* `sha3=0.10.*`, `tiny-keccak=2.*`, `rand_chacha=0.3.*`
* `pqcrypto-kyber`, `pqcrypto-dilithium`, `pqcrypto-sphincsplus` **or** `oqs` (feature-gated)
* `winterfell` (latest compatible), `rayon=1.*`
* `tracing=0.1.*`, `metrics=0.22.*`, `metrics-exporter-prometheus=0.13.*`

> Use a `Cargo.lock` checked in; enable `-Z minimal-versions` CI job to detect over-wide semvers.

---

## 9) Sample `Cargo.toml` (workspace root)

```toml
[workspace]
members = [
  "node", "state", "crypto", "zk", "vm",
  "contracts/sdk", "storage", "telemetry", "cli", "tools/*"
]
resolver = "2"

[workspace.package]
edition = "2021"
rust-version = "1.77"

[workspace.metadata.cargo-udeps.ignore]
# list proc-macros or build deps that appear unused but are required

[workspace.dependencies]
serde = { version = "1", features = ["derive"] }
bincode = "1"
sha3 = "0.10"
tiny-keccak = "2"
rand = "0.8"
rand_chacha = "0.3"
tracing = "0.1"
anyhow = "1"
thiserror = "1"
```

---

## 10) Feature Flags (centralized)

* `pq_backend` = `{ "pqclean", "liboqs" }` (default: `pqclean`)
* `simd` = `{ "avx2", "avx512", "neon", "portable" }` (auto-detect + override)
* `zk_fast` (enables larger memory/threads for prover)
* `contracts` (enable WASM VM + SDK)
* `telemetry` (builds metrics/tracing exporters)
* `strict` (enforces forbid-unsafe, no\_std subsets where possible)

---

### Why this stack?

* **Rust everywhere** → performance + memory safety for consensus-critical code.
* **PQ via PQClean/LibOQS** → standards-aligned, test-vectored, and portable with a perf path.
* **Determinism baked in** → reproducible consensus across heterogeneous validators.
* **ZK STARK path** → transparent proofs, parallel-friendly, hash-centric (Rescue-Prime).
* **Operational maturity** → tracing, metrics, fuzzing, SBOMs, and supply-chain hygiene from day one.

