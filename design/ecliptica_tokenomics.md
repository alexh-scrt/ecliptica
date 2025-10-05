
# 🪙 **Ecliptica Tokenomics**

### *A Deflationary-Equilibrium Monetary System for a Post-Quantum, Privacy-Preserving L1*

**Version:** 0.1 (Draft)
**Date:** October 2025
**Chain:** Ecliptica Mainnet (ShardBFT + zk-Finality)
**Ticker:** `ECLIPT`

---

## 0) Executive Summary

* **Purpose.** Provide sustainable security for a **post-quantum, privacy-preserving**, sharded L1 while preserving long-term **scarcity**.
* **Model.** Soft-capped issuance with an exponential **decay to a 0.5% tail**, **EIP-1559-style burns**, and fee-funded zk proving.
* **Target equilibrium.** Net inflation ≈ **0% (or negative)** at steady usage, with validator/staker yields funded by **tail + fees**.
* **Design pillars.** PQ security (ML-DSA, ML-KEM, STARKs), **universal verifiability** (light clients), and **privacy by architecture**.

---

## 1) Monetary Base & Supply Policy

### 1.1 Genesis & Units

* **Genesis supply $S_0$:** `1,000,000,000 ECLIPT` (1.0B)
* **Smallest unit:** `lepton` = $10^{-9}$ ECLIPT (for fee precision)

### 1.2 Emission Schedule

We use a **decaying inflation** to a **tail**:

$$
I(t) = I_0\, e^{-k t} + I_{\text{tail}}
$$

* $I_0 = 3.5\%$ (initial annualized)
* $I_{\text{tail}} = 0.5\%$ (perpetual, maintenance)
* $k \approx 0.12$ (decay constant, tuned so 0.5% is reached ≈ year 20)

**Supply trajectory:**

$$
S(t) = S_0 \cdot \exp\!\left(\frac{I_0}{k}\big(1-e^{-k t}\big) + I_{\text{tail}} t\right)
$$

**Asymptote (without burns):** ≈ **1.30B ECLIPT**.
**With burns:** practical steady range **1.23–1.28B** depending on usage.

### 1.3 Burns (EIP-1559-style)

Base fee $f_b$ is **provably burned** at ratio $\beta$ of total fees:

$$
\text{Burn}(t) = \beta \cdot \text{Fees}(t),\quad \beta \in [0.3\%,\,0.7\%] \text{ (policy range)}
$$

**Effective inflation**:

$$
I_{\text{eff}}(t) = I(t) - \frac{\text{Burn}(t)}{S(t)}
$$

When $\text{Burn}(t)$ grows with usage, $I_{\text{eff}}(t)\le 0$ → **deflationary equilibrium**.

---

## 2) Fee Model & Cost Centers

### 2.1 Fee Types

| Fee                       | Description                      | Destination                              |
| ------------------------- | -------------------------------- | ---------------------------------------- |
| **Base fee**              | Congestion-priced inclusion fee  | **Burn** (β)                             |
| **Priority tip**          | Goes to shard validators         | Validators                               |
| **zk proof fee**          | Pays for per-epoch STARK proving | **zk-Prover market** (off-chain compute) |
| **Cross-shard fee**       | For atomic cross-shard commits   | Shard validators (both sides)            |
| **Bridge/settlement fee** | L2/L1 settlements, receipts      | Beacon validators                        |

**Policy:** zk-provers are paid **from fees, not inflation** (keeps issuance simple and predictable).

---

## 3) Rewards & Distribution

### 3.1 Inflation Split (tail + decaying)

**Inflationary issuance per epoch** is split:

| Recipient                  | Share of issuance |
| -------------------------- | ----------------- |
| **Stakers (delegators)**   | **70%**           |
| **Validators (operators)** | **20%**           |
| **Treasury (protocol)**    | **10%**           |

> zk-provers **do not** receive inflation; they are paid from **zk-proof fees** (market-rate, competitive).

### 3.2 Validator Performance Coefficient

Rewards to each validator $i$:

$$
R_v(i) = \left(\frac{S_i}{\sum_j S_j}\right)\cdot R_v \cdot \phi_i
$$

* $S_i$: stake (self + delegated)
* $R_v$: validator share of issuance for the epoch
* $\phi_i \in [0,1]$: **performance coefficient** (uptime, latency, equivocation-free)

