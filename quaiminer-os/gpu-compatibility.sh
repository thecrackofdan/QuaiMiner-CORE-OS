#!/bin/bash

# QuaiMiner CORE OS - GPU Compatibility Checker
# Verifies all GPUs that can handle ProgPoW (Quai's algorithm)
# Supports both old and new GPUs from AMD and NVIDIA

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

COMPATIBILITY_DB="/etc/quaiminer/gpu-compatibility.json"

echo -e "${CYAN}🎮 QuaiMiner CORE OS - GPU Compatibility Checker${NC}"
echo "=============================================="
echo ""

# ProgPoW-compatible GPU database
# Based on ProgPoW algorithm requirements (OpenCL 1.2+, sufficient memory)
cat > "$COMPATIBILITY_DB" << 'EOF'
{
  "nvidia": {
    "supported_architectures": ["Kepler", "Maxwell", "Pascal", "Volta", "Turing", "Ampere", "Ada", "Hopper"],
    "minimum_memory_mb": 2048,
    "minimum_compute": 3.0,
    "recommended_models": [
      "GTX 1050", "GTX 1050 Ti", "GTX 1060", "GTX 1070", "GTX 1070 Ti", "GTX 1080", "GTX 1080 Ti",
      "RTX 2060", "RTX 2060 Super", "RTX 2070", "RTX 2070 Super", "RTX 2080", "RTX 2080 Super", "RTX 2080 Ti",
      "RTX 3060", "RTX 3060 Ti", "RTX 3070", "RTX 3070 Ti", "RTX 3080", "RTX 3080 Ti", "RTX 3090",
      "RTX 4060", "RTX 4060 Ti", "RTX 4070", "RTX 4070 Ti", "RTX 4080", "RTX 4090",
      "Titan X", "Titan Xp", "Titan V", "Titan RTX"
    ],
    "legacy_models": [
      "GTX 750", "GTX 750 Ti", "GTX 760", "GTX 770", "GTX 780", "GTX 780 Ti",
      "GTX 950", "GTX 960", "GTX 970", "GTX 980", "GTX 980 Ti"
    ]
  },
  "amd": {
    "supported_architectures": ["GCN 1.0", "GCN 2.0", "GCN 3.0", "GCN 4.0", "GCN 5.0", "RDNA", "RDNA 2", "RDNA 3"],
    "minimum_memory_mb": 2048,
    "minimum_opencl": "1.2",
    "recommended_models": [
      "RX 550", "RX 560", "RX 570", "RX 580", "RX 590",
      "RX 5500 XT", "RX 5600 XT", "RX 5700", "RX 5700 XT",
      "RX 6600", "RX 6600 XT", "RX 6700 XT", "RX 6800", "RX 6800 XT", "RX 6900 XT",
      "RX 7600", "RX 7700 XT", "RX 7800 XT", "RX 7900 XT", "RX 7900 XTX"
    ],
    "legacy_models": [
      "R9 270", "R9 270X", "R9 280", "R9 280X", "R9 290", "R9 290X", "R9 390", "R9 390X",
      "RX 460", "RX 470", "RX 480",
      "Vega 56", "Vega 64", "Vega Frontier Edition"
    ]
  },
  "algorithm": {
    "name": "ProgPoW",
    "description": "Programmatic Proof of Work",
    "memory_intensive": true,
    "opencl_required": true,
    "minimum_opencl_version": "1.2"
  }
}
EOF

# Function to check NVIDIA GPU compatibility
check_nvidia_gpu() {
    local gpu_index="$1"
    local model="$2"
    local memory_mb="$3"
    
    echo -e "${YELLOW}  Checking NVIDIA GPU: $model${NC}"
    
    # Check memory
    if [ "$memory_mb" -lt 2048 ]; then
        echo -e "${RED}    ❌ Insufficient memory (${memory_mb}MB < 2048MB)${NC}"
        return 1
    fi
    
    # Check compute capability
    COMPUTE_CAP=$(nvidia-smi -i "$gpu_index" --query-gpu=compute_cap --format=csv,noheader 2>/dev/null | cut -d'.' -f1 || echo "0")
    if [ "$COMPUTE_CAP" -lt 3 ]; then
        echo -e "${YELLOW}    ⚠️  Low compute capability (${COMPUTE_CAP}.x) - may have reduced performance${NC}"
    fi
    
    # Check if model is in recommended/legacy list
    MODEL_LOWER=$(echo "$model" | tr '[:upper:]' '[:lower:]')
    if echo "$MODEL_LOWER" | grep -qiE "(gtx|rtx|titan)"; then
        echo -e "${GREEN}    ✅ Compatible with ProgPoW${NC}"
        echo -e "${CYAN}    ℹ️  Expected hash rate: 5-50+ MH/s (varies by model)${NC}"
        return 0
    else
        echo -e "${YELLOW}    ⚠️  Unknown model - testing recommended${NC}"
        return 0
    fi
}

