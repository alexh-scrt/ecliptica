# 🚀 Ecliptica Development Environment Installation Guide

**System Requirements:**
- Ubuntu 24.04 LTS
- NVIDIA H100 GPU (or compatible)
- 64GB RAM minimum
- 500GB+ free disk space
- Stable internet connection

---

## 📋 Pre-Installation Checklist

Before starting, ensure:

- [ ] Fresh Ubuntu 24.04 installation
- [ ] User has sudo privileges
- [ ] Internet connection is stable
- [ ] At least 500GB free disk space
- [ ] All important data backed up

---

## 🛠️ Installation Process

### Step 1: Clone Setup Scripts

First, create the workspace and download setup scripts:

```bash
# Create workspace
mkdir -p ~/ecliptica/scripts
cd ~/ecliptica

# Download all setup scripts (you'll need to save the artifacts as scripts)
# Save each script from the artifacts to ~/ecliptica/scripts/

# Scripts to save:
# - 01_system_setup.sh
# - 02_crypto_setup.sh  
# - 03_network_setup.sh
# - 04_monitoring_setup.sh
# - master_setup.sh
```

### Step 2: Make Scripts Executable

```bash
chmod +x ~/ecliptica/scripts/*.sh
```

### Step 3: Run Master Setup

```bash
cd ~/ecliptica/scripts
./master_setup.sh
```

**This will:**
- Install all system dependencies
- Setup NVIDIA drivers and CUDA 12.4
- Install Rust toolchain with optimizations
- Install post-quantum cryptography libraries
- Setup networking and distributed testing tools
- Install monitoring and profiling infrastructure
- Verify complete installation

**Estimated Time:** 60-90 minutes

**Note:** The script will pause and ask for confirmation before proceeding.

---

## 🔄 Alternative: Step-by-Step Installation

If you prefer manual control, run each phase separately:

### Phase 1: System Foundation (20 min)
```bash
cd ~/ecliptica/scripts
./01_system_setup.sh
```

**Installs:**
- Build tools (gcc, clang, cmake)
- NVIDIA drivers & CUDA 12.4
- Rust toolchain
- Docker & Docker Compose
- Performance tools

### Phase 2: Cryptography (25 min)
```bash
./02_crypto_setup.sh
```

**Installs:**
- liboqs (ML-KEM, ML-DSA)
- pqcrypto Rust crates
- Winterfell (ZK-STARK)
- CUDA-accelerated crypto
- Benchmark suite

### Phase 3: Networking (15 min)
```bash
./03_network_setup.sh
```

**Installs:**
- libp2p for Rust
- Network simulation tools
- Docker multi-node setup
- Kubernetes (k3s)
- Distributed testing framework

### Phase 4: Monitoring (20 min)
```bash
./04_monitoring_setup.sh
```

**Installs:**
- NVIDIA Nsight profilers
- Flamegraph & CPU profiling
- Metrics collection
- Real-time dashboard
- Log aggregation

### Phase 5: Verification (5 min)
```bash
./verify_setup.sh
```

**After each phase, check logs:**
```bash
ls -lh ~/ecliptica/setup-logs/
```

---

## ✅ Post-Installation

### 1. Reboot System
```bash
sudo reboot
```

### 2. Verify Installation
```bash
cd ~/ecliptica
source ~/.bashrc
./scripts/verify_setup.sh
```

**Expected Output:**
```
✓ Rust toolchain installed: 1.XX.X
✓ CUDA toolkit installed: 12.4
✓ NVIDIA driver installed: 550.XX
✓ Docker installed: 27.X.X
✓ liboqs (ML-KEM, ML-DSA)
✓ pqcrypto-kyber (Rust)
✓ Winterfell (ZK-STARK)
✓ CUDA crypto library
✓ libp2p for Rust
...

╔════════════════════════════════════════════╗
║   ✓ ALL CHECKS PASSED                      ║
║   Environment is ready for development!    ║
╚════════════════════════════════════════════╝
```

### 3. Run Quick Tests

**Test STARK Benchmarks:**
```bash
cd ~/ecliptica/crypto-bench
cargo bench
```

**Test GPU Acceleration:**
```bash
cd ~/ecliptica/cuda-crypto-rs
cargo test --release
```

**Test Network Stack:**
```bash
cd ~/ecliptica/distributed-bench
cargo build --release
```

---

## 🐛 Troubleshooting

### Issue: NVIDIA Driver Not Found

