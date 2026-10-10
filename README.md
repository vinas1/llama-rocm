# llama-rocm (Strix Halo / gfx1151)

<img width="1408" height="768" alt="image" src="https://github.com/user-attachments/assets/d7b7529e-fbbc-47fa-8f61-055276ffb460" />

[![GitHub stars](https://img.shields.io/github/stars/vinas1/llama-rocm?style=for-the-badge)](https://github.com/vinas1/llama-rocm/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/vinas1/llama-rocm?style=for-the-badge)](https://github.com/vinas1/llama-rocm/issues)
[![Hardware](https://img.shields.io/badge/Hardware-AMD%20ROCm%20Enabled-blue?style=for-the-badge)](https://rocm.amd.com/)
[![License](https://img.shields.io/github/license/vinas1/llama-rocm?style=for-the-badge)](https://github.com/vinas1/llama-rocm/blob/main/LICENSE)

> Unlock peak ROCm performance with a stable, dependency-optimized llama.cpp configuration engineered for local LLM inference on AMD hardware, including RDNA 3 and the `gfx1151` architecture on the AMD Ryzen AI Max systems (including 395 and 495 Strix Halo). This repository provides precise build targets and environment tuning designed to deliver CUDA-like stability on AMD platforms.

> *Note: Newer versions of LM Studio and bundled llama.cpp now include native upstream support for these architectures. [This tracking issue highlights how our project's initial discovery and tooling contributed directly to those native fixes.](https://github.com/vinas1/llama-rocm/issues/1) Custom builds remain fully supported for users looking to push maximum performance!*

## 🛠 Compatibility Matrix

| Component | Supported Baseline |
| :--- | :--- |
| **OS** | Linux / Ubuntu (Native Bare-Metal & WSL2) |
| **Platform** | AMD ROCm (Verified up to recent stable releases) |
| **Hardware** | AMD Ryzen AI Max+ 395 (RDNA 3 / gfx1151) and identical architectures |

## 🚀 Quick Start

```bash
git clone https://github.com/vinas1/llama-rocm && cd llama-rocm
chmod +x scripts/build_native_server.sh && ./scripts/build_native_server.sh
chmod +x scripts/lmstudio_start.sh && ./scripts/lmstudio_start.sh
```
**Repository:** https://github.com/vinas1/llama-rocm

---

## ✨ Features

* **Native `gfx1151` Support:** Compiled specifically for RDNA 3.5 APU architecture without relying on generic fallback targets.
* **Unified Memory Optimization:** Leverages shared LPDDR5X memory topology for high-context, large-parameter LLM inference.
* **Full Feature Parity:** Supports GGML tensor offloading, GQA acceleration, flash attention, and custom ROCm kernels.

## 📦 Installation & Usage

### Option 1: Pre-built Binary (Rex Systems)
For Rex systems, a pre-built binary is available: [llama-rocm-gfx1151-linux-x64.tar.gz](https://github.com/vinas1/llama-rocm/tree/main/binaries/).

```bash
mkdir -p ~/build/llama.cpp/build/bin/
tar -xzvf llama-rocm-gfx1151-linux-x64.tar.gz -C ~/build/llama.cpp/build/bin/
chmod +x scripts/lmstudio_start.sh && ./scripts/lmstudio_start.sh
```

### Option 2: Manual Build (Custom Hardware)
If you are not on a Rex system or wish to compile from source:

1. **Build the Native Server:**
   ```bash
   chmod +x scripts/build_native_server.sh && ./scripts/build_native_server.sh
   ```
2. **Start LM Studio with Auto-Patching:**
   ```bash
   chmod +x scripts/lmstudio_start.sh && ./scripts/lmstudio_start.sh
   ```

## ⚙️ Technical Deep Dive

### Why this is necessary
LM Studio's bundled ROCm backend binaries often lack optimized Tensile kernels and target memory mappings for newer AMD architectures like Strix Halo (`gfx1151`). This typically leads to register limits, GFXHUB memory allocation faults, and token output corruption (e.g., `<unused 49>` errors). 

This project compiles a native `llama-server` binary using your host system's ROCm libraries and patches LM Studio's extension vendor directory, granting maximum GPU acceleration and memory stability.

### Environment Overrides
The following overrides are used to bypass GFXHUB memory allocation faults and ring timeouts:
- `HSA_ENABLE_SDMA=0`: Disable System DMA to prevent GFXHUB memory/VGPR ring corruption.
- `AMD_SERIALIZE_KERNEL=3`: Serialize kernel execution to resolve async kernel race conditions.

### Build Configuration
- `-DGGML_HIPBLAS=ON`: AMD hardware acceleration.
- `-DAMDGPU_TARGETS=gfx1151`: Target Strix Halo APU architecture.
- `-DCMAKE_BUILD_TYPE=Release`: Aggressive optimizations.

## 📋 Prerequisites

* **OS:** Linux (Ubuntu 22.04/24.04 or Arch Linux recommended)
* **ROCm Version:** 6.x+ with `gfx1151` target runtime support
* **Dependencies:** `cmake`, `build-essential`, `hip-dev`, `rocblas-dev`
* **Hardware:** AMD Strix Halo APU (`gfx1151`) or Radeon RX 7900 series with unified VRAM.
* **LM Studio CLI:** Installed at `~/.lmstudio/bin/lms`

**Permissions Setup:**
Ensure your user is part of the necessary groups to access DRM and KFD devices:
```bash
sudo usermod -aG render,video $USER
```
