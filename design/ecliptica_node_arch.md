

# ⚙️ **Ecliptica Node Architecture & Consensus Specification Sheet**

### *Version 0.1 – Draft / October 2025*

---

## 🪐 1. Overview

Ecliptica’s blockchain operates under a **ShardBFT + zk-Finality** model — a post-quantum, privacy-preserving consensus that supports high throughput, sharded scalability, and succinct validation across heterogeneous devices.

Each operational network is composed of **shards**, a **beacon chain**, and an optional **zk-proof computation layer**.

---

## 🧩 2. Node Roles

| Role                                | Description                                                                      | Consensus Layer    | Key Cryptography         | Participation Type          |
| ----------------------------------- | -------------------------------------------------------------------------------- | ------------------ | ------------------------ | --------------------------- |
| **Validator (Shard)**               | Executes transactions, maintains local state, participates in BFT consensus.     | ShardBFT           | ML-DSA (Dilithium)       | Active                      |
| **Beacon Validator**                | Aggregates shard certificates, verifies STARK proofs, maintains global finality. | zk-Finality        | ML-DSA (Dilithium-3)     | Active                      |
| **zk-Prover Node**                  | Generates zk-STARK proofs for shard state transitions and recursive aggregation. | Off-chain compute  | SHAKE-256 / Rescue-Prime | Incentivized (Proof Market) |
| **Data Availability Node (DAN)**    | Stores erasure-coded shards of data; participates in random sampling.            | Data Layer         | SHA-3 / Merkle           | Passive                     |
| **Light Validator / Mobile Client** | Verifies zk-proofs and committee certificates without maintaining state.         | Verification Layer | ML-DSA verify only       | Passive                     |

---

## 🔢 3. Quorum and Threshold Parameters

Ecliptica follows the classical **Byzantine Fault Tolerance rule**:

$$
N \ge 3f + 1
$$

where

* `N` = total validators in committee
* `f` = maximum tolerated faulty nodes

### 3.1 Quorum Requirements

| Parameter                 | Symbol | Formula       | Example (N = 32) | Description                                   |
| ------------------------- | ------ | ------------- | ---------------- | --------------------------------------------- |
| **Fault tolerance**       | f      | ⌊(N−1)/3⌋     | 10               | Number of nodes that can be malicious/offline |
| **Precommit quorum**      | q₁     | 2f + 1        | 21               | Required votes to advance proposal            |
| **Finality quorum**       | q₂     | 2f + 1        | 21               | Commit certificate threshold                  |
| **Aggregate certificate** | q₃     | ≥⅔ validators | 22               | For beacon aggregation proof inclusion        |

### 3.2 Consensus Pipeline (Per Shard)

1. **Proposal Phase:** Leader proposes block header referencing DAG transactions.
2. **Vote Phase:** Validators broadcast `Prepare` votes.
3. **Commit Phase:** Upon `2f + 1` votes, block becomes finalized.
4. **Epoch Proof:** zk-Prover generates STARK proof attesting to valid state transition.
5. **Beacon Aggregation:** Beacon chain aggregates shard proofs → recursive zk-proof → global finality.

---

## 🧠 4. Security & Fault Tolerance

| Property                  | Guarantee                                    | Mechanism                                 |
| ------------------------- | -------------------------------------------- | ----------------------------------------- |
| **Safety**                | No two conflicting blocks finalize           | Classical BFT with ML-DSA signatures      |
| **Liveness**              | Chain progresses under partial synchrony     | Round-robin leader rotation + DAG mempool |
| **Byzantine Resilience**  | Up to f malicious nodes per shard            | 3f + 1 validator rule                     |
| **Privacy Preservation**  | Validators see only encrypted commitments    | ML-KEM + zk-STARK proofs                  |
| **Post-Quantum Security** | Resistant to Shor’s and Grover’s attacks     | ML-DSA + ML-KEM + hash-based STARKs       |
| **Finality Proofs**       | Global proof of correctness                  | Recursive zk-STARK over all shards        |
| **Slashing**              | Double signing, equivocation, or proof fraud | On-chain penalty via beacon governance    |

---

## 🧱 5. Minimum Operational Configuration

| Layer               | Role Composition   | Node Count    | Notes                           |
| ------------------- | ------------------ | ------------- | ------------------------------- |
| **Shard Consensus** | 4 validators (f=1) | **4**         | Absolute minimum (3f+1)         |
| **Beacon Chain**    | 1 node             | **1**         | Can coincide with validator     |
| **zk-Prover**       | 1 node             | **1**         | Optional in devnet (mock proof) |
| **Total (devnet)**  | —                  | **5–7 nodes** | Functional prototype            |

