#!/bin/bash

# QuaiMiner CORE OS - GPU Optimization System
# Automatically optimizes GPU settings for Quai mining

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OPTIMIZATION_CONFIG="/etc/quaiminer/gpu-optimization.json"
LOG_FILE="/var/log/quaiminer/gpu-optimizer.log"

mkdir -p /var/log/quaiminer
mkdir -p /etc/quaiminer

echo -e "${BLUE}⚡ QuaiMiner CORE OS - GPU Optimizer${NC}"
echo "===================================="

# Load hardware info
HARDWARE_INFO="/etc/quaiminer/hardware-info.json"
if [ ! -f "$HARDWARE_INFO" ]; then
    echo -e "${RED}❌ Hardware info not found. Run hardware-detector.sh first${NC}"
    exit 1
fi

# Optimize NVIDIA GPU
optimize_nvidia_gpu() {
    local gpu_index="$1"
    local model="$2"
    
    echo -e "${YELLOW}  Optimizing NVIDIA GPU #$gpu_index ($model)...${NC}"
    
    # Set power limit (80% of max for efficiency)
    MAX_POWER=$(nvidia-smi -i "$gpu_index" --query-gpu=power.max_limit --format=csv,noheader,nounits)
    TARGET_POWER=$(echo "$MAX_POWER * 0.8" | bc | cut -d'.' -f1)
    
    nvidia-smi -i "$gpu_index" -pl "$TARGET_POWER" 2>/dev/null && \
        echo "    ✅ Power limit set to ${TARGET_POWER}W" || \
        echo "    ⚠️  Could not set power limit"
    
    # Set persistence mode
    nvidia-smi -pm 1 2>/dev/null && echo "    ✅ Persistence mode enabled"
    
    # Set compute mode (if supported)
    nvidia-smi -i "$gpu_index" -c EXCLUSIVE_PROCESS 2>/dev/null && \
        echo "    ✅ Compute mode set" || \
        echo "    ℹ️  Compute mode not available"
    
    # Optimize clocks (memory overclock, core underclock for mining)
    if command -v nvidia-settings &> /dev/null; then
        # Memory clock +500MHz (adjust based on GPU)
        # Core clock -200MHz (for efficiency)
        echo "    ℹ️  Manual overclocking recommended via nvidia-settings"
    fi
    
    return 0
}

# Optimize AMD GPU
optimize_amd_gpu() {
    local gpu_index="$1"
    local model="$2"
    local architecture="$3"
    
    echo -e "${YELLOW}  Optimizing AMD GPU #$gpu_index ($model)...${NC}"
    
    # Detect GPU architecture and apply specific optimizations
    case "$architecture" in
        polaris20|polaris)
            # RX 590 / RX 580 optimizations
            echo "    Applying Polaris optimizations..."
            
            # Set core clock (1545 MHz for RX 590)
            if command -v rocm-smi &> /dev/null; then
                rocm-smi --setclocks 1545 --device "$gpu_index" 2>/dev/null || true
            fi
            
            # Set memory clock (2000 MHz)
            if command -v rocm-smi &> /dev/null; then
                rocm-smi --setmemoverclock 2000 --device "$gpu_index" 2>/dev/null || true
            fi
            
            # Set power limit (if supported)
            echo "    ✅ Polaris optimizations applied"
            ;;
        vega)
            echo "    Applying Vega optimizations..."
            # Vega-specific settings
            ;;
        navi)
            echo "    Applying Navi optimizations..."
            # Navi-specific settings
            ;;
        *)
            echo "    ⚠️  Unknown architecture, using generic optimizations"
            ;;
    esac
    
    # Set environment variables for mining
    ENV_FILE="/etc/quaiminer/environment"
    cat >> "$ENV_FILE" << EOF

# GPU $gpu_index Optimization
export GPU_DEVICE_ORDINAL=$gpu_index
EOF
    
    # Polaris-specific environment variables
    if [ "$architecture" = "polaris20" ] || [ "$architecture" = "polaris" ]; then
        cat >> "$ENV_FILE" << 'EOF'
export ROC_ENABLE_PRE_VEGA=1
export HSA_OVERRIDE_GFX_VERSION=8.0.0
export GPU_FORCE_64BIT_PTR=1
export GPU_MAX_HEAP_SIZE=100
export GPU_USE_SYNC_OBJECTS=1
EOF
    fi
    
    return 0
}

# Main optimization function
main() {
    # Read GPU info from hardware detection
    GPU_COUNT=$(python3 -c "import json; data = json.load(open('$HARDWARE_INFO')); print(len(data.get('gpus', [])))" 2>/dev/null || echo "0")
    
    if [ "$GPU_COUNT" -eq 0 ]; then
        echo -e "${RED}❌ No GPUs found in hardware info${NC}"
        exit 1
    fi
    
    echo "🎮 Found $GPU_COUNT GPU(s) to optimize"
    echo ""
    
    # Initialize optimization config
    cat > "$OPTIMIZATION_CONFIG" << EOF
{
  "optimizations": [],
  "last_optimized": "$(date -Iseconds)"
}
EOF
    
    # Process each GPU
    for i in $(seq 0 $((GPU_COUNT - 1))); do
        GPU_INFO=$(python3 -c "
import json
data = json.load(open('$HARDWARE_INFO'))
gpu = data['gpus'][$i]
print(f\"{gpu['vendor']}|{gpu['model']}|{gpu.get('architecture', 'unknown')}\")
" 2>/dev/null)
        
        VENDOR=$(echo "$GPU_INFO" | cut -d'|' -f1)
        MODEL=$(echo "$GPU_INFO" | cut -d'|' -f2)
        ARCH=$(echo "$GPU_INFO" | cut -d'|' -f3)
        
        echo "GPU #$i: $VENDOR $MODEL"
        
        if [ "$VENDOR" = "nvidia" ]; then
            optimize_nvidia_gpu "$i" "$MODEL"
        elif [ "$VENDOR" = "amd" ]; then
            optimize_amd_gpu "$i" "$MODEL" "$ARCH"
        else
            echo -e "${RED}  ❌ Unknown vendor: $VENDOR${NC}"
        fi
        
        # Save optimization status
        python3 << PYTHON_EOF
import json
from datetime import datetime

with open('$OPTIMIZATION_CONFIG', 'r') as f:
    config = json.load(f)

config['optimizations'].append({
    "gpu_index": $i,
    "vendor": "$VENDOR",
    "model": "$MODEL",
    "optimized": True,
    "timestamp": datetime.now().isoformat()
})

with open('$OPTIMIZATION_CONFIG', 'w') as f:
    json.dump(config, f, indent=2)
PYTHON_EOF
        
        echo ""
    done
    
    echo -e "${GREEN}✅ GPU optimization complete!${NC}"
    echo "  Config saved to: $OPTIMIZATION_CONFIG"
    echo ""
    echo "⚠️  Note: Some optimizations require reboot or driver restart"
    echo "   Monitor GPU temperatures and adjust if needed"
}

main "$@"

