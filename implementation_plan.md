# 🤖 Ecliptica Implementation Plan

## **Overview**

This document provides step-by-step instructions for implementing Ecliptica's core validation projects. Each section is designed to be executed sequentially, with clear objectives and acceptance criteria.

---

## **Prerequisites**

Before starting, ensure the development environment is set up:

```bash
# Verify environment
cd ~/ecliptica
./scripts/verify_setup.sh

# Should show all green checkmarks
```

---

## **Phase 1: STARK Proof Validation (Weeks 1-2)**

### **Objective**
Validate that zk-STARK proof generation meets the <2 second target for encrypted transaction proofs.

### **Task 1.1: Setup STARK Benchmark Project**

**Instructions for Claude Code:**

```
Create a new Rust project at ~/ecliptica/core/stark-validation with the following structure:

stark-validation/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── main.rs
│   ├── circuit.rs      # STARK circuit definition
│   ├── prover.rs       # Proof generation
│   ├── verifier.rs     # Proof verification
│   └── benchmarks.rs   # Benchmark suite
├── benches/
│   └── stark_bench.rs
└── tests/
    └── integration_test.rs

Requirements:
1. Use Winterfell 0.9.x for STARK proving
2. Implement circuits for encrypted transaction validation
3. Support variable complexity (simple transfer → complex DeFi)
4. Include CPU and GPU proving paths
5. Export metrics in JSON format

Cargo.toml dependencies:
- winterfell = "0.9"
- criterion = "0.5"
- serde_json = "1"
- rand = "0.8"
- sha3 = "0.10"

Implementation details:
- Circuit should verify: balance constraints, nullifier uniqueness, signature validity
- Prover should use SHAKE-256 for hashing
- Benchmark should measure: trace generation, proof time, verification time, proof size
- GPU path should use CUDA NTT from ~/ecliptica/cuda-crypto
```

### **Task 1.2: Implement STARK Circuit**

**File: `src/circuit.rs`**

```
Implement an AIR (Algebraic Intermediate Representation) circuit for encrypted transactions:

Circuit Constraints:
1. Balance Constraint: old_balance - amount = new_balance (mod prime)
2. Nullifier Constraint: nullifier = SHAKE256(secret || nonce)
3. Commitment Constraint: commitment = SHAKE256(amount || blinding_factor)
4. Range Constraint: amount >= 0 and amount <= MAX_AMOUNT

The circuit should:
- Support 3 complexity levels: Simple (128 steps), Medium (512 steps), Complex (2048 steps)
- Use Winterfell's Air trait
- Include transition constraints for each step
- Export public inputs: nullifiers, commitments

Reference Winterfell examples at: https://github.com/facebook/winterfell/tree/main/examples
```

### **Task 1.3: Implement Prover**

**File: `src/prover.rs`**

```
Create a STARK prover with the following features:

1. Proof Generation Pipeline:
   - Generate execution trace from transaction
   - Build constraint evaluator
   - Generate STARK proof using Winterfell
   - Optionally use GPU-accelerated NTT

2. Complexity Modes:
   - Simple Transfer: 1 input, 2 outputs, ~128 trace steps
   - Medium DeFi: 3 inputs, 5 outputs, ~512 trace steps  
   - Complex DeFi: 5 inputs, 10 outputs, ~2048 trace steps

3. GPU Acceleration:
   - Load CUDA NTT library from ~/ecliptica/cuda-crypto/build/libcuda_crypto.so
   - Use GPU NTT for polynomial operations if available
   - Fallback to CPU if GPU unavailable

4. Metrics Collection:
   - Trace generation time
   - NTT operations time
   - Proof composition time
   - Total proving time
   - Proof size in bytes

Export struct ProofMetrics with all timing data.
```

### **Task 1.4: Implement Benchmarks**

**File: `benches/stark_bench.rs`**

```
Create comprehensive benchmarks using Criterion:

Benchmark Scenarios:
1. Simple Transfer (baseline)
   - 1 input, 2 outputs
   - Target: <500ms

2. Medium DeFi Operation
   - 3 inputs, 5 outputs, contract call
   - Target: <1.5s

3. Complex DeFi Operation
   - 5 inputs, 10 outputs, multiple contract calls
   - Target: <2s

For each scenario, measure:
- CPU-only proving time
- GPU-accelerated proving time (if H100 available)
- Verification time
- Proof size

Output format:
- Console output with criterion
- JSON export to ../profiling/results/stark_benchmark.json
- Include: min, max, mean, median, p95, p99 latencies

Run with: cargo bench --bench stark_bench
```

