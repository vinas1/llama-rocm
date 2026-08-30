#!/bin/bash
LMS_CLI="$HOME/.lmstudio/bin/lms"

# ===================================================================
# 0. Hardware Overrides & Auto-Patching for Strix Halo (gfx1151)
# ===================================================================

# Export ROCm flags to prevent GFXHUB memory faults and SDMA ring crashes
export HSA_ENABLE_SDMA=0
export AMD_SERIALIZE_KERNEL=3

# Path to your custom-built native binary
# Defaulting to ~/build/llama.cpp/build/bin/llama-server as per the Howto
NATIVE_BINARY="$HOME/build/llama.cpp/build/bin/llama-server"

# Find LM Studio's active vendor backend directory
VENDOR_DIR=$(ls -d $HOME/.lmstudio/extensions/backends/vendor/linux-llama-rocm-vendor-* 2>/dev/null | tail -n 1)

if [ -n "$VENDOR_DIR" ] && [ -f "$NATIVE_BINARY" ]; then
    # Check if LM Studio's binary needs to be patched/updated
    if ! cmp -s "$NATIVE_BINARY" "$VENDOR_DIR/llama-server"; then
        echo "=== Auto-Patch: Updating LM Studio with native llama-server ==="
        cp -f "$NATIVE_BINARY" "$VENDOR_DIR/llama-server"
        chmod +x "$VENDOR_DIR/llama-server"
        echo "Native binary patch applied successfully."
    else
        echo "Native llama-server binary is up-to-date."
    fi
else
    echo "Warning: Native binary or Vendor directory not found. Skipping auto-patch."
    echo "Ensure you have run the build script and that LM Studio is installed."
fi

# ===================================================================
# 1. Daemon Startup & Server Operations
# ===================================================================

if $LMS_CLI daemon status | grep -q "running"; then
    echo "Daemon is already running. Skipping daemon up."
else
    echo "=== 1. Starting Standalone CLI Engine Daemon ==="
    $LMS_CLI daemon up
    sleep 7
fi

echo "Starting server on port 1234..."
$LMS_CLI server start --port 1234 --bind 0.0.0.0
$LMS_CLI link enable
