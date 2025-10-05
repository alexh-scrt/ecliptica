
# 🪐 **Ecliptica Consensus Protocol**

### *ShardBFT + DAG + zk-Finality for Post-Quantum, Privacy-Preserving Scalability*

> *“In the orbit of Ecliptica, light and shadow find balance —
> where every node, even the smallest device, can validate truth without unveiling secrets.”*

---

## 1. Executive Summary

Ecliptica introduces a **post-quantum, privacy-preserving, high-throughput consensus architecture** that allows **any device — even a mobile phone — to act as a light validator**.
This is achieved through a combination of:

* **Sharded BFT consensus** for parallel scalability,
* **DAG-based mempool** for throughput and low latency,
* **zk-STARK finality proofs** for succinct, post-quantum verifiable state transitions.

The resulting consensus mechanism — **ShardBFT with zk-Finality** — guarantees **deterministic finality, quantum resilience, and privacy by design**, forming the cryptographic and computational backbone of the Ecliptica blockchain.

---

## 2. Design Goals

| Goal                        | Description                                                                                                    |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Post-Quantum Security**   | All consensus messages and signatures are based on NIST-approved PQ algorithms (ML-DSA, ML-KEM).               |
| **Privacy Preservation**    | Consensus verifies encrypted transactions and zero-knowledge proofs — validators never see plaintext state.    |
| **High Throughput**         | Decoupled DAG architecture enables parallel transaction processing across shards (>50,000 TPS).                |
| **Instant Finality**        | Each shard reaches sub-second finality; the beacon chain recursively aggregates zk-proofs for global finality. |
| **Universal Participation** | Phones and low-resource devices can act as light validators by verifying succinct zk-proofs and certificates.  |
| **Modular Scalability**     | Independent shards with cross-shard atomic commits verified by zk aggregation.                                 |

---

## 3. Consensus Overview

### 3.1 Core Architecture

Ecliptica’s consensus is composed of three layers:

| Layer                 | Function                                                     | Consensus Mechanism              |
| --------------------- | ------------------------------------------------------------ | -------------------------------- |
| **Shard Layer**       | Executes encrypted transactions; achieves local BFT finality | **ShardBFT** (HotStuff-derived)  |
| **Aggregation Layer** | Builds zk-STARK proofs for each shard’s state transition     | **Permissionless STARK Provers** |
| **Beacon Layer**      | Aggregates shard proofs and validator certificates           | **Recursive zk-STARK Finality**  |

Each shard produces deterministic blocks ordered by a DAG-style mempool, reaches BFT finality within 150ms, and emits an **epoch STARK proof** of valid state transition.
The **beacon chain** then merges these shard proofs into a single **recursive proof**, forming the **Ecliptica Finality Proof (EFP)** — a compact, globally verifiable representation of system state.

---

## 4. ShardBFT: Deterministic Low-Latency BFT

### 4.1 Protocol Model

* Derived from **HotStuff / Tendermint** class protocols.
* Safety and liveness under standard 3f+1 Byzantine fault tolerance model.
* Leader rotation on each round via verifiable random function (VRF).
* Voting and commit certificates signed using **ML-DSA (Dilithium)** signatures.

### 4.2 Enhancements

* **DAG Mempool (Narwhal/Bullshark-inspired)** decouples transaction dissemination from consensus ordering.
* **Parallel block proposal**: multiple proposers can submit headers referencing the same transaction DAG.
* **Optimistic Fast Path:** if quorum precommits are collected early, shard finality occurs in one round trip.
* **Timeout recovery:** fallback to 2-round HotStuff if latency or equivocation occurs.

### 4.3 Performance Targets

| Parameter                | Value                                 |
| ------------------------ | ------------------------------------- |
| Validator Committee Size | 96 per shard                          |
| Fault Tolerance          | f = 31 Byzantine nodes                |
| Block Interval           | 250–500 ms                            |
| Finality Latency         | <150 ms (optimistic), <400 ms (worst) |
| Throughput               | \~4,000–8,000 TPS per shard           |
| Shards                   | 8–16 (scalable)                       |

---

## 5. zk-Finality: Zero-Knowledge Aggregation of Validity

### 5.1 Per-Shard Proofs

Each shard generates a zk-STARK proof at the end of every epoch (e.g., 1 second).
This proof attests that:

1. All included transactions are valid under Ecliptica’s encrypted-state rules.
2. No double-spend or invalid state transitions occurred.
3. The resulting Merkle root of the shard’s state tree is consistent with the previous epoch.
4. The data-availability commitments match the on-chain commitments in the DAG.

### 5.2 Recursive Aggregation

* The **Beacon Chain** receives each shard’s `(epoch_certificate, zk_STARK_proof)`.
* It verifies each proof locally and builds a **recursive STARK** that compresses all shard proofs into a single global proof — the **Ecliptica Finality Proof (EFP)**.
* Once the EFP is broadcast, all shards and light clients accept the aggregated epoch as finalized.

---

## 6. Light Validators: Universal Verification

Light validators — including **mobile devices** — can verify network correctness without storing or executing full state.

**Verification steps per epoch:**