### **Task 1.5: Integration Tests**

**File: `tests/integration_test.rs`**

```
Create integration tests that verify:

1. Proof Validity:
   - Generate proof for valid transaction → verify passes
   - Generate proof for invalid transaction → verify fails
   - Verify proof determinism (same input = same proof)

2. Performance Regression:
   - Load baseline from ../profiling/results/stark_baseline.json
   - Current performance must be within 20% of baseline
   - Fail test if regression > 20%

3. GPU Acceleration:
   - Skip if no GPU available
   - Compare CPU vs GPU proving time
   - GPU should be at least 5x faster for complex proofs

Run with: cargo test --release
```

### **Acceptance Criteria for Phase 1:**

- [ ] All benchmarks pass with <2s proving time for complex transactions
- [ ] Proof verification takes <100ms
- [ ] Proof size is <50KB
- [ ] GPU acceleration provides >5x speedup (if available)
- [ ] Integration tests pass with 0 failures
- [ ] Performance metrics exported to JSON

**Deliverable:** Performance report showing TPS capacity based on proving time.

---

## **Phase 2: Encrypted Execution Validation (Weeks 3-4)**

### **Objective**
Prove smart contracts can execute on encrypted state with <10× performance overhead.

### **Task 2.1: Setup Encrypted Execution Project**

**Instructions for Claude Code:**

```
Create project at ~/ecliptica/core/encrypted-exec:

encrypted-exec/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── main.rs
│   ├── models/
│   │   ├── mod.rs
│   │   ├── client_zk.rs    # Client-side ZK execution
│   │   ├── tee.rs          # TEE-based execution
│   │   └── mpc.rs          # MPC-based execution
│   ├── contracts/
│   │   ├── counter.rs      # Simple counter contract
│   │   ├── token.rs        # ERC20-like token
│   │   └── dex.rs          # DEX swap contract
│   └── crypto/
│       ├── encryption.rs   # ML-KEM encryption
│       └── state.rs        # Encrypted state management
└── benches/
    └── exec_bench.rs

Dependencies:
- pqcrypto-kyber = "0.8"
- wasmtime = { version = "18", features = ["cranelift"] }
- winterfell = "0.9"  # For ZK proofs
- sha3 = "0.10"
- criterion = "0.5"
```

### **Task 2.2: Implement Execution Models**

**File: `src/models/client_zk.rs`**

```
Implement Client-Side ZK Execution Model:

1. Client-side execution flow:
   - Client decrypts state locally
   - Execute contract operation
   - Re-encrypt new state
   - Generate ZK proof of correct execution

2. ZK Circuit for Execution:
   - Public inputs: old state commitment, new state commitment, method hash
   - Private inputs: old state plaintext, new state plaintext, execution trace
   - Constraints: verify state transition is valid

3. Performance tracking:
   - Decryption time
   - Execution time
   - Encryption time
   - Proof generation time
   - Total overhead vs plaintext

Struct ClientZKExecutor with methods:
- execute_encrypted(&self, encrypted_state, method) -> (new_state, proof, metrics)
- verify_execution(&self, proof) -> bool
```

**File: `src/models/tee.rs`**

```
Implement TEE-Based Execution Model:

1. Simulated TEE execution:
   - Attestation phase (simulated)
   - Decrypt inside "enclave"
   - Execute contract
   - Re-encrypt result
   - Return with attestation proof

2. Trust model:
   - Document assumptions about TEE security
   - Simulate SGX/SEV-like environment
   - Add performance overhead for attestation

3. Performance tracking:
   - Attestation overhead
   - Execution time
   - Total overhead vs plaintext

Note: This is simulation. Production would use actual SGX/SEV.
```

**File: `src/models/mpc.rs`**

```
Implement MPC-Based Execution Model:

1. Secret sharing approach:
   - Split encrypted state into shares (Shamir 3-of-5)
   - Simulate 5 parties computing on shares
   - Reconstruct result from shares

2. Network simulation:
   - Add realistic network latency per party (50-100ms)
   - Simulate parallel computation
   - Track communication rounds

3. Performance tracking:
   - Share generation time
   - Computation time (parallel)
   - Reconstruction time
   - Network overhead
   - Total overhead vs plaintext

Struct MPCExecutor with multi-party simulation.
```

