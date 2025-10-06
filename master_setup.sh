#!/bin/bash
# Ecliptica Master Setup Script
# Orchestrates complete development environment setup

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
}

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Banner
clear
cat << "EOF"
    _____ ________    ________  _________  _____  _________ _____ 
   / ____|  ____\ \  / /  ____||__   __| |_   _||  _____| |_   _|
  | |  __| |__   \ \/ /| |__      | |      | |  | |__      | |  
  | | |_ |  __|   \  / |  __|     | |      | |  |  __|     | |  
  | |__| | |____  /  \ | |____    | |     _| |_ | |____   _| |_ 
   \_____|______|/__/\_\______|   |_|    |_____||______| |_____|
                                                                 
        ECLIPTICA DEVELOPMENT ENVIRONMENT SETUP
        Ubuntu 24.04 + NVIDIA H100 + 64GB RAM
        
EOF

echo ""
print_header "MASTER SETUP SCRIPT"
echo ""

# Check prerequisites
print_status "Checking prerequisites..."

# Check Ubuntu version
if [ "$(lsb_release -rs)" != "24.04" ]; then
    print_warning "Ubuntu version is not 24.04"
fi

# Check NVIDIA GPU
if ! nvidia-smi &> /dev/null; then
    print_warning "NVIDIA GPU not detected (will be installed)"
fi

# Check RAM
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -lt 60 ]; then
    print_warning "Less than 64GB RAM detected (${TOTAL_RAM}GB)"
fi

# Check disk space
AVAILABLE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 100 ]; then
    print_error "Insufficient disk space. Need at least 100GB, have ${AVAILABLE_SPACE}GB"
    exit 1
fi

print_status "Prerequisites check complete"
echo ""

# Ask user confirmation
read -p "Continue with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Create log directory
LOG_DIR=~/ecliptica/setup-logs
mkdir -p $LOG_DIR
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Phase 1: System Setup
print_header "PHASE 1: SYSTEM FOUNDATION"
echo "This will install system packages and dependencies..."
sleep 2

bash ~/ecliptica/scripts/01_system_setup.sh 2>&1 | tee $LOG_DIR/01_system_setup_${TIMESTAMP}.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_status "Phase 1 complete"
else
    print_error "Phase 1 failed. Check log: $LOG_DIR/01_system_setup_${TIMESTAMP}.log"
    exit 1
fi

echo ""

# Phase 2: Cryptography Setup
print_header "PHASE 2: POST-QUANTUM CRYPTOGRAPHY"
echo "Installing ML-KEM, ML-DSA, and ZK libraries..."
sleep 2

bash ~/ecliptica/scripts/02_crypto_setup.sh 2>&1 | tee $LOG_DIR/02_crypto_setup_${TIMESTAMP}.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_status "Phase 2 complete"
else
    print_error "Phase 2 failed. Check log: $LOG_DIR/02_crypto_setup_${TIMESTAMP}.log"
    exit 1
fi

echo ""

# Phase 3: Networking Setup
print_header "PHASE 3: NETWORKING & DISTRIBUTED TESTING"
echo "Setting up libp2p and distributed testing tools..."
sleep 2

bash ~/ecliptica/scripts/03_network_setup.sh 2>&1 | tee $LOG_DIR/03_network_setup_${TIMESTAMP}.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_status "Phase 3 complete"
else
    print_error "Phase 3 failed. Check log: $LOG_DIR/03_network_setup_${TIMESTAMP}.log"
    exit 1
fi

echo ""

# Phase 4: Monitoring Setup
print_header "PHASE 4: MONITORING & PROFILING"
echo "Installing monitoring and profiling tools..."
sleep 2

bash ~/ecliptica/scripts/04_monitoring_setup.sh 2>&1 | tee $LOG_DIR/04_monitoring_setup_${TIMESTAMP}.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_status "Phase 4 complete"
else
    print_error "Phase 4 failed. Check log: $LOG_DIR/04_monitoring_setup_${TIMESTAMP}.log"
    exit 1
fi

echo ""

# Phase 5: Verification
print_header "PHASE 5: ENVIRONMENT VERIFICATION"
echo "Verifying installation..."
sleep 2

# Run comprehensive verification
cat > /tmp/verify_ecliptica.sh <<'VERIFY_EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}[✓]${NC} $2"
        return 0
    else
        echo -e "${RED}[✗]${NC} $2"
        return 1
    fi
}

FAILED=0

