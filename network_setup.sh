#!/bin/bash
# Ecliptica Networking and Distributed Testing Setup

set -e

GREEN='\033[0;32m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

echo "=== Setting up Networking & Distributed Testing ==="
echo ""

# 1. Install libp2p development environment
print_status "Installing libp2p for Rust..."

cd ~/ecliptica
cargo new --lib libp2p-test
cd libp2p-test

cat >> Cargo.toml <<'EOF'

[dependencies]
libp2p = { version = "0.53", features = [
    "tcp",
    "quic",
    "dns",
    "websocket",
    "noise",
    "yamux",
    "gossipsub",
    "kad",
    "identify",
    "ping",
    "mdns",
    "metrics",
    "tokio",
] }
tokio = { version = "1", features = ["full"] }
tracing = "0.1"
tracing-subscriber = "0.3"
futures = "0.3"
async-trait = "0.1"

[dev-dependencies]
criterion = "0.5"
EOF

cargo build --release
print_status "libp2p installed successfully"

# 2. Install network simulation tools
print_status "Installing network simulation tools..."

# Install tc (traffic control) for network simulation
sudo apt install -y iproute2

# Install toxiproxy for fault injection
cd /tmp
wget -q https://github.com/Shopify/toxiproxy/releases/download/v2.9.0/toxiproxy_2.9.0_linux_amd64.deb
sudo dpkg -i toxiproxy_2.9.0_linux_amd64.deb
rm toxiproxy_2.9.0_linux_amd64.deb

# Install pumba for Docker network chaos
sudo curl -L https://github.com/alexei-led/pumba/releases/download/0.9.9/pumba_linux_amd64 -o /usr/local/bin/pumba
sudo chmod +x /usr/local/bin/pumba

print_status "Network simulation tools installed"

# 3. Create network testing utilities
print_status "Creating network testing utilities..."

cd ~/ecliptica
mkdir -p network-tools
cd network-tools

# Network latency simulator script
cat > simulate_latency.sh <<'EOF'
#!/bin/bash
# Simulate geographic network latency

INTERFACE=${1:-lo}
LATENCY=${2:-100}  # milliseconds

# Add latency
sudo tc qdisc add dev $INTERFACE root netem delay ${LATENCY}ms

echo "Added ${LATENCY}ms latency to $INTERFACE"
echo "To remove: sudo tc qdisc del dev $INTERFACE root"
EOF

chmod +x simulate_latency.sh

# Bandwidth limiter script
cat > limit_bandwidth.sh <<'EOF'
#!/bin/bash
# Limit network bandwidth

INTERFACE=${1:-lo}
RATE=${2:-10mbit}  # 10 Mbit/s

# Limit bandwidth
sudo tc qdisc add dev $INTERFACE root tbf rate $RATE burst 32kbit latency 400ms

echo "Limited $INTERFACE to $RATE"
echo "To remove: sudo tc qdisc del dev $INTERFACE root"
EOF

chmod +x limit_bandwidth.sh

# Packet loss simulator
cat > simulate_packet_loss.sh <<'EOF'
#!/bin/bash
# Simulate packet loss

INTERFACE=${1:-lo}
LOSS=${2:-5}  # 5% packet loss

# Add packet loss
sudo tc qdisc add dev $INTERFACE root netem loss ${LOSS}%

echo "Added ${LOSS}% packet loss to $INTERFACE"
echo "To remove: sudo tc qdisc del dev $INTERFACE root"
EOF

chmod +x simulate_packet_loss.sh

print_status "Network testing utilities created in ~/ecliptica/network-tools/"

# 4. Setup Docker network for distributed testing
print_status "Creating Docker network for testing..."

# Create custom bridge network with proper MTU
docker network create \
    --driver bridge \
    --subnet=172.20.0.0/16 \
    --gateway=172.20.0.1 \
    --opt com.docker.network.driver.mtu=1500 \
    ecliptica-testnet || true

# 5. Create docker-compose for multi-node testing
cd ~/ecliptica
mkdir -p docker
cd docker

cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  # Validator nodes
  validator-1:
    image: ecliptica/validator:latest
    container_name: validator-1
    networks:
      ecliptica-testnet:
        ipv4_address: 172.20.0.11
    environment:
      - NODE_ID=1
      - VALIDATOR_KEY=${VALIDATOR_KEY_1}
      - BOOTSTRAP_PEERS=172.20.0.12:9000,172.20.0.13:9000
    ports:
      - "9001:9000"
      - "8001:8000"
    volumes:
      - validator-1-data:/data

  validator-2:
    image: ecliptica/validator:latest
    container_name: validator-2
    networks:
      ecliptica-testnet:
        ipv4_address: 172.20.0.12
    environment:
      - NODE_ID=2
      - VALIDATOR_KEY=${VALIDATOR_KEY_2}
      - BOOTSTRAP_PEERS=172.20.0.11:9000,172.20.0.13:9000
    ports:
      - "9002:9000"
      - "8002:8000"
    volumes:
      - validator-2-data:/data

  validator-3:
    image: ecliptica/validator:latest
    container_name: validator-3
    networks:
      ecliptica-testnet:
        ipv4_address: 172.20.0.13
    environment:
      - NODE_ID=3
      - VALIDATOR_KEY=${VALIDATOR_KEY_3}
      - BOOTSTRAP_PEERS=172.20.0.11:9000,172.20.0.12:9000
    ports:
      - "9003:9000"
      - "8003:8000"
    volumes:
      - validator-3-data:/data

  # Monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    networks:
      - ecliptica-testnet
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    networks:
      - ecliptica-testnet
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana-dashboards:/etc/grafana/provisioning/dashboards
    depends_on:
      - prometheus