### **Task 2.3: Implement Test Contracts**

**File: `src/contracts/counter.rs`**

```
Implement encrypted counter contract:

State: u64 (encrypted)

Methods:
- increment(&mut self)
- decrement(&mut self)
- get(&self) -> u64

Execution in each model:
1. Decrypt state
2. Perform operation
3. Encrypt new state
4. Generate proof (for ZK model)

This is the simplest contract for baseline overhead measurement.
```

**File: `src/contracts/token.rs`**

```
Implement encrypted ERC20-like token:

State: HashMap<Address, u64> (encrypted balances)

Methods:
- transfer(&mut self, from, to, amount)
- balance_of(&self, address) -> u64

This tests overhead with more complex state (hashmap).
```

**File: `src/contracts/dex.rs`**

```
Implement encrypted DEX swap:

State: 
- reserves: (u64, u64) (encrypted)
- balances: HashMap<Address, (u64, u64)>

Methods:
- swap(&mut self, from, amount_in, min_amount_out)
- add_liquidity(&mut self, from, amount_a, amount_b)

This tests overhead with complex computations (constant product formula).
```

### **Task 2.4: Comprehensive Benchmarking**

**File: `benches/exec_bench.rs`**

```
Benchmark all execution models against all contracts:

Matrix:
- 3 Execution Models × 3 Contracts = 9 benchmark scenarios
- Each scenario: 1000 iterations

Metrics to collect:
1. Absolute times (μs)
2. Overhead vs plaintext (multiplier)
3. Throughput (operations/second)

Comparison baseline:
- Run same contracts in plaintext (no encryption)
- Calculate overhead multiplier for each model

Output:
- Console table with criterion
- JSON export to ../profiling/results/encrypted_exec.json
- Include recommendation: which model to use for v1

Target: At least one model should have <10× overhead.
```

### **Acceptance Criteria for Phase 2:**

- [ ] At least one execution model achieves <10× overhead
- [ ] TEE model likely has lowest overhead (~2-3×)
- [ ] Client-ZK model overhead acceptable for high-value ops (<20×)
- [ ] MPC model documents network requirements
- [ ] All contracts work correctly in all models
- [ ] Recommendation provided for v1 implementation

**Deliverable:** Execution model comparison report with recommendation.

---

## **Phase 3: Threshold Decryption Validation (Weeks 5-6)**

### **Objective**
Validate 67-of-100 threshold decryption completes in <500ms under geographic network conditions.

### **Task 3.1: Setup Threshold Decryption Project**

**Instructions for Claude Code:**

```
Create project at ~/ecliptica/core/threshold-test:

threshold-test/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── validator.rs      # Validator node simulation
│   ├── coordinator.rs    # Decryption coordinator
│   ├── crypto.rs         # Threshold crypto (Shamir)
│   └── network.rs        # Network topology simulation
└── benches/
    └── threshold_bench.rs

Dependencies:
- tokio = { version = "1", features = ["full"] }
- pqcrypto-kyber = "0.8"
- rand = "0.8"
- sha3 = "0.10"
- clap = { version = "4", features = ["derive"] }

Support 3 network topologies:
1. LAN (1-5ms latency)
2. Geographic (50-200ms latency)
3. Adversarial (100-500ms, some nodes slow/offline)
```

### **Task 3.2: Implement Threshold Cryptography**

**File: `src/crypto.rs`**

```
Implement Shamir Secret Sharing over finite field:

Functions:
1. split_secret(secret: &[u8], threshold: usize, total: usize) -> Vec<Share>
   - Use polynomial of degree (threshold - 1)
   - Evaluate at points 1..total
   - Return shares

2. reconstruct_secret(shares: &[Share], threshold: usize) -> Vec<u8>
   - Use Lagrange interpolation
   - Require exactly threshold shares
   - Return reconstructed secret

3. encrypt_shares(shares: Vec<Share>, validator_pubkeys: Vec<PublicKey>) -> Vec<EncryptedShare>
   - Encrypt each share with validator's ML-KEM public key
   - Return encrypted shares for distribution

Field arithmetic:
- Use prime p = 2^252 + 27742317777372353535851937790883648493
- Implement field operations: add, mul, inv
```

