# llama-rocm (Strix Halo / gfx1151)

<img width="1408" height="768" alt="image" src="https://github.com/user-attachments/assets/d7b7529e-fbbc-47fa-8f61-055276ffb460" />



Native `llama.cpp` build optimized for AMD Strix Halo APUs (`gfx1151`), bringing ROCm acceleration and feature parity on Linux to NVIDIA CUDA and Apple Silicon setups in LM Studio via a custom llama.cpp engine.

---

## Features

* **Native `gfx1151` Support:** Compiled specifically for RDNA 3.5 APU architecture without relying on generic fallback targets.
* **Unified Memory Optimization:** Leverages shared LPDDR5X memory topology for high-context, large-parameter LLM inference.
* **Full Feature Parity:** Supports GGML tensor offloading, GQA acceleration, flash attention, and custom ROCm kernels.

---

## Prerequisites

* **OS:** Linux (Ubuntu 22.04/24.04 or Arch Linux recommended)
* **ROCm Version:** 6.x+ with `gfx1151` target runtime support
* **Dependencies:** `cmake`, `build-essential`, `hip-dev`, `rocblas-dev`

Ensure your user is part of the necessary groups to access DRM and KFD devices:

```bash
sudo usermod -aG render,video $USER
```

## Patching LM Studio with Native ROCm llama-server (AMD Strix Halo / gfx1151)

## Why this is cool

LM Studio's bundled ROCm backend binaries lack optimized Tensile kernels and target memory mappings for newer AMD architectures like Strix Halo (gfx1151). This missing hardware support leads to register limits, GFXHUB memory allocation faults, and token output corruption like <unused 49> errors, especially on complex architectures like Gemma 4.

This procedure compiles a native llama-server binary using your host system's ROCm libraries and patches LM Studio's extension vendor directory. This grants maximum GPU acceleration and memory stability while preserving full LM Link network routing to remote devices (e.g., MacBook Pro).

## 🚀 Quick Start for Rex Systems

For Rex systems, a pre-built binary is already available in this repository: `llama-rocm-gfx1151-linux-x64.tar.gz`.

To use the pre-built binary:
1. Extract the archive to the expected build path:
   ```bash
   mkdir -p ~/build/llama.cpp/build/bin/
   tar -xzvf llama-rocm-gfx1151-linux-x64.tar.gz -C ~/build/llama.cpp/build/bin/
   ```
2. Run the startup script to apply the patch and start LM Studio:
   ```bash
   chmod +x scripts/lmstudio_start.sh
   ./scripts/lmstudio_start.sh
   ```

## Prerequisites

* **Hardware:** AMD Strix Halo APU (gfx1151) with unified VRAM.  
* **OS / Environment:** Linux with ROCm 7.x installed (hipcc, hipconfig available in system $PATH).  
* **LM Studio CLI:** Installed at ~/.lmstudio/bin/lms.  
* **Build Tools:** git, cmake, gcc, g++, make.

## Installation & Usage (Manual Build)

If you are not on a Rex system or wish to compile from source:

### 1. Build the Native Server
Run the provided build script to compile `llama.cpp` for your architecture:
```bash
chmod +x scripts/build_native_server.sh
./scripts/build_native_server.sh
```

### 2. Start LM Studio with Auto-Patching
Use the startup script to apply the patch and start the server:
```bash
chmod +x scripts/lmstudio_start.sh
./scripts/lmstudio_start.sh
```

## Technical Details

### Environment Overrides
The following ROCm environment overrides are used to bypass GFXHUB memory allocation faults and ring timeouts:
- `HSA_ENABLE_SDMA=0`: Disable System DMA to prevent GFXHUB memory/VGPR ring corruption.
- `AMD_SERIALIZE_KERNEL=3`: Serialize kernel execution to resolve async kernel race conditions.

### Build Configuration
The server is built with:
- `-DGGML_HIPBLAS=ON`: AMD hardware acceleration.
- `-DAMDGPU_TARGETS=gfx1151`: Target Strix Halo APU architecture.
- `-DCMAKE_BUILD_TYPE=Release`: Aggressive optimizations.