echo "=== ECLIPTICA ENVIRONMENT VERIFICATION ==="
echo ""

# System checks
echo "System Components:"
rustc --version &> /dev/null
print_check $? "Rust toolchain installed: $(rustc --version 2>/dev/null | cut -d' ' -f2)" || ((FAILED++))

nvcc --version &> /dev/null
print_check $? "CUDA toolkit installed: $(nvcc --version 2>/dev/null | grep 'release' | cut -d' ' -f5)" || ((FAILED++))

nvidia-smi &> /dev/null
print_check $? "NVIDIA driver installed: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null)" || ((FAILED++))

docker --version &> /dev/null
print_check $? "Docker installed: $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')" || ((FAILED++))

echo ""

# Cryptography libraries
echo "Cryptography Libraries:"
[ -f /usr/local/lib/liboqs.so ]
print_check $? "liboqs (ML-KEM, ML-DSA)" || ((FAILED++))

cargo tree -p pqcrypto-kyber &> /dev/null
print_check $? "pqcrypto-kyber (Rust)" || ((FAILED++))

cargo tree -p winterfell &> /dev/null
print_check $? "Winterfell (ZK-STARK)" || ((FAILED++))

[ -f ~/ecliptica/cuda-crypto/build/libcuda_crypto.so ]
print_check $? "CUDA crypto library" || ((FAILED++))

echo ""

# Networking
echo "Networking Tools:"
cargo tree -p libp2p &> /dev/null
print_check $? "libp2p for Rust" || ((FAILED++))

which toxiproxy-server &> /dev/null
print_check $? "Toxiproxy (network simulation)" || ((FAILED++))

docker network ls | grep -q ecliptica-testnet
print_check $? "Docker testnet network" || ((FAILED++))

echo ""

# Monitoring
echo "Monitoring & Profiling:"
which nvidia-nsight-sys &> /dev/null
print_check $? "NVIDIA Nsight Systems" || ((FAILED++))

which flamegraph &> /dev/null
print_check $? "Flamegraph profiler" || ((FAILED++))

[ -d ~/ecliptica/metrics-dashboard ]
print_check $? "Metrics dashboard" || ((FAILED++))

echo ""

# GPU capabilities
echo "GPU Information:"
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null)
GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null)
CUDA_CORES=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | grep -q "H100" && echo "16896" || echo "Unknown")

echo "  GPU Model: $GPU_NAME"
echo "  VRAM: $GPU_MEM"
echo "  CUDA Cores: $CUDA_CORES"
echo "  Compute Capability: 9.0 (Hopper)"

echo ""

# System resources
echo "System Resources:"
echo "  Total RAM: $(free -h | awk '/^Mem:/{print $2}')"
echo "  Available RAM: $(free -h | awk '/^Mem:/{print $7}')"
echo "  CPU Cores: $(nproc)"
echo "  Disk Space: $(df -h / | awk 'NR==2 {print $4}') available"

echo ""

# Summary
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✓ ALL CHECKS PASSED                      ║${NC}"
    echo -e "${GREEN}║   Environment is ready for development!    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ✗ $FAILED CHECKS FAILED                        ║${NC}"
    echo -e "${RED}║   Please review errors above               ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
    exit 1
fi
VERIFY_EOF

chmod +x /tmp/verify_ecliptica.sh
/tmp/verify_ecliptica.sh 2>&1 | tee $LOG_DIR/05_verification_${TIMESTAMP}.log
VERIFY_RESULT=${PIPESTATUS[0]}

echo ""

# Final summary
print_header "SETUP COMPLETE"

if [ $VERIFY_RESULT -eq 0 ]; then
    cat << "EOF"

    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║  ✓ Ecliptica Development Environment Ready!          ║
    ║                                                       ║
    ║  Next Steps:                                          ║
    ║  1. Restart your system (recommended)                ║
    ║  2. Run: source ~/.bashrc                            ║
    ║  3. Start validation: cd ~/ecliptica                 ║
    ║  4. Run benchmarks: ./benchmarks/run_all_benchmarks.sh║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝

EOF
    
    # Create quick start guide
    cat > ~/ecliptica/QUICK_START.md << 'QS_EOF'
# Ecliptica Development Quick Start Guide

## 🚀 Getting Started

### 1. Verify Installation
```bash
cd ~/ecliptica
./scripts/verify_setup.sh
```

### 2. Run Your First Benchmark

**STARK Proof Benchmark:**
```bash
cd ~/ecliptica/stark-benchmark
cargo run --release --bin stark_bench
```