### **Task 3.3: Implement Validator Simulation**

**File: `src/validator.rs`**

```
Implement async validator node:

struct Validator {
    id: usize,
    secret_key: SecretKey,
    public_key: PublicKey,
    latency_ms: u64,
    online: bool,
}

Methods:
1. async fn respond_with_share(&self, encrypted_share: &EncryptedShare) -> Result<Share>
   - Simulate network latency (sleep for latency_ms)
   - Decrypt share using ML-KEM secret key
   - Return decrypted share

2. fn set_latency(&mut self, topology: NetworkTopology)
   - LAN: 1-5ms
   - Geographic: 50-200ms (based on validator location)
   - Adversarial: 100-500ms

Geographic latency should simulate realistic scenarios:
- US East <-> US West: 70ms
- US <-> Europe: 120ms
- US <-> Asia: 180ms
- Europe <-> Asia: 150ms
```

### **Task 3.4: Implement Decryption Coordinator**

**File: `src/coordinator.rs`**

```
Implement threshold decryption coordinator:

struct ThresholdCoordinator {
    validators: Vec<Validator>,
    threshold: usize,
}

Methods:
1. async fn decrypt_transaction(&self, encrypted_tx: EncryptedTx) -> Result<Transaction>
   - Phase 1: Broadcast decrypt request to all validators (gossip simulation)
   - Phase 2: Collect shares (parallel futures)
   - Phase 3: Stop when threshold reached (first K validators)
   - Phase 4: Reconstruct secret from shares
   - Phase 5: Decrypt transaction payload
   - Return decrypted transaction

2. fn collect_metrics(&self) -> ThresholdMetrics
   - Total time
   - Broadcast time
   - Collection time (p50, p95, p99 validator response)
   - Reconstruction time
   - Number of shares received

Track metrics for each phase with high precision (microseconds).
```

### **Task 3.5: Network Topology Simulation**

**File: `src/network.rs`**

```
Implement network topology configurations:

enum NetworkTopology {
    LAN,
    Geographic,
    Adversarial,
}

Geographic topology should assign validators to regions:
- 30 validators in North America
- 30 validators in Europe
- 30 validators in Asia
- 10 validators in other regions

Calculate realistic latency between any two validators based on their regions.

Adversarial topology:
- 10% validators offline (don't respond)
- 20% validators very slow (500ms+)
- 70% validators normal

This tests resilience of threshold scheme.
```

### **Task 3.6: Comprehensive Testing**

**File: `benches/threshold_bench.rs`**

```
Benchmark threshold decryption across topologies:

Test Matrix:
1. Validator counts: [10, 50, 100]
2. Thresholds: [7/10, 34/50, 67/100]
3. Topologies: [LAN, Geographic, Adversarial]

For each combination:
- Run 100 iterations
- Collect latency distribution
- Calculate success rate (for adversarial)

Metrics:
- Mean, median, p95, p99 latency
- Success rate (got threshold shares)
- Bandwidth usage estimate

Output:
- JSON report: ../profiling/results/threshold_benchmark.json
- Pass/fail against <500ms target for geographic topology
```

### **Acceptance Criteria for Phase 3:**

- [ ] LAN topology: <100ms average latency
- [ ] Geographic topology: <500ms p95 latency ✅ (TARGET)
- [ ] Adversarial topology: >90% success rate
- [ ] 67-of-100 configuration meets targets
- [ ] Bandwidth usage <100KB per decryption
- [ ] Graceful degradation with slow/offline validators

**Deliverable:** Threshold decryption performance report with network analysis.

---

## **Phase 4: Cross-Shard Validation (Weeks 7-8)**

### **Objective**
Achieve <5 second cross-shard finality with optimistic execution.

### **Task 4.1: Setup Cross-Shard Project**

**Instructions for Claude Code:**

```
Create project at ~/ecliptica/core/cross-shard:

cross-shard/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── shard.rs          # Shard simulation
│   ├── methods/
│   │   ├── optimistic.rs # Optimistic execution
│   │   ├── light_client.rs # Light client proofs
│   │   └── strong.rs     # Strong finality (2PC)
│   ├── receipt.rs        # Cross-shard receipts
│   └── fraud_proof.rs    # Fraud detection
└── benches/
    └── cross_shard_bench.rs

Dependencies:
- tokio = { version = "1", features = ["full"] }
- winterfell = "0.9"
- sha3 = "0.10"
- serde = { version = "1", features = ["derive"] }
```

