# 🌐 Ecliptica: Post-Quantum Privacy Blockchain

**Privacy at the Speed of Light**

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/rust-1.75%2B-orange.svg)](https://www.rust-lang.org)
[![CUDA](https://img.shields.io/badge/CUDA-12.4-green.svg)](https://developer.nvidia.com/cuda-toolkit)
[![Status](https://img.shields.io/badge/status-validation%20phase-yellow.svg)](https://github.com/ecliptica)

Ecliptica is a next-generation Layer 1 blockchain that combines **post-quantum cryptography**, **privacy-preserving transactions**, and **high throughput** to create a quantum-resistant, privacy-first platform that can be verified by any device—from data centers to mobile phones.

---

## 🎯 **Vision**

In a world where quantum computers threaten existing blockchains and privacy is increasingly scarce, Ecliptica provides:

- **Post-Quantum Security**: All cryptography (ML-KEM, ML-DSA) resistant to quantum attacks
- **Native Privacy**: Transactions and smart contracts with encrypted state by default
- **Universal Verification**: Light clients on mobile devices can verify chain correctness
- **Scalable Performance**: 50,000+ TPS through sharding and zk-STARK proofs
- **MEV Protection**: Encrypted mempool with threshold decryption prevents front-running

---

## ✨ **Key Features**

### 🔐 **Post-Quantum Cryptography**
- **ML-KEM-512** (Kyber) for key encapsulation
- **ML-DSA** (Dilithium-3) for digital signatures
- **SHAKE-256** for hashing
- **zk-STARKs** for transparent, quantum-resistant proofs

### 🕵️ **Privacy by Design**
- **Encrypted transactions** with viewing keys for selective disclosure
- **Hierarchical Deterministic Viewing Keys (HDVK)** using LWE-PRF (novel contribution)
- **Confidential smart contracts** with encrypted state
- **Privacy-preserving DeFi** without sacrificing auditability

### ⚡ **High Performance**
- **Sharded architecture** with ShardBFT consensus
- **GPU-accelerated proving** with CUDA kernels
- **DAG-based mempool** for parallel transaction processing
- **Sub-second finality** per shard with recursive proof aggregation

### 📱 **Universal Accessibility**
- **Light clients** sync in <30 seconds on mobile devices
- **WASM support** for browser-based verification
- **Minimal bandwidth** (<5 MB/day for light clients)
- **Low resource requirements** for widespread participation

---

## 🏗️ **Architecture Overview**

[High Level Architecture](design/Ecliptica-Arch.png)

**Core Components:**

1. **Sharded Execution Layer**: Parallel transaction processing with BFT consensus
2. **Privacy Layer**: ML-KEM encryption + zk-STARK proofs for confidential state
3. **Aggregation Layer**: Recursive proof composition for global finality
4. **Light Client Protocol**: Sync committee + checkpoint verification for mobile devices

---

## 🚀 **Current Status: Core Validation Phase**

We are currently validating 5 critical technical assumptions:

| Assumption                 | Target                        | Status        |
| -------------------------- | ----------------------------- | ------------- |
| **STARK Proof Generation** | <2s for encrypted tx          | 🔄 In Progress |
| **Encrypted Execution**    | <10× overhead vs plaintext    | 🔄 In Progress |
| **Threshold Decryption**   | <500ms for 67-of-100          | 🔄 In Progress |
| **Cross-Shard Finality**   | <5s with optimistic execution | 🔄 In Progress |
| **Mobile Light Client**    | <30s sync on phones           | 🔄 In Progress |

**Timeline**: 3-month validation phase → Go/No-Go decision → Phase 1 implementation

---

## 🛠️ **Technology Stack**

### **Core Languages**
- **Rust** (consensus, networking, smart contracts)
- **CUDA** (GPU-accelerated cryptography)
- **WASM** (browser and mobile light clients)

### **Cryptography Libraries**
- **liboqs** - Post-quantum crypto (ML-KEM, ML-DSA)
- **Winterfell** - zk-STARK proving system
- **Custom CUDA kernels** - GPU-accelerated NTT, Poseidon hash

### **Networking**
- **libp2p** - P2P communication with gossipsub
- **QUIC** - Low-latency transport for validators
- **Threshold encryption** - 67-of-100 validator decryption

### **Smart Contracts**
- **Wasmtime** - Deterministic WASM runtime
- **Custom VM** - Privacy-preserving execution with encrypted state
- **Rust SDK** - Developer-friendly contract framework

---

## 📦 **Installation**

### **Prerequisites**
- Ubuntu 24.04 LTS (or compatible Linux)
- NVIDIA GPU (H100 recommended for validation, optional for usage)
- 64GB RAM minimum
- 500GB free disk space
- Rust 1.75+
- CUDA 12.4 (for GPU acceleration)

### **Quick Start**

```bash
# Clone repository
git clone https://github.com/ecliptica-blockchain/ecliptica.git
cd ecliptica

# Run automated setup (60-90 minutes)
./scripts/master_setup.sh

# Verify installation
./scripts/verify_setup.sh

# Run validation benchmarks
cd core
cargo test --release --workspace
```

**Detailed installation guide**: See [INSTALLATION.md](docs/INSTALLATION.md)

---

## 🧪 **Development**

### **Project Structure**

```
ecliptica/
├── core/                      # Core validation projects
│   ├── stark-validation/      # zk-STARK proof benchmarks
│   ├── encrypted-exec/        # Encrypted contract execution
│   ├── threshold-test/        # Threshold decryption tests
│   ├── cross-shard/           # Cross-shard atomicity
│   └── light-client/          # Mobile sync protocol
├── benchmarks/                # Performance benchmarks
├── profiling/                 # CPU/GPU profiling results
├── docker/                    # Multi-node test environment
├── scripts/                   # Automation scripts
└── docs/                      # Documentation
```

### **Running Tests**

```bash
# Run all tests
cargo test --workspace

# Run benchmarks
cargo bench --workspace

# Run with profiling
cargo flamegraph --bin <binary>

# GPU profiling
./profiling/gpu/profile_gpu.sh <binary>
```

### **Contributing**

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code of conduct
- Development workflow
- Coding standards
- Pull request process

---

## 📊 **Benchmarks**

### **Preliminary Results** (as of validation phase)

| Metric                 | Current | Target         | Status |
| ---------------------- | ------- | -------------- | ------ |
| STARK Proof Time       | TBD     | <2s            | 🔄      |
| Transaction Throughput | TBD     | 50,000 TPS     | 🔄      |
| Finality Time          | TBD     | <1s per shard  | 🔄      |
| Light Client Sync      | TBD     | <30s mobile    | 🔄      |
| Memory Usage           | TBD     | <4GB validator | 🔄      |

*Results will be updated as validation progresses*

---

## 🔬 **Research & Innovation**

Ecliptica introduces several novel cryptographic constructions:

### **1. Hierarchical Deterministic Viewing Keys (HDVK)**
First post-quantum implementation of HD viewing keys using LWE-PRF, enabling:
- Deterministic key derivation from master seed
- Granular access control (full, partial, time-bound)
- Quantum-resistant privacy with auditability

**Paper**: Coming soon to IACR ePrint

### **2. Encrypted State Smart Contracts**
Novel execution model for privacy-preserving contracts:
- State encrypted with ML-KEM at rest
- ZK proofs verify correct execution without revealing state
- Viewing keys enable selective disclosure to auditors

### **3. Post-Quantum BFT with Privacy**
First combination of:
- ShardBFT consensus (HotStuff-derived)
- Encrypted mempool with threshold decryption
- zk-STARK finality proofs
- Mobile verification

---

## 🛣️ **Roadmap**

### **Phase 0: Core Validation** (Current - Q1 2025)
- [x] Development environment setup
- [ ] STARK proof benchmarks
- [ ] Encrypted execution validation
- [ ] Threshold decryption tests
- [ ] Cross-shard finality validation
- [ ] Light client implementation
- [ ] Go/No-Go decision

### **Phase 1: Testnet Alpha** (Q2-Q3 2025)
- [ ] Core consensus implementation
- [ ] 4-shard testnet deployment
- [ ] Basic smart contract VM
- [ ] Light client SDK (iOS, Android, Web)
- [ ] Developer documentation
- [ ] Bug bounty program

### **Phase 2: Testnet Beta** (Q4 2025)
- [ ] 8-shard scaling
- [ ] Advanced smart contracts
- [ ] MEV protection activation
- [ ] Cross-shard optimizations
- [ ] Security audits (3 firms)
- [ ] Incentivized testnet

### **Phase 3: Mainnet** (Q1 2026)
- [ ] Mainnet genesis
- [ ] Token distribution
- [ ] Staking activation
- [ ] DeFi primitives
- [ ] Bridge deployments
- [ ] Ecosystem grants

### **Future Enhancements**
- [ ] zkVM for fully private execution
- [ ] Homomorphic encryption primitives
- [ ] AI/ML inference in contracts
- [ ] Quantum-resistant bridges
- [ ] Decentralized sequencing

---

## 💰 **Tokenomics**

**Token**: ECLIPT  
**Total Supply**: 1,000,000,000 (1 billion)  
**Inflation**: 10.5% Year 1 → 0.3% Year 20+ (tail emission)

### **Distribution**
- 20% Public Sale
- 15% Team & Advisors (3-year vest)
- 25% Ecosystem Fund (4-year vest)
- 20% Block Rewards Reserve
- 10% Foundation Treasury
- 5% Validator Bootstrap
- 5% Liquidity Provision

### **Staking**
- Target: 60% of supply staked
- APY: 8% at target (dynamic curve: 3-20%)
- Validator minimum: 100,000 ECLIPT
- Delegator minimum: 1,000 ECLIPT
- Unbonding: 21 days

### **Economic Security**
- 33% attack cost: >$100M (at $0.50/token)
- 67% attack cost: >$2B (at $0.50/token)
- All attack scenarios have negative expected value

---

## 🔒 **Security**

### **Cryptographic Assumptions**
- **ML-KEM security**: Based on Module-LWE hardness
- **ML-DSA security**: Based on Module-LWE + Module-SIS
- **zk-STARK soundness**: 100-bit security parameter
- **Hash security**: SHAKE-256 (quantum-resistant)

### **Audits**
- [ ] Trail of Bits (planned Q3 2025)
- [ ] NCC Group (planned Q3 2025)
- [ ] Kudelski Security (planned Q4 2025)

### **Bug Bounty**
- Critical: up to $100,000
- High: up to $50,000
- Medium: up to $10,000
- Low: up to $1,000

**Report**: security@ecliptica.io

---

## 📚 **Documentation**

- [**White Paper**](docs/whitepaper.pdf) - Technical overview
- [**Architecture**](docs/architecture.md) - System design
- [**Cryptography**](docs/cryptography.md) - Crypto primitives
- [**Developer Guide**](docs/developer-guide.md) - Build on Ecliptica
- [**API Reference**](https://docs.ecliptica.io/api) - RPC/SDK docs
- [**Quick Start**](QUICK_START.md) - Get started quickly

---

## 🤝 **Community**

### **Get Involved**
- **Discord**: [discord.gg/ecliptica](https://discord.gg/ecliptica)
- **Twitter**: [@EclipticaChain](https://twitter.com/EclipticaChain)
- **Telegram**: [t.me/ecliptica](https://t.me/ecliptica)
- **Forum**: [forum.ecliptica.io](https://forum.ecliptica.io)

### **Developer Resources**
- **GitHub**: [github.com/ecliptica-blockchain](https://github.com/ecliptica-blockchain)
- **Docs**: [docs.ecliptica.io](https://docs.ecliptica.io)
- **Blog**: [blog.ecliptica.io](https://blog.ecliptica.io)
- **Grants**: [grants.ecliptica.io](https://grants.ecliptica.io)

### **Support**
- **Developer Support**: dev@ecliptica.io
- **General Inquiries**: hello@ecliptica.io
- **Security**: security@ecliptica.io
- **Partnerships**: partnerships@ecliptica.io

---

## 📄 **License**

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

### **Third-Party Licenses**
- Winterfell: MIT License
- liboqs: MIT License
- libp2p: MIT/Apache 2.0
- See [THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES.md) for complete list

---

## 🙏 **Acknowledgments**

Ecliptica builds upon groundbreaking work from:
- **NIST** - Post-quantum cryptography standardization
- **StarkWare** - zk-STARK research
- **Zcash** - Privacy protocol innovations
- **Ethereum** - Smart contract platform design
- **Cosmos** - Inter-blockchain communication
- **Open Quantum Safe** - PQC implementations

Special thanks to all contributors and the broader blockchain research community.

---

## 📈 **Status & Metrics**

![Build Status](https://img.shields.io/github/actions/workflow/status/ecliptica/ecliptica/ci.yml?branch=main)
![Coverage](https://img.shields.io/codecov/c/github/ecliptica/ecliptica)
![Contributors](https://img.shields.io/github/contributors/ecliptica/ecliptica)
![Last Commit](https://img.shields.io/github/last-commit/ecliptica/ecliptica)

**Stars**: ⭐ Star us on GitHub!  
**Forks**: 🍴 Fork and contribute!  
**Issues**: 🐛 [Report bugs](https://github.com/ecliptica/ecliptica/issues)

---

## 🚨 **Disclaimer**

**This is experimental software under active development.**

- Ecliptica is currently in the validation phase and NOT production-ready
- Do not use with real funds or sensitive data
- Post-quantum cryptography is relatively new (ML-KEM standardized 2024)
- All cryptographic assumptions subject to ongoing research
- Performance targets are preliminary and subject to validation

**Use at your own risk.**

---

## 🌟 **Why Ecliptica?**

> "In the orbit of Ecliptica, light and shadow find balance—where every node, even the smallest device, can validate truth without unveiling secrets."

**Privacy** and **security** should not be compromised for **performance**.  
**Quantum resistance** should not sacrifice **usability**.  
**Decentralization** should not be limited to **data centers**.

Ecliptica makes no compromises. We are building the blockchain for the quantum era.

**Join us in creating the future of private, quantum-resistant blockchain technology.**

---

<div align="center">

### 🌐 **Ecliptica: Privacy at the Speed of Light** 🌐

[Website](https://ecliptica.io) • [Docs](https://docs.ecliptica.io) • [Discord](https://discord.gg/ecliptica) • [Twitter](https://twitter.com/EclipticaChain)

**Built with 🔐 by the Ecliptica Team**

</div>