**Solution:**
```bash
# Check if driver installed
nvidia-smi

# If not, reinstall
sudo apt remove --purge nvidia-*
sudo apt install nvidia-driver-550
sudo reboot
```

### Issue: CUDA Not in PATH

**Solution:**
```bash
# Add to ~/.bashrc
echo 'export PATH=/usr/local/cuda-12.4/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

### Issue: Docker Permission Denied

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
exit
# (re-login)

# Test
docker run hello-world
```

### Issue: Rust Build Fails

**Solution:**
```bash
# Update Rust
rustup update stable

# Clear cache
cargo clean

# Rebuild
cargo build --release
```

### Issue: Out of Disk Space

**Solution:**
```bash
# Check space
df -h

# Clean Docker
docker system prune -a

# Clean Cargo cache
cargo cache --autoclean
```

### Issue: CUDA Compute Capability Error

**Solution:**
```bash
# Check GPU compute capability
nvidia-smi --query-gpu=compute_cap --format=csv

# H100 should show 9.0
# If different, update CMakeLists.txt in cuda-crypto/
```

---

## 📊 Verification Checklist

After installation, verify each component:

### System Components
- [ ] Rust 1.75+ installed
- [ ] CUDA 12.4 installed  
- [ ] NVIDIA driver 550+ installed
- [ ] Docker running
- [ ] 500GB+ disk space available

### Cryptography
- [ ] liboqs library present
- [ ] pqcrypto crates compile
- [ ] Winterfell benchmarks run
- [ ] CUDA crypto library built

### Networking
- [ ] libp2p compiles
- [ ] Docker testnet network exists
- [ ] Network simulation tools work
- [ ] k3s cluster running

### Monitoring
- [ ] Flamegraph generates profiles
- [ ] NVIDIA Nsight installed
- [ ] Metrics dashboard starts
- [ ] Prometheus accessible

---

## 🎯 Next Steps

Once installation is verified:

1. **Read Quick Start Guide:**
   ```bash
   cat ~/ecliptica/QUICK_START.md
   ```

2. **Begin Core Validation:**
   ```bash
   cd ~/ecliptica/core/stark-validation
   cargo run --release
   ```

3. **Start Monitoring:**
   ```bash
   cd ~/ecliptica/metrics-dashboard
   cargo run --release &
   # Open http://localhost:8080
   ```

4. **Run Comprehensive Benchmarks:**
   ```bash
   cd ~/ecliptica/benchmarks
   ./run_all_benchmarks.sh
   ```

---

## 📁 Directory Structure

After installation, your workspace will look like:

```
~/ecliptica/
├── core/                  # Core validation projects
│   ├── stark-validation/
│   ├── encrypted-exec/
│   ├── threshold-test/
│   ├── cross-shard/
│   └── light-client/
├── benchmarks/            # Benchmark suites
├── profiling/             # Profiling scripts & results
│   ├── cpu/
│   ├── gpu/
│   ├── memory/
│   └── network/
├── docker/                # Multi-node Docker setup
├── scripts/               # Setup & utility scripts
├── network-tools/         # Network simulation
├── data/                  # Test data
├── logs/                  # Application logs
├── setup-logs/            # Installation logs
└── QUICK_START.md         # Quick reference guide
```

---

## 🔒 Security Considerations

1. **Firewall Configuration:**
   ```bash
   # Allow development ports
   sudo ufw allow 8000:9000/tcp
   sudo ufw allow 3000/tcp  # Grafana
   sudo ufw allow 9090/tcp  # Prometheus
   ```

2. **Docker Security:**
   - Container isolation enabled by default
   - Use Docker secrets for sensitive data
   - Regular security updates

3. **SSH Hardening** (if remote):
   ```bash
   # Disable password auth
   sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ```

---

## 💾 Backup Recommendations

**Critical directories to backup:**
- `~/ecliptica/core/` - Validation projects
- `~/ecliptica/data/` - Test data
- `~/ecliptica/.env` - Environment config
- `~/.cargo/` - Rust dependencies (optional)

**Backup command:**
```bash
tar -czf ecliptica-backup-$(date +%Y%m%d).tar.gz \
  ~/ecliptica/core \
  ~/ecliptica/data \
  ~/ecliptica/.env
```

---

## 📞 Support

If you encounter issues:

1. **Check logs:**
   ```bash
   ls -lh ~/ecliptica/setup-logs/
   tail -100 ~/ecliptica/setup-logs/<latest_log>
   ```

2. **Run verification:**
   ```bash
   ~/ecliptica/scripts/verify_setup.sh
   ```