### **Task 4.2: Implement Shard Simulation**

**File: `src/shard.rs`**

```
Implement minimal shard for cross-shard testing:

struct Shard {
    id: u8,
    state: HashMap<Address, Balance>,
    finalized_height: u64,
}

Methods:
1. fn lock_balance(&mut self, address: Address, amount: Balance) -> Result<LockReceipt>
   - Verify sufficient balance
   - Lock balance (mark as reserved)
   - Generate lock receipt with proof

2. fn unlock_balance(&mut self, receipt: &UnlockReceipt) -> Result<()>
   - Verify receipt signature
   - Verify receipt not already redeemed
   - Credit balance to recipient

3. fn finalize_block(&mut self, height: u64)
   - Mark block as finalized
   - Cannot rollback finalized blocks

Lock receipts should include:
- Source shard ID
- Locked amount
- User address
- Block height
- Merkle proof of inclusion
```

### **Task 4.3: Implement Transfer Methods**

**File: `src/methods/optimistic.rs`**

```
Implement Optimistic Cross-Shard Transfer:

Flow:
1. User submits transfer to shard A
2. Shard A locks balance immediately
3. Shard A sends receipt to shard B (async)
4. Shard B credits user immediately (optimistic)
5. If fraud detected → slashing + rollback

Target latency: <2 seconds

struct OptimisticTransfer {
    fraud_proof_window: u64,  // 100 blocks (~50 seconds)
}

Methods:
- async fn execute(&self, from_shard, to_shard, amount) -> Result<Duration>
- fn generate_fraud_proof(&self, invalid_receipt) -> FraudProof
- fn verify_fraud_proof(&self, proof) -> bool

Track:
- Transfer latency
- Fraud detection rate
- Rollback frequency
```

**File: `src/methods/light_client.rs`**

```
Implement Light Client Proof Method:

Flow:
1. Shard A locks balance
2. Shard A generates light client proof (sync committee signatures)
3. Shard B verifies proof
4. Shard B credits balance

Target latency: <3 seconds

Proof includes:
- Block header from shard A
- Sync committee signatures (67%)
- Merkle proof of lock transaction

This is similar to IBC (Inter-Blockchain Communication) approach.
```

**File: `src/methods/strong.rs`**

```
Implement Strong Finality (2PC):

Flow:
1. Prepare phase: Shard A locks, Shard B reserves slot
2. Wait for both shards to finalize (12 blocks each)
3. Commit phase: Shard A releases, Shard B credits
4. If timeout → rollback both shards

Target latency: <15 seconds (acceptable for large transfers)

This is the safest method with absolute finality.
```

### **Task 4.4: Adaptive Method Selection**

**File: `src/lib.rs`**

```
Implement automatic method selection based on transfer value:

fn select_method(amount: Balance) -> TransferMethod {
    match amount {
        0..=100_000 => TransferMethod::Optimistic,      // <$100
        100_001..=10_000_000 => TransferMethod::LightClient,  // <$10K
        _ => TransferMethod::Strong,                     // >$10K
    }
}

Allow user override with explicit method parameter.

Track metrics per method:
- Latency distribution
- Success rate
- Cost (in gas/fees)
```

### **Task 4.5: Benchmarking All Methods**

**File: `benches/cross_shard_bench.rs`**

```
Benchmark all transfer methods:

Scenarios:
1. Small transfer ($10) → Optimistic
2. Medium transfer ($1000) → Light Client
3. Large transfer ($100K) → Strong Finality

For each scenario, measure:
- Best case latency (everything optimal)
- Average case latency
- Worst case latency (network delays)
- Failure handling time

Simulate network conditions:
- 50ms inter-shard latency
- 10% packet loss
- Occasional validator downtime

Output:
- Latency distribution per method
- Recommendation for different value tiers
- JSON export to ../profiling/results/cross_shard_benchmark.json
```

### **Acceptance Criteria for Phase 4:**

- [ ] Optimistic method: <2s latency for 95% of transfers
- [ ] Light client method: <3s latency with cryptographic security
- [ ] Strong finality: <15s with absolute guarantee
- [ ] Fraud detection: >99.9% accuracy
- [ ] Adaptive selection works correctly
- [ ] Graceful degradation under network stress

