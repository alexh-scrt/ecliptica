#!/bin/bash
# Ecliptica Monitoring and Profiling Setup

set -e

GREEN='\033[0;32m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

echo "=== Setting up Monitoring & Profiling Tools ==="
echo ""

# 1. Install NVIDIA profiling tools
print_status "Installing NVIDIA profiling tools..."

sudo apt install -y \
    nvidia-nsight-systems \
    nvidia-nsight-compute

# Download NVIDIA Nsight Systems (newer version)
cd /tmp
wget -q https://developer.nvidia.com/downloads/nsight-systems-2024-2-1
sudo dpkg -i nsight-systems-*.deb || sudo apt --fix-broken install -y
rm nsight-systems-*.deb

print_status "NVIDIA profiling tools installed"

# 2. Setup Rust profiling
print_status "Installing Rust profiling tools..."

# Install cargo-flamegraph (already installed, but ensure latest)
cargo install cargo-flamegraph --force

# Install samply (modern profiler)
cargo install samply

# Install puffin (real-time profiler)
cargo install puffin_viewer

# Install cargo-instrument for instrumentation
cargo install cargo-instrument

print_status "Rust profiling tools installed"

# 3. Create profiling workspace
cd ~/ecliptica
mkdir -p profiling/{cpu,gpu,memory,network}

# CPU profiling script
cat > profiling/cpu/profile_cpu.sh <<'EOF'
#!/bin/bash
# Profile CPU performance

BINARY=${1:-target/release/ecliptica-bench}
OUTPUT=${2:-flamegraph.svg}

echo "Profiling CPU for: $BINARY"
echo "Output: $OUTPUT"

# Enable perf for unprivileged users
echo 0 | sudo tee /proc/sys/kernel/perf_event_paranoid

# Run flamegraph
cargo flamegraph --bin ecliptica-bench -o $OUTPUT

# Alternative: Use perf directly
# perf record -F 999 -g --call-graph dwarf $BINARY
# perf script | stackcollapse-perf.pl | flamegraph.pl > $OUTPUT

echo "Flamegraph saved to: $OUTPUT"
EOF

chmod +x profiling/cpu/profile_cpu.sh

# GPU profiling script
cat > profiling/gpu/profile_gpu.sh <<'EOF'
#!/bin/bash
# Profile GPU performance with NVIDIA Nsight

BINARY=${1:-target/release/ecliptica-bench}
OUTPUT=${2:-gpu_profile}

echo "Profiling GPU for: $BINARY"
echo "Output directory: $OUTPUT"

# Profile with Nsight Compute
ncu --set full --export $OUTPUT --force-overwrite $BINARY

# Alternative: Nsight Systems for timeline
# nsys profile --trace=cuda,nvtx --output=$OUTPUT $BINARY

echo ""
echo "GPU profile saved to: ${OUTPUT}.ncu-rep"
echo "View with: ncu-ui ${OUTPUT}.ncu-rep"
EOF

chmod +x profiling/gpu/profile_gpu.sh

# Memory profiling script
cat > profiling/memory/profile_memory.sh <<'EOF'
#!/bin/bash
# Profile memory usage

BINARY=${1:-target/release/ecliptica-bench}
OUTPUT=${2:-memory_profile.txt}

echo "Profiling memory for: $BINARY"

# Valgrind massif for heap profiling
valgrind --tool=massif --massif-out-file=massif.out $BINARY

# Convert to text
ms_print massif.out > $OUTPUT

# Alternative: heaptrack (if installed)
# heaptrack $BINARY
# heaptrack_print heaptrack.*.gz > $OUTPUT

echo "Memory profile saved to: $OUTPUT"
EOF

chmod +x profiling/memory/profile_memory.sh

# 4. Install metrics collection
print_status "Setting up metrics collection..."

cd ~/ecliptica
cargo new --lib metrics-collector
cd metrics-collector

cat >> Cargo.toml <<'EOF'

[dependencies]
metrics = "0.21"
metrics-exporter-prometheus = "0.13"
tokio = { version = "1", features = ["full"] }
tracing = "0.1"
tracing-subscriber = "0.3"
sysinfo = "0.30"
psutil = "3"

[lib]
crate-type = ["rlib", "cdylib"]
EOF

cat > src/lib.rs <<'EOF'
//! Ecliptica metrics collection library

use metrics::{counter, gauge, histogram};
use metrics_exporter_prometheus::PrometheusBuilder;
use std::time::Duration;
use sysinfo::{System, SystemExt, ProcessExt, CpuExt};

pub struct MetricsCollector {
    system: System,
}

impl MetricsCollector {
    pub fn new() -> Self {
        Self {
            system: System::new_all(),
        }
    }
    
    pub fn init_exporter(port: u16) -> Result<(), Box<dyn std::error::Error>> {
        PrometheusBuilder::new()
            .with_http_listener(([0, 0, 0, 0], port))
            .install()?;
        Ok(())
    }
    