### 3.3 Staker Rewards (Delegation)

Stakers delegate to validators and receive proportional share of **staker pool** net of validator commission (policy-bounded, e.g., 0–10%).

### 3.4 Treasury

Protocol treasury gets **10%** of issuance for **R\&D, audits, grants, client diversity**, subject to on-chain governance with **spending caps and disclosures**.

---

## 4) Staking & Slashing Mechanics

### 4.1 Staking

* **Unbonding period:** 14 days (parameterized 7–21)
* **Minimum stake:** governance-set (e.g., 25k ECLIPT)
* **Commission:** validator-set within bounds (e.g., 0–10%)

### 4.2 Slashing

| Event            | Slash (principal) | Penalty detail               |
| ---------------- | ----------------- | ---------------------------- |
| **Double-sign**  | 1.0–5.0%          | Immediate, plus jailing      |
| **Downtime**     | 0.1–0.5%          | Thresholded by missed epochs |
| **Equivocation** | up to 5%          | Beacon evidence → on-chain   |

**Jailing:** temporary removal; **unbond freeze** during dispute window.
**Appeals:** on-chain governance process with evidence windows.

---

## 5) Consensus-Linked Economics

### 5.1 Security Budget & Staker APR

Assume stake ratio $\sigma = \frac{S_{\text{staked}}}{S}$.
Nominal **staker APR**:

$$
Y_{\text{staker}}(t) = \frac{0.7\,I(t)\,S(t)}{\sigma S(t)} + \frac{\text{FeeShare}_{\text{staker}}(t)}{\sigma S(t)} - \text{Dilution}(t)
$$

$$
= \frac{0.7\,I(t)}{\sigma} + \frac{\text{FeeShare}_{\text{staker}}(t)}{\sigma S(t)} - \text{Dilution}(t)
$$

* In early years with $I\approx 3.5\%$, $\sigma=0.6$ ⇒ $\frac{0.7\cdot 3.5\%}{0.6} \approx 4.08\%$ **before** fees/tips.
* With burns increasing over time, net APR tends to **2–4%** at equilibrium.

### 5.2 Economic Safety

Attack cost $C_{\text{attack}} \propto \sigma \cdot \text{MCAP}$.
Choose $\sigma$ targets (e.g., **≥60% staked**) via incentives (APR, fees) to ensure $C_{\text{attack}}$ ≫ expected gain.

---

## 6) Data Availability & zk Proving Markets

* **DA cost** is covered by base fees; **no KZG** → Merkle + erasure coding (PQ-safe).
* **Provers** bid to produce per-epoch **STARKs**; payment is from **zk-proof fees** assigned to the epoch.
* Market is **permissionless**, with **proof validity** enforced on-chain; late/invalid proofs forfeit fee escrow (slash-like economic penalty).

---

## 7) Treasury Policy

* **Inflows:** 10% of issuance + optional % of priority tips (configurable; default 0%).
* **Outflows:** Grants, audits, client diversity, zk research, critical infra.
* **Transparency:** Monthly report; addresses, outflows, runway.
* **Caps:** Yearly spend cap (e.g., ≤ 35% of treasury balance) unless DAO supermajority.

---

## 8) Allocation & Unlocks (Illustrative; to be confirmed)

| Category                 | % of Genesis | Lock/Cliff |               Vesting |
| ------------------------ | -----------: | ---------: | --------------------: |
| Public/Community Airdrop |          10% |        TGE |                     — |
| Ecosystem/Grants         |          15% |       6 mo |          36 mo linear |
| Core Contributors        |          15% |      12 mo |          36 mo linear |
| Strategic Partners       |          10% |       6 mo |          24 mo linear |
| Validators Bootstrap     |           5% |     0–3 mo |          12 mo linear |
| Treasury (protocol)      |          15% |        TGE | Governance-controlled |
| Liquidity/Market Making  |           5% |        TGE |          12 mo linear |
| **Circulating at TGE**   |      **25%** |          — |                     — |

> Final allocations subject to governance ratification and audit disclosure.

---

## 9) Governance

* **Scope-limited governance** may modify:
  $\{ I_{\text{tail}}\le 0.5\%,\, \beta \in [0.3\%,0.7\%],\, \text{split ratios},\, \text{unbonding},\, \text{commission bounds}\}$