**Deliverable:** Cross-shard transfer performance analysis with method recommendations.

---

## **Phase 5: Light Client Validation (Weeks 9-10)**

### **Objective**
Verify mobile devices can sync chain state in <30 seconds.

### **Task 5.1: Setup Light Client Project**

**Instructions for Claude Code:**

```
Create project at ~/ecliptica/core/light-client:

light-client/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── sync.rs           # Sync algorithm
│   ├── checkpoint.rs     # Checkpoint verification
│   ├── committee.rs      # Sync committee tracking
│   └── mobile/
│       ├── wasm.rs       # WASM bindings
│       └── native.rs     # Native mobile (iOS/Android)
├── benches/
│   └── sync_bench.rs
└── examples/
    └── mobile_sync.rs

Dependencies:
- pqcrypto-dilithium = "0.5"
- sha3 = "0.10"
- serde = { version = "1", features = ["derive"] }
- wasm-bindgen = "0.2"  # For browser

Additional target: wasm32-unknown-unknown
```

### **Task 5.2: Implement Checkpoint Sync**

**File: `src/checkpoint.rs`**

```
Implement checkpoint-based sync:

struct Checkpoint {
    block_height: u64,
    state_root: Hash,
    sync_committee: Vec<PublicKey>,
    signatures: Vec<Signature>,
}

Methods:
1. fn verify_checkpoint(&self) -> Result<bool>
   - Verify 67% of sync committee signed
   - Verify ML-DSA signatures
   - Verify state root commitment

2. fn download_checkpoint(source: CheckpointSource) -> Result<Checkpoint>
   - Support multiple sources:
     * Foundation API
     * GitHub releases
     * IPFS
     * DNS TXT records
   - Require 2+ sources to agree

Checkpoint format: ~50KB (serialized)
```

### **Task 5.3: Implement Sync Algorithm**

**File: `src/sync.rs`**

```
Implement light client sync algorithm:

Flow:
1. Download latest checkpoint (trusted sources)
2. Verify checkpoint signatures
3. Download block headers since checkpoint
4. Verify each header with sync committee
5. Track sync committee updates (every 27 hours)

struct LightClient {
    checkpoint: Checkpoint,
    current_height: u64,
    sync_committee: SyncCommittee,
}

Methods:
1. async fn initial_sync(&mut self) -> Result<Duration>
   - Download checkpoint
   - Verify checkpoint
   - Sync to current head
   - Return total sync time

2. async fn sync_block(&mut self, block_header: BlockHeader) -> Result<()>
   - Verify block header with sync committee
   - Update local state
   - Detect committee updates

3. fn verify_header(&self, header: &BlockHeader, signatures: &[Signature]) -> Result<bool>
   - Verify 67% of sync committee signed
   - Verify ML-DSA signatures (batched if possible)

Target: Initial sync in <30 seconds
```

### **Task 5.4: Mobile Optimization**

**File: `src/mobile/wasm.rs`**

```
Create WASM bindings for browser:

#[wasm_bindgen]
pub struct WasmLightClient {
    inner: LightClient,
}

#[wasm_bindgen]
impl WasmLightClient {
    pub async fn new() -> Result<WasmLightClient, JsValue>
    
    pub async fn sync(&mut self) -> Result<f64, JsValue>  // Returns seconds
    
    pub fn current_height(&self) -> u64
    
    pub fn verify_block(&self, header: &[u8]) -> Result<bool, JsValue>
}

Optimize for:
- Minimal WASM binary size (<500KB)
- Fast signature verification
- Low memory usage (<10MB)
- IndexedDB for persistent storage
```

**File: `src/mobile/native.rs`**

```
Create native bindings for iOS/Android:

Platform-specific optimizations:
1. iOS (ARM64):
   - Use platform ML-DSA implementation if available
   - Keychain integration for checkpoint storage
   - Background fetch for sync

2. Android (ARM64):
   - Use platform crypto APIs
   - KeyStore integration
   - WorkManager for background sync

Expose C ABI for FFI:
```c
typedef struct LightClient LightClient;

LightClient* light_client_new(void);
int light_client_sync(LightClient* client);
void light_client_free(LightClient* client);
```
```

### **Task 5.5: Performance Benchmarks**

**File: `benches/sync_bench.rs`**