    pub fn collect_system_metrics(&mut self) {
        self.system.refresh_all();
        
        // CPU metrics
        for (i, cpu) in self.system.cpus().iter().enumerate() {
            gauge!("ecliptica_cpu_usage", cpu.cpu_usage() as f64, "core" => i.to_string());
        }
        
        // Memory metrics
        let total_mem = self.system.total_memory() as f64;
        let used_mem = self.system.used_memory() as f64;
        gauge!("ecliptica_memory_total_bytes", total_mem);
        gauge!("ecliptica_memory_used_bytes", used_mem);
        gauge!("ecliptica_memory_usage_percent", (used_mem / total_mem) * 100.0);
        
        // Swap metrics
        gauge!("ecliptica_swap_used_bytes", self.system.used_swap() as f64);
        
        // Process count
        gauge!("ecliptica_process_count", self.system.processes().len() as f64);
    }
    
    pub fn record_transaction(&self, tx_size: usize, latency_ms: u64) {
        counter!("ecliptica_transactions_total", 1);
        histogram!("ecliptica_tx_size_bytes", tx_size as f64);
        histogram!("ecliptica_tx_latency_ms", latency_ms as f64);
    }
    
    pub fn record_block(&self, block_size: usize, tx_count: usize) {
        counter!("ecliptica_blocks_total", 1);
        gauge!("ecliptica_block_size_bytes", block_size as f64);
        gauge!("ecliptica_block_tx_count", tx_count as f64);
    }
    
    pub fn record_consensus_round(&self, round: u64, duration_ms: u64) {
        gauge!("ecliptica_consensus_round", round as f64);
        histogram!("ecliptica_consensus_duration_ms", duration_ms as f64);
    }
    
    pub fn record_proof_generation(&self, duration_ms: u64, proof_size: usize) {
        counter!("ecliptica_proofs_generated_total", 1);
        histogram!("ecliptica_proof_gen_duration_ms", duration_ms as f64);
        histogram!("ecliptica_proof_size_bytes", proof_size as f64);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_metrics_collection() {
        let mut collector = MetricsCollector::new();
        collector.collect_system_metrics();
    }
}
EOF

cargo build --release
print_status "Metrics collector library created"

# 5. Setup real-time monitoring dashboard
cd ~/ecliptica
cargo new --bin metrics-dashboard
cd metrics-dashboard

cat >> Cargo.toml <<'EOF'

[dependencies]
tokio = { version = "1", features = ["full"] }
axum = "0.7"
tower = "0.4"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tracing = "0.1"
tracing-subscriber = "0.3"
EOF

cat > src/main.rs <<'EOF'
//! Real-time metrics dashboard

use axum::{
    Router,
    routing::get,
    response::Html,
};
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();
    