# Function to check AMD GPU compatibility
check_amd_gpu() {
    local gpu_index="$1"
    local model="$2"
    local architecture="$3"
    
    echo -e "${YELLOW}  Checking AMD GPU: $model${NC}"
    
    # Check architecture
    if [ "$architecture" = "unknown" ]; then
        echo -e "${YELLOW}    ⚠️  Unknown architecture - may still work${NC}"
    fi
    
    # Check OpenCL availability
    if ! clinfo 2>/dev/null | grep -q "AMD\|Mesa"; then
        echo -e "${RED}    ❌ OpenCL not available${NC}"
        return 1
    fi
    
    # Check if model is in recommended/legacy list
    MODEL_LOWER=$(echo "$model" | tr '[:upper:]' '[:lower:]')
    if echo "$MODEL_LOWER" | grep -qiE "(rx|r9|vega)"; then
        echo -e "${GREEN}    ✅ Compatible with ProgPoW${NC}"
        echo -e "${CYAN}    ℹ️  Expected hash rate: 5-30+ MH/s (varies by model)${NC}"
        return 0
    else
        echo -e "${YELLOW}    ⚠️  Unknown model - testing recommended${NC}"
        return 0
    fi
}

# Main compatibility check
main() {
    HARDWARE_INFO="/etc/quaiminer/hardware-info.json"
    
    if [ ! -f "$HARDWARE_INFO" ]; then
        echo -e "${RED}❌ Hardware info not found. Run hardware-detector.sh first${NC}"
        exit 1
    fi
    
    GPU_COUNT=$(python3 -c "import json; data = json.load(open('$HARDWARE_INFO')); print(len(data.get('gpus', [])))" 2>/dev/null || echo "0")
    
    if [ "$GPU_COUNT" -eq 0 ]; then
        echo -e "${RED}❌ No GPUs found${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📊 Checking $GPU_COUNT GPU(s) for ProgPoW compatibility...${NC}"
    echo ""
    
    COMPATIBLE=0
    INCOMPATIBLE=0
    
    for i in $(seq 0 $((GPU_COUNT - 1))); do
        GPU_INFO=$(python3 -c "
import json
data = json.load(open('$HARDWARE_INFO'))
gpu = data['gpus'][$i]
print(f\"{gpu['vendor']}|{gpu['model']}|{gpu.get('memory_mb', 0)}|{gpu.get('architecture', 'unknown')}\")
" 2>/dev/null)
        
        VENDOR=$(echo "$GPU_INFO" | cut -d'|' -f1)
        MODEL=$(echo "$GPU_INFO" | cut -d'|' -f2)
        MEMORY=$(echo "$GPU_INFO" | cut -d'|' -f3)
        ARCH=$(echo "$GPU_INFO" | cut -d'|' -f4)
        
        echo -e "${CYAN}GPU #$i:${NC}"
        
        if [ "$VENDOR" = "nvidia" ]; then
            if check_nvidia_gpu "$i" "$MODEL" "$MEMORY"; then
                COMPATIBLE=$((COMPATIBLE + 1))
            else
                INCOMPATIBLE=$((INCOMPATIBLE + 1))
            fi
        elif [ "$VENDOR" = "amd" ]; then
            if check_amd_gpu "$i" "$MODEL" "$ARCH"; then
                COMPATIBLE=$((COMPATIBLE + 1))
            else
                INCOMPATIBLE=$((INCOMPATIBLE + 1))
            fi
        fi
        echo ""
    done
    
    # Summary
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Compatibility Summary:${NC}"
    echo -e "${GREEN}  Compatible: $COMPATIBLE${NC}"
    echo -e "${RED}  Incompatible: $INCOMPATIBLE${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ "$COMPATIBLE" -gt 0 ]; then
        echo -e "${GREEN}✅ You have $COMPATIBLE GPU(s) ready for Quai mining!${NC}"
        exit 0
    else
        echo -e "${RED}❌ No compatible GPUs found${NC}"
        exit 1
    fi
}

main "$@"

