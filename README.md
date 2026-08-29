# llama-rocm (Strix Halo / gfx1151)

Native `llama.cpp` build optimized for AMD Strix Halo APUs (`gfx1151`), bringing ROCm acceleration and feature parity on Linux to NVIDIA CUDA and Apple Silicon setups.

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