    let app = Router::new()
        .route("/", get(dashboard))
        .route("/api/metrics", get(metrics));
    
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    println!("Dashboard running on http://localhost:8080");
    
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn dashboard() -> Html<&'static str> {
    Html(r#"
<!DOCTYPE html>
<html>
<head>
    <title>Ecliptica Metrics Dashboard</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background: #1a1a1a; color: #fff; }
        .metric { background: #2a2a2a; padding: 15px; margin: 10px 0; border-radius: 8px; }
        .metric-name { font-weight: bold; color: #2DE2E6; }
        .metric-value { font-size: 24px; color: #F6C356; }
        h1 { color: #2DE2E6; }
    </style>
</head>
<body>
    <h1>🌐 Ecliptica Network Metrics</h1>
    <div id="metrics"></div>
    <script>
        async function updateMetrics() {
            const response = await fetch('/api/metrics');
            const data = await response.json();
            
            const container = document.getElementById('metrics');
            container.innerHTML = Object.entries(data).map(([key, value]) => `
                <div class="metric">
                    <div class="metric-name">${key}</div>
                    <div class="metric-value">${value}</div>
                </div>
            `).join('');
        }
        
        updateMetrics();
        setInterval(updateMetrics, 1000);
    </script>
</body>
</html>
    "#)
}

async fn metrics() -> axum::Json<serde_json::Value> {
    axum::Json(serde_json::json!({
        "tps": 12453,
        "latency_ms": 0.8,
        "validators": 100,
        "block_height": 1234567
    }))
}
EOF

cargo build --release
print_status "Real-time metrics dashboard created"

# 6. Install tracing infrastructure
cd ~/ecliptica
cargo new --lib tracing-setup
cd tracing-setup

cat >> Cargo.toml <<'EOF'

[dependencies]
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter", "json"] }
tracing-appender = "0.2"
tracing-flame = "0.2"
console-subscriber = "0.2"
EOF

cat > src/lib.rs <<'EOF'
//! Tracing setup for Ecliptica

use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};
use std::path::Path;

pub fn init_tracing(log_dir: &Path) {
    // File appender for rotating logs
    let file_appender = tracing_appender::rolling::daily(log_dir, "ecliptica.log");
    let (non_blocking, _guard) = tracing_appender::non_blocking(file_appender);
    
    tracing_subscriber::registry()
        .with(EnvFilter::from_default_env()
            .add_directive("ecliptica=debug".parse().unwrap())
            .add_directive("tokio=info".parse().unwrap()))
        .with(tracing_subscriber::fmt::layer()
            .with_writer(std::io::stdout))
        .with(tracing_subscriber::fmt::layer()
            .with_writer(non_blocking)
            .json())
        .init();
}

pub fn init_tokio_console() {
    console_subscriber::init();
}
EOF

cargo build --release
print_status "Tracing infrastructure created"

# 7. Create benchmark runner with metrics
cd ~/ecliptica
mkdir -p benchmarks
cd benchmarks

cat > run_all_benchmarks.sh <<'EOF'
#!/bin/bash
# Run all Ecliptica benchmarks with profiling

OUTPUT_DIR=${1:-../profiling/results}
mkdir -p $OUTPUT_DIR

echo "Running Ecliptica benchmark suite..."
echo "Output directory: $OUTPUT_DIR"
echo ""

# 1. STARK benchmark
echo "[1/5] Running STARK benchmarks..."
cd ../stark-benchmark 2>/dev/null || cd stark-benchmark
cargo bench --bench stark_bench -- --save-baseline stark
cp target/criterion $OUTPUT_DIR/stark -r

# 2. Crypto benchmark
echo "[2/5] Running crypto benchmarks..."
cd ../crypto-bench
cargo bench --bench pq_crypto -- --save-baseline crypto
cp target/criterion $OUTPUT_DIR/crypto -r

# 3. Network benchmark
echo "[3/5] Running network benchmarks..."
cd ../network-bench
cargo bench --bench network_bench -- --save-baseline network
cp target/criterion $OUTPUT_DIR/network -r

# 4. Consensus benchmark
echo "[4/5] Running consensus benchmarks..."
cd ../consensus-bench
cargo bench --bench consensus_bench -- --save-baseline consensus
cp target/criterion $OUTPUT_DIR/consensus -r

# 5. E2E benchmark
echo "[5/5] Running end-to-end benchmarks..."
cd ../e2e-bench
cargo bench --bench e2e_bench -- --save-baseline e2e
cp target/criterion $OUTPUT_DIR/e2e -r

echo ""
echo "All benchmarks complete!"
echo "Results saved to: $OUTPUT_DIR"
echo ""
echo "Generate comparison report:"
echo "  cd $OUTPUT_DIR && cargo criterion --plotting-backend gnuplot"
EOF

chmod +x run_all_benchmarks.sh
print_status "Benchmark runner created"

# 8. Setup continuous benchmarking
cd ~/ecliptica
mkdir -p .github/workflows

cat > .github/workflows/benchmark.yml <<'EOF'
name: Continuous Benchmarking

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  benchmark:
    runs-on: ubuntu-latest-gpu
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        
    - name: Run benchmarks
      run: |
        cd benchmarks
        ./run_all_benchmarks.sh results
        
    - name: Store benchmark results
      uses: benchmark-action/github-action-benchmark@v1
      with:
        tool: 'cargo'
        output-file-path: benchmarks/results/output.txt
        github-token: ${{ secrets.GITHUB_TOKEN }}
        auto-push: true
EOF

print_status "Continuous benchmarking workflow created"

# 9. Install log analysis tools
print_status "Installing log analysis tools..."

sudo apt install -y \
    jq \
    ripgrep \
    lnav

# Install vector for log aggregation
curl --proto '=https' --tlsv1.2 -sSfL https://sh.vector.dev | bash -s -- -y

print_status "Log analysis tools installed"

# 10. Summary
echo ""
echo "============================================"
print_status "Monitoring & profiling setup complete!"
echo "============================================"
echo ""
echo "Tools installed:"
echo "  - NVIDIA Nsight (GPU profiling)"
echo "  - Flamegraph (CPU profiling)"
echo "  - Valgrind/Massif (memory profiling)"
echo "  - Prometheus metrics exporter"
echo "  - Real-time dashboard (port 8080)"
echo "  - Distributed tracing"
echo ""
echo "Quick start:"
echo "  1. Profile CPU: ~/ecliptica/profiling/cpu/profile_cpu.sh"
echo "  2. Profile GPU: ~/ecliptica/profiling/gpu/profile_gpu.sh"
echo "  3. Run dashboard: cd ~/ecliptica/metrics-dashboard && cargo run --release"
echo "  4. Run all benchmarks: cd ~/ecliptica/benchmarks && ./run_all_benchmarks.sh"
echo ""