1. Download latest **Ecliptica Finality Proof (EFP)** (\~50–100 KB).
2. Verify the recursive zk-STARK (PQ-safe hash-based).
3. Verify the beacon chain committee certificate (ML-DSA aggregate signature).
4. Sample a few erasure-coded data chunks for Data Availability Sampling (DAS).

**No transaction replay, no plaintext access, no heavy computation required.**

Estimated cost on a modern smartphone (A15/ARMv9):

* STARK verification: \~0.3s
* Signature verification: <5ms
* DAS sampling: <1MB bandwidth

This enables **real proof-of-correctness on mobile**, fulfilling the principle of *universal verifiability*.

---

## 7. Privacy Integration

Ecliptica achieves privacy without breaking consensus integrity:

| Layer                 | Privacy Mechanism                  | Description                                           |
| --------------------- | ---------------------------------- | ----------------------------------------------------- |
| **Transaction Layer** | ML-KEM (Kyber) encrypted payloads  | Ensures encrypted inputs/outputs                      |
| **Execution Layer**   | zk-STARK constraint system         | Proves balance, nonce, range without revealing data   |
| **Viewing Layer**     | Deterministic LWE-PRF viewing keys | Enables selective decryption without leaking on-chain |
| **Consensus Layer**   | Verifies proofs only               | Validators never access or decrypt transaction data   |

The consensus layer therefore operates over **commitments and zero-knowledge proofs only** — ensuring full privacy compliance even under adversarial validator sets.

---

## 8. Post-Quantum Security Model

All cryptographic primitives are **PQ-safe** under NIST standardization:

| Function          | Algorithm               | Source                  |
| ----------------- | ----------------------- | ----------------------- |
| Signatures        | ML-DSA (Dilithium)      | FIPS 204                |
| Key Encapsulation | ML-KEM (Kyber)          | FIPS 203                |
| Hash / KDF        | SHAKE-256               | FIPS 202                |
| Long-term Anchors | SPHINCS+                | FIPS 205                |
| Proof System      | zk-STARK (Rescue-Prime) | Transparent, hash-based |

All signature verification and proof verification steps are constant-time and reproducible.
All randomness derives from **deterministic, domain-separated DRBGs**.

---

## 9. Data Availability Layer

* **Erasure-coded chunks** per block header (Reed-Solomon or RaptorQ).
* **Merkle commitments** ensure tamper-evident inclusion.
* **Light DAS**: clients verify random samples to detect withholding.
* **PQ-safe design**: no KZG or elliptic-curve-based commitments used.

---

## 10. Cross-Shard Atomic Commit

Ecliptica uses a **two-phase commit protocol** across shards:

1. Transaction output in Shard A emits a *commitment receipt*.
2. Shard B verifies inclusion proof + zk consistency proof.
3. Beacon chain finalizes both shards’ receipts atomically.

All receipts remain encrypted; only proofs and commitments are visible to validators.

---

## 11. Consensus Security Properties

| Property               | Guarantee                                                                  |
| ---------------------- | -------------------------------------------------------------------------- |
| **Safety**             | Deterministic BFT ensures no two conflicting blocks can both finalize.     |
| **Liveness**           | Leader rotation + DAG mempool avoids deadlocks under partial synchrony.    |
| **Accountability**     | Misbehavior (double-sign, equivocation) provable via Dilithium signatures. |
| **Privacy**            | State transitions proven via zk-STARKs; no plaintext leakage.              |
| **Verifiability**      | Recursive zk-STARK allows global proof verification on any device.         |
| **Quantum Resilience** | All crypto primitives selected for PQ security; no ECC reliance.           |

---

## 12. Implementation Plan

| Phase       | Milestone                    | Description                                                          |
| ----------- | ---------------------------- | -------------------------------------------------------------------- |
| **Phase 1** | **ShardBFT Core (Rust)**     | Implement HotStuff-like BFT with DAG mempool and ML-DSA signatures.  |
| **Phase 2** | **Encrypted Execution**      | Integrate Kyber-encrypted transaction flow and zk constraint system. |
| **Phase 3** | **zk-STARK Prover/Verifier** | Implement per-shard proof generation + beacon recursive aggregation. |
| **Phase 4** | **Light Validator SDK**      | Mobile SDK verifying recursive STARKs and certificates.              |
| **Phase 5** | **Testnet Genesis**          | Multi-shard deployment with mobile verification and public explorer. |

---

## 13. Naming and Branding

* **Protocol Name:** *Ecliptica Consensus*
* **Nickname:** *ShardBFT + zk-Finality*
* **Logo Concept:** Interlocking orbits with a luminous crescent — symbolizing parallel shards under a shared light of truth.

---

## 14. Conclusion

Ecliptica Consensus represents the next evolutionary stage of blockchain systems:

* **Scalable** like DAG-based ledgers,
* **Final and deterministic** like BFT,
* **Private** like Zcash,
* **Quantum-secure** like a post-2030 Internet backbone.

It achieves what no existing blockchain has unified:

> **Quantum-resilient finality, privacy-preserving validation, and global light-node verifiability.**

This protocol turns *validation* into a universal right —
from data centers to smartphones, every participant can verify the light of truth within the shadow of privacy.


