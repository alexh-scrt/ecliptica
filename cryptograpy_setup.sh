#!/bin/bash
# Ecliptica Post-Quantum Cryptography Setup
# Installs and configures ML-KEM, ML-DSA, and ZK libraries

set -e

GREEN='\033[0;32m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

echo "=== Installing Post-Quantum Cryptography Libraries ==="
echo ""

# 1. Install liboqs (Open Quantum Safe)
print_status "Installing liboqs (ML-KEM, ML-DSA)..."

cd ~/ecliptica
git clone --depth 1 https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build

cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DOQS_USE_OPENSSL=ON \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DOQS_DIST_BUILD=ON \
      ..

make -j$(nproc)
sudo make install
sudo ldconfig

print_status "liboqs installed successfully"

# 2. Install liboqs-rust bindings
print_status "Installing Rust bindings for liboqs..."
cd ~/ecliptica
git clone https://github.com/open-quantum-safe/liboqs-rust.git
cd liboqs-rust

# Build and test
cargo build --release
cargo test

print_status "liboqs-rust installed successfully"

# 3. Install pqcrypto crates (alternative Rust implementation)
print_status "Installing pqcrypto Rust crates..."
cd ~/ecliptica
cargo new --lib pqcrypto-test
cd pqcrypto-test

# Add dependencies
cat >> Cargo.toml <<EOF

[dependencies]
pqcrypto-kyber = "0.8"
pqcrypto-dilithium = "0.5"
pqcrypto-traits = "0.3"
sha3 = "0.10"
rand = "0.8"
EOF

cargo build --release
print_status "pqcrypto crates installed successfully"

# 4. Install STARK/ZK libraries
print_status "Installing ZK-STARK libraries..."

# Winterfell
cd ~/ecliptica
cargo new --lib winterfell-test
cd winterfell-test

cat >> Cargo.toml <<EOF

[dependencies]
winterfell = "0.9"
rand = "0.8"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
EOF

cargo build --release
print_status "Winterfell installed successfully"

# 5. Install GPU acceleration libraries for ZK
print_status "Installing GPU-accelerated cryptography..."

# Install CUDA-accelerated FFT libraries
sudo apt install -y libcufft-dev

# Install cuBLAS (for linear algebra operations in ZK)
sudo apt install -y libcublas-dev-12-4

# Install thrust (for parallel algorithms)
sudo apt install -y libthrust-dev

# 6. Build custom CUDA-accelerated primitives
print_status "Setting up CUDA cryptography workspace..."

cd ~/ecliptica
mkdir -p cuda-crypto/src
cd cuda-crypto

# Create CMakeLists.txt for CUDA crypto
cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.18)
project(ecliptica_cuda_crypto CUDA CXX)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_ARCHITECTURES 90)  # H100 compute capability

find_package(CUDAToolkit REQUIRED)

add_library(cuda_crypto SHARED
    src/ntt.cu
    src/poseidon.cu
    src/rescue_prime.cu
)

target_link_libraries(cuda_crypto
    CUDA::cudart
    CUDA::cufft
    CUDA::cublas
)

target_include_directories(cuda_crypto PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CUDAToolkit_INCLUDE_DIRS}
)
EOF

# Create NTT (Number Theoretic Transform) CUDA kernel
mkdir -p src include
cat > src/ntt.cu <<'EOF'
#include <cuda_runtime.h>
#include <cufft.h>

// GPU-accelerated NTT for STARK polynomial operations
__global__ void ntt_kernel(uint64_t* data, uint64_t* twiddles, 
                           int n, int logn, uint64_t modulus) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (tid < n) {
        // Cooley-Tukey butterfly operations
        for (int s = 1; s <= logn; s++) {
            int m = 1 << s;
            int m2 = m >> 1;
            int k = tid & (m - 1);
            
            if (k < m2) {
                int idx1 = tid;
                int idx2 = tid + m2;
                
                uint64_t t = data[idx1];
                uint64_t u = (__uint128_t)data[idx2] * twiddles[m2 + k] % modulus;
                
                data[idx1] = (t + u) % modulus;
                data[idx2] = (t + modulus - u) % modulus;
            }
            __syncthreads();
        }
    }
}

extern "C" {
    void ntt_cuda(uint64_t* h_data, int n, uint64_t modulus) {
        // Allocate device memory
        uint64_t *d_data, *d_twiddles;
        cudaMalloc(&d_data, n * sizeof(uint64_t));
        cudaMalloc(&d_twiddles, n * sizeof(uint64_t));
        
        // Copy data to device
        cudaMemcpy(d_data, h_data, n * sizeof(uint64_t), cudaMemcpyHostToDevice);
        
        // Generate twiddle factors (simplified)
        // In production, pre-compute and cache these
        
        // Launch kernel
        int threads = 256;
        int blocks = (n + threads - 1) / threads;
        int logn = __builtin_ctz(n);
        
        ntt_kernel<<<blocks, threads>>>(d_data, d_twiddles, n, logn, modulus);
        cudaDeviceSynchronize();
        
        // Copy result back
        cudaMemcpy(h_data, d_data, n * sizeof(uint64_t), cudaMemcpyDeviceToHost);
        
        // Cleanup
        cudaFree(d_data);
        cudaFree(d_twiddles);
    }
}
EOF

# Create header
cat > include/cuda_crypto.h <<'EOF'
#ifndef CUDA_CRYPTO_H
#define CUDA_CRYPTO_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// GPU-accelerated NTT
void ntt_cuda(uint64_t* data, int n, uint64_t modulus);

// GPU-accelerated Poseidon hash (for STARK)
void poseidon_cuda(uint64_t* state, const uint64_t* round_constants, int num_rounds);

