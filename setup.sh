#!/bin/bash
# Ecliptica Development Environment Setup
# Ubuntu 24.04 + NVIDIA H100 + 64GB RAM

set -e  # Exit on error

echo "=== Ecliptica Development Environment Setup ==="
echo "System: Ubuntu 24.04"
echo "GPU: NVIDIA H100"
echo "RAM: 64GB"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please run as regular user (not root)"
    exit 1
fi

# 1. Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install essential build tools
print_status "Installing essential build tools..."
sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    git \
    curl \
    wget \
    unzip \
    gcc \
    g++ \
    clang \
    llvm \
    lld \
    python3 \
    python3-pip \
    python3-venv

# 3. Install NVIDIA drivers and CUDA toolkit
print_status "Installing NVIDIA drivers and CUDA 12.4..."

# Add NVIDIA package repository
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
rm cuda-keyring_1.1-1_all.deb

sudo apt update
sudo apt install -y \
    nvidia-driver-550 \
    cuda-toolkit-12-4 \
    nvidia-cuda-toolkit

# Add CUDA to PATH
echo 'export PATH=/usr/local/cuda-12.4/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

# 4. Install Rust toolchain
print_status "Installing Rust toolchain..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    print_warning "Rust already installed"
fi

# Update Rust to latest stable
rustup update stable
rustup default stable

# Add wasm target
rustup target add wasm32-unknown-unknown

# Install Rust components
rustup component add \
    clippy \
    rustfmt \
    rust-analyzer

print_status "Rust version: $(rustc --version)"

# 5. Install additional Rust tools
print_status "Installing Rust development tools..."
cargo install \
    cargo-watch \
    cargo-edit \
    cargo-expand \
    cargo-audit \
    cargo-deny \
    cargo-outdated \
    cargo-tree \
    flamegraph \
    hyperfine \
    tokio-console

# 6. Install Node.js (for tooling)
print_status "Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# 7. Install development libraries
print_status "Installing development libraries..."
sudo apt install -y \
    libgmp-dev \
    libsodium-dev \
    libudev-dev \
    libhidapi-dev \
    libusb-1.0-0-dev \
    libtool \
    autoconf \
    automake

# 8. Install Docker and Docker Compose
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    print_warning "Docker installed. You need to log out and back in for group changes to take effect"
else
    print_warning "Docker already installed"
fi

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 9. Install performance profiling tools
print_status "Installing profiling and monitoring tools..."
sudo apt install -y \
    linux-tools-common \
    linux-tools-generic \
    linux-tools-$(uname -r) \
    valgrind \
    htop \
    iotop \
    iftop \
    nethogs \
    sysstat \
    strace

# Install perf with debugging symbols
sudo apt install -y linux-image-$(uname -r)-dbgsym

# 10. Setup system performance optimizations
print_status "Configuring system performance settings..."

# Increase file descriptor limits
echo "* soft nofile 1048576" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 1048576" | sudo tee -a /etc/security/limits.conf

# Increase network buffer sizes
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF

# Ecliptica network optimizations
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.netdev_max_backlog = 250000
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF

sudo sysctl -p

# 11. Create development directory structure
print_status "Creating development directory structure..."
mkdir -p ~/ecliptica/{
    core,
    benchmarks,
    tests,
    docs,
    scripts,
    data,
    logs
}

# 12. Install VS Code (optional but recommended)
print_status "Installing VS Code..."
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    
    sudo apt update
    sudo apt install -y code
    
    # Install recommended extensions
    code --install-extension rust-lang.rust-analyzer
    code --install-extension vadimcn.vscode-lldb
    code --install-extension tamasfe.even-better-toml
    code --install-extension serayuzgur.crates
    code --install-extension bungcip.better-toml
else
    print_warning "VS Code already installed"
fi

# 13. Verify NVIDIA GPU setup
print_status "Verifying NVIDIA GPU setup..."
nvidia-smi

# 14. Create environment validation script
cat > ~/ecliptica/scripts/verify_setup.sh <<'EOF'
#!/bin/bash
# Verify Ecliptica development environment

echo "=== Ecliptica Environment Verification ==="
echo ""

# Check Rust
echo "Rust toolchain:"
rustc --version
cargo --version
echo ""

# Check CUDA
echo "CUDA version:"
nvcc --version
echo ""

# Check GPU
echo "GPU information:"
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
echo ""

# Check system resources
echo "System resources:"
echo "  RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "  CPU cores: $(nproc)"
echo "  Disk space: $(df -h / | awk 'NR==2 {print $4}') available"
echo ""

# Check Docker
echo "Docker version:"
docker --version
docker-compose --version
echo ""

echo "=== Verification complete ==="
EOF

chmod +x ~/ecliptica/scripts/verify_setup.sh

# 15. Print summary
echo ""
echo "============================================"
print_status "Base system setup complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Log out and back in (for Docker group changes)"
echo "2. Run: source ~/.bashrc"
echo "3. Run: ~/ecliptica/scripts/verify_setup.sh"
echo "4. Continue with Part 2: Cryptography Setup"
echo ""
print_warning "Important: Reboot recommended for all changes to take effect"