> ⚠️ *This configuration provides functionality but not resilience. It should only be used for local development or testing.*

---

## 🏗️ 6. Recommended Secure Launch Configuration

| Role                      | Count | Purpose                                |
| ------------------------- | ----- | -------------------------------------- |
| **Shard Validators**      | 32    | f = 10; resilient to regional downtime |
| **Beacon Validators**     | 64    | f = 21; ensures deterministic finality |
| **zk-Provers**            | 5–10  | Decentralized proof market             |
| **DA Nodes**              | ≥ 5   | Erasure-coded data availability        |
| **Full Nodes / Indexers** | 5–10  | Archival, RPC, analytics               |

> **Minimum Secure Launch Total:** ≈ 100 operational nodes
> **Fault tolerance:** up to 31 malicious actors across system (shard + beacon).

---

## ⚡ 7. Scaling with Shards

| Shards | Validators per Shard | Beacon Validators | Total Validators | Fault Tolerance (per Shard) |
| ------ | -------------------- | ----------------- | ---------------- | --------------------------- |
| 1      | 32                   | 64                | 96               | f = 10                      |
| 4      | 32                   | 64                | 192              | f = 10                      |
| 8      | 64                   | 96                | 608              | f = 21                      |

The **beacon chain** serves as a shared security root for all shards, verifying their zk-proofs and maintaining recursive global finality.

---

## 🔐 8. Light Validator Path

Mobile clients and IoT nodes act as **verifiable observers**:

1. Download latest **Ecliptica Finality Proof (EFP)**
2. Verify recursive zk-STARK and beacon committee signature
3. Optionally sample data for Data Availability Sampling (DAS)
4. Maintain latest state root commitment

**Verification cost:**

* zk-STARK verify < 0.3 s on mobile CPU
* Dilithium cert verify < 5 ms
* Bandwidth < 1 MB per epoch

Thus any device can fully validate Ecliptica’s correctness — *without full node synchronization*.

---

## 🧮 9. Consensus Timing Targets

| Parameter                | Symbol | Target                                     |
| ------------------------ | ------ | ------------------------------------------ |
| Block interval           | Δb     | 250–500 ms                                 |
| Epoch length             | Δe     | 1–2 s                                      |
| Average finality latency | Lf     | <150 ms (optimistic), <400 ms (worst case) |
| zk-Proof generation      | Δp     | 2–4 s (per shard)                          |
| zk-Proof verification    | Vp     | <300 ms (beacon layer)                     |

---

## 🧱 10. Security Summary

| Category                | Metric                   | Value                                 |
| ----------------------- | ------------------------ | ------------------------------------- |
| Byzantine tolerance     | f/N                      | 33 %                                  |
| Minimum quorum          | 2f + 1                   | ≥ 67 %                                |
| Signature type          | ML-DSA (Dilithium)       | PQ-safe                               |
| KEM / Encryption        | ML-KEM (Kyber)           | PQ-safe                               |
| Proof system            | zk-STARK                 | Transparent, no trusted setup         |
| Hash / KDF              | SHAKE-256 / Rescue-Prime | PQ-safe                               |
| Network fault tolerance | Partial synchrony        | Consensus stable under ≤1/3 Byzantine |

---

## 🚀 11. Bootstrapping Recommendations

| Stage              | Node Count | Use Case                           |
| ------------------ | ---------- | ---------------------------------- |
| **Devnet Alpha**   | 5–7        | Internal testing (mock proofs)     |
| **Public Testnet** | 16–24      | Validator testing, fee calibration |
| **Mainnet Beta**   | 64–100     | Secure decentralized operation     |
| **Mature Mainnet** | 192–512    | Multi-shard scaling + zk-markets   |

---

## 🧠 12. Design Philosophy

> “Ecliptica is designed for *universal verifiability* — every participant, from data center to mobile phone, can validate the truth of the ledger without revealing or trusting secrets.”

* Decentralization without computational exclusion.
* Security without reliance on elliptic curves.
* Proof-based verification instead of re-execution.

---

**Document ID:** `ECLIPT-TECHSPEC-001`
**Maintainer:** Ecliptica Research Consortium
**License:** CC-BY-SA-4.0

---