```
Benchmark light client sync on different platforms:

Simulated Devices:
1. Desktop (powerful):
   - CPU: 8 cores @ 3.5GHz
   - Network: WiFi 100 Mbps
   - Expected: <10 seconds

2. Mobile (mid-range):
   - CPU: ARM Cortex-A55 (4 cores @ 2GHz)
   - Network: 4G LTE (20 Mbps)
   - Expected: <30 seconds ✅ (TARGET)

3. IoT (constrained):
   - CPU: ARM Cortex-M4 (1 core @ 200MHz)
   - Network: 3G (1 Mbps)
   - Expected: <60 seconds

Measure:
- Checkpoint download time
- Signature verification time (per block)
- Header download time
- Total sync time
- Memory usage
- Battery drain estimate (for mobile)

Simulate different checkpoint ages:
- Fresh (1 hour old)
- Stale (1 week old)
- Very stale (1 month old)

Output:
- Performance report per platform
- Bandwidth usage analysis
- Battery impact estimate
- JSON export to ../profiling/results/light_client_benchmark.json
```

### **Acceptance Criteria for Phase 5:**

- [ ] Desktop sync: <10 seconds
- [ ] Mobile sync: <30 seconds (mid-range device) ✅ (TARGET)
- [ ] IoT sync: <60 seconds
- [ ] WASM binary: <500KB
- [ ] Memory usage: <50MB
- [ ] Daily bandwidth: <5MB
- [ ] Battery drain: <1% per sync
- [ ] Signature verification: <100ms per block

**Deliverable:** Light client implementation with multi-platform support and performance report.

---

## **Phase 6: Integration & Reporting (Weeks 11-12)**

### **Task 6.1: Create Unified Test Harness**

**Instructions for Claude Code:**

```
Create integration test at ~/ecliptica/core/integration-test:

Purpose: Run all validation tests together and generate final report.

Cargo workspace members:
- stark-validation
- encrypted-exec
- threshold-test
- cross-shard
- light-client

Create workspace Cargo.toml at ~/ecliptica/core/Cargo.toml:

[workspace]
members = [
    "stark-validation",
    "encrypted-exec",
    "threshold-test",
    "cross-shard",
    "light-client",
    "integration-test"
]

Integration test should:
1. Run all validation benchmarks
2. Collect all metrics
3. Compare against targets
4. Generate comprehensive report
```

### **Task 6.2: Final Validation Report**

**File: `~/ecliptica/core/integration-test/src/report.rs`**

```
Generate final validation report in multiple formats:

Formats:
1. JSON (for automation)
2. Markdown (for documentation)
3. HTML (for presentation)

Report Structure:
- Executive Summary
  * Overall validation result (PASS/FAIL)
  * Key findings
  * Recommendations
  
- Per-Project Results
  * STARK Validation: proof time, TPS capacity
  * Encrypted Execution: overhead comparison
  * Threshold Decryption: latency distribution
  * Cross-Shard: method performance
  * Light Client: sync time, platform support
  
- Performance Comparison
  * vs Targets (color-coded: green/yellow/red)
  * vs Other Blockchains (Ethereum, Solana, etc.)
  
- Go/No-Go Decision Matrix
  * Criteria met
  * Criteria failed
  * Required optimizations
  * Recommended Phase 1 approach
  
- Appendices
  * Raw benchmark data
  * Profiling reports
  * Optimization suggestions

Output files:
- validation_report.json
- validation_report.md
- validation_report.html
```

### **Task 6.3: Automated Validation Runner**

**File: `~/ecliptica/scripts/run_full_validation.sh`**

