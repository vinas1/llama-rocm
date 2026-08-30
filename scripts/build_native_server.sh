#!/bin/bash
set -e

echo "=== Starting Native llama-server Build for gfx1151 ==="

# 1. Dependency Setup (Optional check/install)
# sudo apt-get update && sudo apt-get install -y git cmake build-essential rocm-dev hip-runtime-amd

# 2. Repository Acquisition
BUILD_DIR="$HOME/build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d "llama.cpp" ]; then
    echo "Cloning llama.cpp..."
    git clone https://github.com/ggml-org/llama.cpp.git
fi
cd llama.cpp

# 3. CMake Build Configuration
echo "Configuring CMake for gfx1151..."
HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
cmake -B build \
  -DGGML_HIPBLAS=ON \
  -DAMDGPU_TARGETS=gfx1151 \
  -DCMAKE_BUILD_TYPE=Release

# 4. Binary Compilation
echo "Compiling binaries..."
cmake --build build --config Release -j$(nproc)

echo "=== Build Complete ==="
echo "Binary location: $BUILD_DIR/llama.cpp/build/bin/llama-server"

# 5. Shared Library Validation
echo "Validating shared libraries..."
ldd "$BUILD_DIR/llama.cpp/build/bin/llama-server" | grep -iE 'hip|rocm|amd' || echo "No ROCm libraries found in ldd output. Please check your ROCm installation."