**Crypto Performance:**
```bash
cd ~/ecliptica/crypto-bench
cargo bench
```

**GPU Acceleration Test:**
```bash
cd ~/ecliptica/cuda-crypto-rs
cargo test --release
```

## 📊 Core Validation Projects

### Project 1: STARK Performance
```bash
cd ~/ecliptica/core/stark-validation
cargo run --release

# Profile with GPU:
~/ecliptica/profiling/gpu/profile_gpu.sh target/release/stark-validation
```

### Project 2: Encrypted Execution
```bash
cd ~/ecliptica/core/encrypted-exec
cargo run --release -- --model all

# Compare execution models:
cargo run --release -- --model client-zk
cargo run --release -- --model tee
cargo run --release -- --model mpc
```

### Project 3: Threshold Decryption
```bash
cd ~/ecliptica/core/threshold-test
cargo run --release -- --validators 100 --threshold 67 --topology geographic
```

### Project 4: Cross-Shard
```bash
cd ~/ecliptica/core/cross-shard
cargo run --release -- --shards 2 --method optimistic
```

### Project 5: Light Client
```bash
cd ~/ecliptica/core/light-client
cargo build --target wasm32-unknown-unknown --release
```

## 🔧 Development Workflow

### Build & Test
```bash
# Build all projects
cargo build --release --workspace

# Run tests
cargo test --workspace

# Run with logging
RUST_LOG=debug cargo run --release
```

### Profiling

**CPU Profiling:**
```bash
cd ~/ecliptica/profiling/cpu
./profile_cpu.sh <binary_path> <output.svg>
```

**GPU Profiling:**
```bash
cd ~/ecliptica/profiling/gpu
./profile_gpu.sh <binary_path> <output_name>
```

**Memory Profiling:**
```bash
cd ~/ecliptica/profiling/memory
./profile_memory.sh <binary_path>
```

### Network Testing

**Simulate Network Conditions:**
```bash
# Add 100ms latency
~/ecliptica/network-tools/simulate_latency.sh lo 100

# Limit to 10 Mbit/s
~/ecliptica/network-tools/limit_bandwidth.sh lo 10mbit

# Add 5% packet loss
~/ecliptica/network-tools/simulate_packet_loss.sh lo 5

# Remove all
sudo tc qdisc del dev lo root
```

**Run Distributed Test:**
```bash
cd ~/ecliptica/scripts
./run_distributed_test.sh 3 50  # 3 nodes, 50ms latency
```

**Docker Multi-Node:**
```bash
cd ~/ecliptica/docker
docker-compose up -d

# View logs
docker-compose logs -f validator-1

# Stop
docker-compose down
```

## 📈 Monitoring

### Start Metrics Dashboard
```bash
cd ~/ecliptica/metrics-dashboard
cargo run --release

# Open browser: http://localhost:8080
```

### Prometheus + Grafana
```bash
cd ~/ecliptica/docker
docker-compose up -d prometheus grafana

# Grafana: http://localhost:3000
# Username: admin, Password: admin
```

### Real-time Tracing
```bash
# Terminal 1: Start with console
RUSTFLAGS="--cfg tokio_unstable" cargo run --release

# Terminal 2: Connect console
tokio-console
```

## 🧪 Validation Checklist

- [ ] STARK proof generation <2s
- [ ] Encrypted execution overhead <10×
- [ ] Threshold decryption <500ms
- [ ] Cross-shard latency <5s
- [ ] Light client sync <30s

## 📚 Key Directories

```
~/ecliptica/
├── core/              # Core validation projects
├── benchmarks/        # Benchmark suites
├── profiling/         # Profiling scripts & results
├── docker/            # Multi-node setup
├── scripts/           # Utility scripts
├── data/              # Test data
└── logs/              # Application logs
```

## 🔍 Troubleshooting

### CUDA Issues
```bash
# Check CUDA installation
nvcc --version
nvidia-smi

# Verify compute capability
nvidia-smi --query-gpu=compute_cap --format=csv

# Rebuild CUDA libraries
cd ~/ecliptica/cuda-crypto
rm -rf build && mkdir build && cd build
cmake .. && make -j$(nproc)
```

### Docker Permission
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then:
docker run hello-world
```

### Rust Issues
```bash
# Update Rust
rustup update