networks:
  ecliptica-testnet:
    external: true

volumes:
  validator-1-data:
  validator-2-data:
  validator-3-data:
  prometheus-data:
  grafana-data:
EOF

# Create Prometheus configuration
cat > prometheus.yml <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'validators'
    static_configs:
      - targets:
        - 'validator-1:8000'
        - 'validator-2:8000'
        - 'validator-3:8000'
    metrics_path: '/metrics'
EOF

print_status "Docker Compose setup created"

# 6. Install Kubernetes (k3s) for advanced testing
print_status "Installing k3s (lightweight Kubernetes)..."

curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Add k3s to PATH
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc

print_status "k3s installed successfully"

# 7. Install network debugging tools
print_status "Installing network debugging tools..."

sudo apt install -y \
    tcpdump \
    wireshark-common \
    netcat \
    nmap \
    mtr \
    iperf3 \
    socat

# 8. Create distributed benchmark framework
cd ~/ecliptica
cargo new --lib distributed-bench
cd distributed-bench

cat >> Cargo.toml <<'EOF'

[dependencies]
tokio = { version = "1", features = ["full"] }
libp2p = { version = "0.53", features = ["tcp", "noise", "yamux", "gossipsub"] }
futures = "0.3"
tracing = "0.1"
tracing-subscriber = "0.3"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
chrono = "0.4"
clap = { version = "4", features = ["derive"] }

[dev-dependencies]
criterion = "0.5"
EOF

mkdir -p src/bin
cat > src/bin/distributed_test.rs <<'EOF'
//! Distributed consensus testing tool

use clap::Parser;
use std::time::Duration;
use tokio::time::sleep;

#[derive(Parser, Debug)]
#[command(author, version, about = "Distributed Ecliptica test framework")]
struct Args {
    /// Node ID
    #[arg(short, long)]
    node_id: usize,
    
    /// Total number of nodes
    #[arg(short, long, default_value_t = 3)]
    total_nodes: usize,
    
    /// Network latency simulation (ms)
    #[arg(short, long, default_value_t = 0)]
    latency: u64,
    
    /// Bootstrap peer addresses
    #[arg(short, long)]
    peers: Vec<String>,
}

#[tokio::main]
async fn main() {
    let args = Args::parse();
    
    println!("Starting Ecliptica test node {}/{}", args.node_id, args.total_nodes);
    println!("Network latency: {}ms", args.latency);
    println!("Bootstrap peers: {:?}", args.peers);
    
    // Simulate network latency
    if args.latency > 0 {
        sleep(Duration::from_millis(args.latency)).await;
    }
    
    // Run distributed test
    run_consensus_test(args.node_id, args.total_nodes, args.peers).await;
}

async fn run_consensus_test(node_id: usize, total_nodes: usize, _peers: Vec<String>) {
    println!("Node {} running consensus test with {} total nodes", node_id, total_nodes);
    
    // Placeholder for actual distributed testing logic
    for round in 1..=10 {
        println!("Node {}: Round {}", node_id, round);
        sleep(Duration::from_secs(1)).await;
    }
}
EOF

cargo build --release
print_status "Distributed benchmark framework created"

# 9. Create test orchestration scripts
cd ~/ecliptica/scripts

cat > run_distributed_test.sh <<'EOF'
#!/bin/bash
# Run distributed consensus test

NODES=${1:-3}
LATENCY=${2:-50}  # 50ms

echo "Starting $NODES test nodes with ${LATENCY}ms latency..."

# Start nodes in background
for i in $(seq 1 $NODES); do
    cargo run --release --bin distributed_test -- \
        --node-id $i \
        --total-nodes $NODES \
        --latency $LATENCY \
        --peers "localhost:900$((i+1))" &
done

# Wait for all nodes
wait

echo "Test complete"
EOF

chmod +x run_distributed_test.sh

# 10. Install monitoring dashboards
print_status "Setting up monitoring dashboards..."

cd ~/ecliptica/docker
mkdir -p grafana-dashboards

cat > grafana-dashboards/ecliptica-dashboard.json <<'EOF'
{
  "dashboard": {
    "title": "Ecliptica Network Metrics",
    "panels": [
      {
        "title": "Transaction Throughput",
        "targets": [
          {
            "expr": "rate(ecliptica_transactions_total[1m])"
          }
        ]
      },
      {
        "title": "Consensus Rounds",
        "targets": [
          {
            "expr": "ecliptica_consensus_round"
          }
        ]
      },
      {
        "title": "Network Latency",
        "targets": [
          {
            "expr": "histogram_quantile(0.99, rate(ecliptica_network_latency_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
EOF

print_status "Monitoring dashboards configured"

# 11. Summary
echo ""
echo "============================================"
print_status "Networking & distributed testing setup complete!"
echo "============================================"
echo ""
echo "Tools installed:"
echo "  - libp2p with full feature set"
echo "  - Network simulation (tc, toxiproxy, pumba)"
echo "  - Docker multi-node setup"
echo "  - k3s (Kubernetes)"
echo "  - Monitoring (Prometheus + Grafana)"
echo ""
echo "Usage examples:"
echo "  1. Simulate 100ms latency: ~/ecliptica/network-tools/simulate_latency.sh lo 100"
echo "  2. Run 3-node test: ~/ecliptica/scripts/run_distributed_test.sh 3 50"
echo "  3. Start Docker testnet: cd ~/ecliptica/docker && docker-compose up -d"
echo "  4. View metrics: http://localhost:3000 (Grafana)"
echo ""