* **Guardrails:** No authority to exceed published cap band (1.30B theoretical without burns).
* **Voting:** Token-weighted or quadratic with lockups; **2-chamber** (validators + tokenholders) recommended for economic changes.

---

## 10) Example Scenarios

### 10.1 Early Network (Year 1)

* $I \approx 3.5\%$, $\sigma=60\%$, fees modest, burns 0.3%.
* **Staker APR** (issuance only): $\approx 4.08\%$ before fees.
* **Effective inflation**: $3.5\% - \text{Burn}(t)/S(t) \approx 3.2\%$.

### 10.2 Maturity (Year 10)

* $I \approx 1.0\%$, burns 0.5–0.7%.
* **Effective inflation**: 0.3–0.5% or **≈0%** with higher usage.
* **Staker APR**: **2–3%** blended (issuance + fees).

### 10.3 Steady State (Year 20+)

* $I \to 0.5\%$ tail; robust burns.
* **Net inflation:** 0% or **deflation**.
* **Security:** Stable yields; fees cover most validator income.

---

## 11) Risk Analysis

| Risk                                | Mitigation                                                                    |
| ----------------------------------- | ----------------------------------------------------------------------------- |
| **Fee shortfall vs. proving costs** | Dynamic zk fee market; temporary treasury subsidy switch if needed (with cap) |
| **Validator centralization**        | Commission bounds, stake caps per validator, delegation incentives            |
| **Low stake ratio**                 | APR calibration; fee-share routing to stakers; community staking campaigns    |
| **Parameter capture**               | Governance guardrails + multi-chamber approvals                               |
| **Cross-shard complexity**          | Conservative rollout (few shards → more), robust monitoring                   |

---

## 12) Transparency & Reporting

* **On-chain dashboards:** supply, inflation, burns, staking, validator set.
* **Monthly reports:** treasury, grants, expenditures, proving market stats.
* **Quarterly audits:** protocol + tokenomics review updates.
* **Public endpoints:** RPC, explorer, verified SDKs.

---

## 13) Legal & Disclaimer (Non-binding Summary)

* ECLIPT is designed as a **protocol utility token** to secure the network and pay transaction/proof fees.
* This document describes **intended parameters**; changes require governance within the guardrails above.
* This is **not investment advice**; jurisdictional compliance is the responsibility of participants.

---

## 14) Parameter Registry (Initial)

| Parameter              | Symbol            | Value                                       | Range / Governance   |
| ---------------------- | ----------------- | ------------------------------------------- | -------------------- |
| Initial inflation      | $I_0$             | 3.5%                                        | Fixed                |
| Tail inflation         | $I_{\text{tail}}$ | 0.5%                                        | **Max 0.5%**         |
| Decay constant         | $k$               | 0.12                                        | Tunable ±10%         |
| Burn fraction          | $\beta$           | 0.3–0.7% fees                               | Governable (bounded) |
| Staking ratio target   | $\sigma^*$        | ≥ 60%                                       | Derived (incentives) |
| Reward split           | —                 | 70% stakers / 20% validators / 10% treasury | Governable (bounded) |
| Unbonding              | —                 | 14 days                                     | 7–21 days            |
| Commission bound       | —                 | 0–10%                                       | Governable           |
| Slashing (double-sign) | —                 | up to 5%                                    | Governable (cap)     |

---

## 15) Appendices

### A) APR Back-of-Envelope

If $\sigma=0.6$, $I=1.5\%$ mid-curve:

$$
Y_{\text{issuance}} = \frac{0.7 \cdot 1.5\%}{0.6} \approx 1.75\%
$$

Add fee share; subtract dilution ($\approx 0$ at equilibrium) → **\~2–3%** APR.

### B) Implementation Notes

* Rewards paid per epoch; compounding at claim.
* Auto-restake optional via wallet flag (non-custodial).
* All accounting done in integers (leptons) for determinism.

---

### 📌 One-Paragraph TL;DR

Ecliptica issues from **1.0B** toward a soft cap near **1.3B**, but burns make the **effective supply stabilize** lower over time. A **0.5% tail** funds security in perpetuity, while **fees (and burns)** couple token scarcity to real usage. **Stakers** earn most issuance (70%), **validators** receive 20% plus tips/fees, and **treasury** 10% with guardrails. **zk-provers** are paid from **fees**, not inflation. The result is a **scarce, sustainable**, PQ-secure economy designed for a century-scale, privacy-preserving L1.