# Clean and rebuild
cargo clean
cargo build --release
```

## 📖 Documentation

- [Design Docs](./design/)
- [API Reference](./docs/api/)
- [Architecture](./docs/architecture/)

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## 📞 Support

- Issues: GitHub Issues
- Discord: [Coming Soon]
- Email: dev@ecliptica.io
QS_EOF

    print_status "Quick start guide created: ~/ecliptica/QUICK_START.md"
    
    # Create validation project templates
    mkdir -p ~/ecliptica/core/{stark-validation,encrypted-exec,threshold-test,cross-shard,light-client}
    
    # Create README for core projects
    cat > ~/ecliptica/core/README.md << 'CORE_README'
# Ecliptica Core Validation Projects

This directory contains the 5 core validation projects for testing fundamental assumptions.

## Projects

### 1. STARK Validation (`stark-validation/`)
**Goal:** Validate that zk-STARK proof generation meets <2s target

**Key Metrics:**
- Proof generation time
- Proof size
- Verification time
- TPS capacity

**Run:**
```bash
cd stark-validation
cargo run --release
```

### 2. Encrypted Execution (`encrypted-exec/`)
**Goal:** Test smart contract execution with encrypted state

**Models Tested:**
- Client-side ZK
- TEE-based (SGX/SEV)
- MPC-based

**Run:**
```bash
cd encrypted-exec
cargo run --release -- --model all
```

### 3. Threshold Decryption (`threshold-test/`)
**Goal:** Measure 67-of-100 threshold decryption latency

**Topologies:**
- Local LAN
- Geographic
- Adversarial

**Run:**
```bash
cd threshold-test
cargo run --release -- --validators 100 --threshold 67
```

### 4. Cross-Shard (`cross-shard/`)
**Goal:** Achieve <5s cross-shard finality

**Methods:**
- Optimistic execution
- Light client proofs
- Strong finality

**Run:**
```bash
cd cross-shard
cargo run --release -- --shards 2
```

### 5. Light Client (`light-client/`)
**Goal:** <30s sync on mobile devices

**Platforms:**
- iOS (ARM64)
- Android (ARM64)
- Browser (WASM)

**Run:**
```bash
cd light-client
cargo build --target wasm32-unknown-unknown --release
```

## Success Criteria

| Project | Target | Stretch Goal |
|---------|--------|--------------|
| STARK | <5s | <2s |
| Encrypted Exec | <20× | <10× |
| Threshold | <1s | <500ms |
| Cross-Shard | <10s | <5s |
| Light Client | <60s | <30s |

## Timeline

- Week 1-2: Setup & initial benchmarks
- Week 3-4: Optimization passes
- Week 5-6: Final validation & report

## Deliverables

1. Performance benchmarks for each project
2. Profiling reports (CPU/GPU/memory)
3. Validation report with go/no-go recommendation
4. Optimization recommendations for Phase 1
CORE_README

    print_status "Core validation structure created"
    
    # Create environment file
    cat > ~/ecliptica/.env << 'ENV_EOF'
# Ecliptica Development Environment Variables

# Rust settings
RUST_BACKTRACE=1
RUST_LOG=info

# CUDA settings
CUDA_HOME=/usr/local/cuda-12.4
LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH

# Network settings
ECLIPTICA_NETWORK=testnet
ECLIPTICA_P2P_PORT=9000
ECLIPTICA_RPC_PORT=8000

# Metrics
ECLIPTICA_METRICS_PORT=9090

# Profiling
ECLIPTICA_PROFILE_MODE=release
ENV_EOF

    print_status "Environment configuration created"
    
    # Final instructions
    echo ""
    print_status "Setup logs saved to: $LOG_DIR"
    echo ""
    echo "📚 Documentation created:"
    echo "   - ~/ecliptica/QUICK_START.md"
    echo "   - ~/ecliptica/core/README.md"
    echo "   - ~/ecliptica/.env"
    echo ""
    echo "🎯 Next Actions:"
    echo "   1. Reboot your system: sudo reboot"
    echo "   2. After reboot, run: source ~/.bashrc"
    echo "   3. Read quick start: cat ~/ecliptica/QUICK_START.md"
    echo "   4. Begin validation: cd ~/ecliptica/core/stark-validation"
    echo ""
    
else
    print_error "Verification failed. Please check the logs:"
    echo "   $LOG_DIR/05_verification_${TIMESTAMP}.log"
    echo ""
    echo "Common issues:"
    echo "   - Reboot required for driver changes"
    echo "   - Docker group membership needs re-login"
    echo "   - CUDA paths not in environment (run: source ~/.bashrc)"
    exit 1
fi