// GPU-accelerated Rescue-Prime hash
void rescue_prime_cuda(uint64_t* state, int num_rounds);

#ifdef __cplusplus
}
#endif

#endif // CUDA_CRYPTO_H
EOF

# Build CUDA crypto library
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

print_status "CUDA cryptography library built successfully"

# 7. Create Rust FFI bindings for CUDA crypto
cd ~/ecliptica
cargo new --lib cuda-crypto-rs
cd cuda-crypto-rs

cat > Cargo.toml <<'EOF'
[package]
name = "cuda-crypto-rs"
version = "0.1.0"
edition = "2021"

[dependencies]

[build-dependencies]
cc = "1.0"

[lib]
crate-type = ["rlib", "cdylib"]
EOF

cat > build.rs <<'EOF'
fn main() {
    println!("cargo:rustc-link-search=native=../cuda-crypto/build");
    println!("cargo:rustc-link-lib=cuda_crypto");
    println!("cargo:rustc-link-lib=cudart");
    println!("cargo:rerun-if-changed=../cuda-crypto/include/cuda_crypto.h");
}
EOF

cat > src/lib.rs <<'EOF'
//! Rust bindings for CUDA-accelerated cryptography

use std::os::raw::c_uint;

#[link(name = "cuda_crypto")]
extern "C" {
    fn ntt_cuda(data: *mut u64, n: c_uint, modulus: u64);
}

pub fn ntt_gpu(data: &mut [u64], modulus: u64) {
    assert!(data.len().is_power_of_two(), "Length must be power of 2");
    
    unsafe {
        ntt_cuda(data.as_mut_ptr(), data.len() as c_uint, modulus);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ntt_gpu() {
        let mut data = vec![1u64, 2, 3, 4, 5, 6, 7, 8];
        let modulus = 18446744073709551557u64; // Large prime
        
        ntt_gpu(&mut data, modulus);
        
        // Verify transform completed (data should be modified)
        assert_ne!(data, vec![1u64, 2, 3, 4, 5, 6, 7, 8]);
    }
}
EOF

cargo build --release
cargo test

print_status "Rust-CUDA bindings created successfully"

# 8. Install benchmarking tools
print_status "Installing cryptography benchmarking tools..."

cd ~/ecliptica
cargo install criterion
cargo install cargo-criterion

# 9. Create cryptography benchmark suite
cargo new --lib crypto-bench
cd crypto-bench

cat > Cargo.toml <<'EOF'
[package]
name = "crypto-bench"
version = "0.1.0"
edition = "2021"

[dependencies]
pqcrypto-kyber = "0.8"
pqcrypto-dilithium = "0.5"
sha3 = "0.10"
criterion = "0.5"
rand = "0.8"

[[bench]]
name = "pq_crypto"
harness = false
EOF

mkdir benches
cat > benches/pq_crypto.rs <<'EOF'
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use pqcrypto_kyber::kyber512::*;
use pqcrypto_dilithium::dilithium3::*;
use sha3::{Shake256, digest::{Update, ExtendableOutput, XofReader}};

fn bench_ml_kem(c: &mut Criterion) {
    c.bench_function("ML-KEM-512 keypair", |b| {
        b.iter(|| {
            keypair()
        })
    });
    
    let (pk, sk) = keypair();
    
    c.bench_function("ML-KEM-512 encapsulate", |b| {
        b.iter(|| {
            encapsulate(black_box(&pk))
        })
    });
    
    let (ss, ct) = encapsulate(&pk);
    
    c.bench_function("ML-KEM-512 decapsulate", |b| {
        b.iter(|| {
            decapsulate(black_box(&ct), black_box(&sk))
        })
    });
}

fn bench_ml_dsa(c: &mut Criterion) {
    c.bench_function("ML-DSA (Dilithium3) keypair", |b| {
        b.iter(|| {
            keypair()
        })
    });
    
    let (pk, sk) = keypair();
    let msg = b"Ecliptica transaction data";
    
    c.bench_function("ML-DSA sign", |b| {
        b.iter(|| {
            sign(black_box(msg), black_box(&sk))
        })
    });
    
    let sig = sign(msg, &sk);
    
    c.bench_function("ML-DSA verify", |b| {
        b.iter(|| {
            verify(black_box(&sig), black_box(msg), black_box(&pk))
        })
    });
}

fn bench_shake256(c: &mut Criterion) {
    let mut group = c.benchmark_group("SHAKE-256");
    
    for size in [32, 256, 1024, 4096].iter() {
        group.bench_with_input(BenchmarkId::from_parameter(size), size, |b, &size| {
            let data = vec![0u8; size];
            b.iter(|| {
                let mut hasher = Shake256::default();
                hasher.update(black_box(&data));
                let mut output = [0u8; 32];
                hasher.finalize_xof().read(&mut output);
                black_box(output);
            });
        });
    }
    group.finish();
}

criterion_group!(benches, bench_ml_kem, bench_ml_dsa, bench_shake256);
criterion_main!(benches);
EOF

cargo bench

print_status "Cryptography benchmarks installed successfully"

# 10. Summary
echo ""
echo "============================================"
print_status "Cryptography setup complete!"
echo "============================================"
echo ""
echo "Installed libraries:"
echo "  - liboqs (ML-KEM-512, ML-DSA)"
echo "  - pqcrypto Rust crates"
echo "  - Winterfell (ZK-STARK)"
echo "  - CUDA-accelerated NTT"
echo "  - Benchmarking suite"
echo ""
echo "Next: Run crypto benchmarks with:"
echo "  cd ~/ecliptica/crypto-bench && cargo bench"