3. **Get system info:**
   ```bash
   # Generate diagnostics
   cat > /tmp/ecliptica-diag.sh <<'EOF'
   #!/bin/bash
   echo "=== System Info ==="
   uname -a
   lsb_release -a
   echo ""
   echo "=== GPU Info ==="
   nvidia-smi
   echo ""
   echo "=== CUDA Info ==="
   nvcc --version
   echo ""
   echo "=== Rust Info ==="
   rustc --version
   cargo --version
   echo ""
   echo "=== Docker Info ==="
   docker --version
   docker ps
   EOF
   chmod +x /tmp/ecliptica-diag.sh
   /tmp/ecliptica-diag.sh > ~/ecliptica-diagnostics.txt
   ```

4. **Contact:**
   - GitHub Issues: [repository URL]
   - Email: dev@ecliptica.io
   - Discord: [invite link]

---

## 🔄 Updating

To update the environment:

```bash
# Update Rust
rustup update

# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Cargo dependencies
cd ~/ecliptica
cargo update

# Rebuild with latest
cargo build --release --workspace
```

---

## 🗑️ Uninstallation

To remove the development environment:

```bash
# Stop all services
docker-compose -f ~/ecliptica/docker/docker-compose.yml down
sudo k3s-uninstall.sh

# Remove Ecliptica
rm -rf ~/ecliptica

# Remove CUDA (optional)
sudo apt remove --purge cuda-* nvidia-*

# Remove Docker (optional)
sudo apt remove --purge docker-ce docker-ce-cli containerd.io

# Clean up
sudo apt autoremove -y
```

---

## 📄 License

This development environment setup is part of the Ecliptica project.

---

**Installation complete! Welcome to Ecliptica development! 🌐**




Now let me create the final installation instructions document:## 📝 **Summary**

I've created a **comprehensive development environment setup** for Ubuntu 24.04 with NVIDIA H100 and 64GB RAM, specifically tailored for Ecliptica's core assumptions validation. Here's what's included:

### **🎯 What You Have Now:**

1. **5 Setup Scripts** (as Artifacts):
   - `01_system_setup.sh` - System foundation, CUDA, Rust
   - `02_crypto_setup.sh` - Post-quantum crypto libraries
   - `03_network_setup.sh` - libp2p, distributed testing
   - `04_monitoring_setup.sh` - Profiling and metrics
   - `master_setup.sh` - Orchestrates everything

2. **3 Validation Benchmarks** (as Artifacts):
   - STARK proof benchmark framework
   - Encrypted execution POC (3 models)
   - Threshold decryption latency test

3. **Complete Documentation**:
   - Installation guide with troubleshooting
   - Quick start guide for development
   - Directory structure and workflows

### **⚡ Key Features:**

**GPU Acceleration:**
- CUDA 12.4 with H100 support (compute 9.0)
- Custom NTT kernels for STARK proving
- GPU-accelerated cryptography primitives

**Post-Quantum Crypto:**
- liboqs (ML-KEM-512, ML-DSA)
- pqcrypto Rust crates
- Winterfell ZK-STARK library
- Benchmarking suite included

**Distributed Testing:**
- libp2p with full features
- Docker multi-node setup (3 validators)
- Network simulation (latency, packet loss, bandwidth)
- Kubernetes (k3s) for advanced scenarios

**Monitoring & Profiling:**
- NVIDIA Nsight for GPU profiling
- Flamegraph for CPU profiling
- Prometheus + Grafana dashboards
- Real-time metrics collection

### **📋 Installation Steps:**

```bash
# 1. Save all scripts to ~/ecliptica/scripts/

# 2. Make executable
chmod +x ~/ecliptica/scripts/*.sh

# 3. Run master setup
cd ~/ecliptica/scripts
./master_setup.sh

# 4. Reboot
sudo reboot

# 5. Verify
source ~/.bashrc
~/ecliptica/scripts/verify_setup.sh
```

**Total Installation Time:** 60-90 minutes

### **🚀 What to Do Next:**

1. **Run the master setup script** to install everything
2. **After reboot**, verify installation
3. **Start with STARK benchmarks** to validate Assumption 1
4. **Run encrypted execution tests** for Assumption 2
5. **Test threshold decryption** for Assumption 3

### **📊 Expected Validation Results:**

Each validation project will produce:
- Performance benchmarks with actual numbers
- GPU/CPU profiling reports
- Go/No-Go recommendations for each assumption
- Optimization suggestions for Phase 1