```
Create automated runner script:

#!/bin/bash
set -e

echo "=== Ecliptica Core Validation Suite ==="
echo "Starting comprehensive validation..."
echo ""

# Create results directory
mkdir -p ~/ecliptica/profiling/results
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR=~/ecliptica/profiling/results/$TIMESTAMP

# 1. STARK Validation
echo "[1/5] Running STARK validation..."
cd ~/ecliptica/core/stark-validation
cargo bench --bench stark_bench -- --save-baseline stark_$TIMESTAMP
cp -r target/criterion $RESULTS_DIR/stark

# 2. Encrypted Execution
echo "[2/5] Running encrypted execution validation..."
cd ~/ecliptica/core/encrypted-exec
cargo bench --bench exec_bench -- --save-baseline exec_$TIMESTAMP
cp -r target/criterion $RESULTS_DIR/encrypted-exec

# 3. Threshold Decryption
echo "[3/5] Running threshold decryption validation..."
cd ~/ecliptica/core/threshold-test
cargo bench --bench threshold_bench -- --save-baseline threshold_$TIMESTAMP
cp -r target/criterion $RESULTS_DIR/threshold

# 4. Cross-Shard
echo "[4/5] Running cross-shard validation..."
cd ~/ecliptica/core/cross-shard
cargo bench --bench cross_shard_bench -- --save-baseline cross_shard_$TIMESTAMP
cp -r target/criterion $RESULTS_DIR/cross-shard

# 5. Light Client
echo "[5/5] Running light client validation..."
cd ~/ecliptica/core/light-client
cargo bench --bench sync_bench -- --save-baseline light_client_$TIMESTAMP
cp -r target/criterion $RESULTS_DIR/light-client

# Generate unified report
echo ""
echo "Generating validation report..."
cd ~/ecliptica/core/integration-test
cargo run --release -- --results-dir $RESULTS_DIR

echo ""
echo "=== Validation Complete ==="
echo "Results saved to: $RESULTS_DIR"
echo "Report: $RESULTS_DIR/validation_report.html"
echo ""

# Open report in browser
xdg-open $RESULTS_DIR/validation_report.html || open $RESULTS_DIR/validation_report.html
```

### **Acceptance Criteria for Phase 6:**

- [ ] All validation tests run successfully
- [ ] Report generated in all formats (JSON/MD/HTML)
- [ ] Go/No-Go decision clearly stated
- [ ] Optimization recommendations provided
- [ ] Results reproducible with automation script

**Final Deliverable:** Comprehensive validation report with go/no-go recommendation for Phase 1.

---

## **Success Metrics Summary**

| Component             | Target | Stretch Goal | Status |
| --------------------- | ------ | ------------ | ------ |
| **STARK Proof**       | <5s    | <2s          | ⏳      |
| **Encrypted Exec**    | <20×   | <10×         | ⏳      |
| **Threshold Decrypt** | <1s    | <500ms       | ⏳      |
| **Cross-Shard**       | <10s   | <5s          | ⏳      |
| **Light Client**      | <60s   | <30s         | ⏳      |

**Overall Success:** 3+ core assumptions validated with at least target metrics met.

---

## **Notes for Claude Code**

1. **Code Quality:**
   - Use `cargo fmt` and `cargo clippy` on all code
   - Add comprehensive error handling with `anyhow` or `thiserror`
   - Include inline documentation with `///` doc comments
   - Write unit tests for all core functions

2. **Performance:**
   - Use `--release` for all benchmarks
   - Profile with `cargo flamegraph` for CPU hotspots
   - Use `nvidia-nsight` for GPU kernels
   - Document performance findings

3. **Testing:**
   - Integration tests should be deterministic
   - Use `proptest` for property-based testing where appropriate
   - Mock network conditions consistently
   - Seed RNGs for reproducibility

4. **Documentation:**
   - Every module should have module-level docs
   - Public APIs must have examples
   - Complex algorithms need explanation comments
   - Update README.md as you go

5. **Git Workflow:**
   - Commit after completing each task
   - Use conventional commits (feat:, fix:, docs:, etc.)
   - Tag milestones (v0.1.0-stark, v0.1.0-exec, etc.)
   - Keep commits atomic and focused

---

## **Timeline Overview**

**Weeks 1-2:** STARK Validation
**Weeks 3-4:** Encrypted Execution  
**Weeks 5-6:** Threshold Decryption
**Weeks 7-8:** Cross-Shard Transfer
**Weeks 9-10:** Light Client
**Weeks 11-12:** Integration & Reporting

**Total Duration:** 12 weeks (3 months)

---

## **Final Checklist**

Before declaring validation complete:

- [ ] All 5 core projects implemented
- [ ] All benchmarks passing
- [ ] All integration tests passing
- [ ] Performance reports generated
- [ ] Code reviewed and documented
- [ ] Final report created
- [ ] Go/No-Go decision made
- [ ] Phase 1 plan drafted (if GO)

---

**This implementation plan provides Claude Code with clear, actionable instructions for building the core validation projects. Each task is self-contained with specific requirements and acceptance criteria.**