
## 🧩 1. Basic Formula — Byzantine Fault Tolerance

Ecliptica’s consensus (ShardBFT) inherits from **HotStuff / Tendermint**, which follows the **classical BFT model**:

$$
N \ge 3f + 1
$$

where:

* $N$ = number of validators in a committee,
* $f$ = maximum number of Byzantine (malicious or offline) nodes tolerated.

This ensures:

* **Safety** (no two conflicting blocks can both finalize) even if ≤ f nodes are faulty,
* **Liveness** (the chain continues) when ≥ 2f + 1 honest nodes are online.

---

## ⚙️ 2. Minimum Operational Configuration (Single-Shard Prototype)

For early-stage deployment or testnet:

| Parameter                | Symbol | Minimum Value | Rationale                                                  |
| ------------------------ | ------ | ------------- | ---------------------------------------------------------- |
| Validator committee size | N      | **4 nodes**   | The absolute minimum (3f + 1 with f = 1)                   |
| Fault tolerance          | f      | 1 faulty node | Allows 1 crash or malicious node without halting the chain |
| Honest quorum            | 2f + 1 | 3 nodes       | Needed for finality votes                                  |
| zk-Prover node(s)        | —      | 1–2           | Optional off-chain workers generating STARKs               |
| Beacon / aggregator      | —      | 1             | Can initially coincide with a validator                    |
| Total operational nodes  | —      | **≈ 5–7**     | For functional devnet                                      |

➡️ **Absolute minimum viable network: 4 validators + 1 beacon = 5 nodes.**
However, this configuration offers **zero redundancy** and should only be used for internal or developer testnets.

---

## 🪶 3. Recommended Secure Launch Configuration (Mainnet Alpha)

For a public, fault-tolerant environment:

| Role                   | Count        | Purpose                               |
| ---------------------- | ------------ | ------------------------------------- |
| **Shard validators**   | 32 per shard | f = 10 → tolerates 10 Byzantine nodes |
| **Beacon validators**  | 64           | f = 21 → strong global finality       |
| **zk-Provers**         | 5–10         | Decentralized STARK generation        |
| **Full archive nodes** | ≥ 5          | Data availability, snapshots          |
| **Light clients**      | Unlimited    | Mobile verifiers, wallets             |

**Total minimum network (single shard):** \~50 operational nodes.
This ensures:

* Safety and liveness under realistic network churn.
* Resilience to regional outages.
* Redundant zk-proof generation.

---

## 🌌 4. Scaling with Shards

If Ecliptica starts with *S* shards, total validator count is:

$$
N_{\text{total}} = S \times N_{\text{shard}} + N_{\text{beacon}}
$$

| Shards | Shard Committee | Beacon | Total Nodes | Fault Tolerance (per shard) |
| ------ | --------------- | ------ | ----------- | --------------------------- |
| 1      | 32              | 64     | **96**      | f = 10                      |
| 4      | 32              | 64     | **192**     | f = 10                      |
| 8      | 64              | 96     | **608**     | f = 21                      |

This model scales linearly with shards but keeps **finality centralized** through a small beacon set that verifies all shard proofs.

---

## 🔐 5. zk-Proof & DA Considerations

Even though zk-proof generation and data-availability (DAS) nodes can be off-chain, the blockchain itself must have **at least one proof verifier per shard** online.
Thus, for a minimally verifiable shard:

* 4 validators (BFT),
* 1 zk-proof verifier,
* 1 aggregator for beacon relay.

→ 6 nodes is the **mathematical floor** for consensus + proof integrity.

---

## ✅ 6. Practical Recommendation

| Stage              | Nodes   | Configuration                          | Purpose                             |
| ------------------ | ------- | -------------------------------------- | ----------------------------------- |
| **Devnet**         | 5–7     | 4 validators + beacon + prover         | Rapid iteration, functional testing |
| **Testnet**        | 16–24   | 8–12 validators + beacon + 2–3 provers | Public experimentation              |
| **Mainnet Beta**   | 64–100  | Multiple committees, 2–3 shards        | Economic & security realism         |
| **Mature Mainnet** | 192–512 | 8+ shards, zk-proof markets            | Fully decentralized                 |

---

### 🧠 Summary

| Layer           | Min Operational Nodes    | Secure Launch Nodes       |
| --------------- | ------------------------ | ------------------------- |
| Shard Consensus | 4                        | 32                        |
| Beacon Chain    | 1                        | 64                        |
| zk-Proof Layer  | 1                        | 5–10                      |
| **Total**       | **≈ 5–7** (absolute min) | **≈ 100+** (secure start) |

---

> **In short:**
> • Ecliptica *can* run with 5 nodes (devnet),
> • It becomes *securely decentralized* at \~100 nodes,
> • It scales linearly with shard count thereafter.


