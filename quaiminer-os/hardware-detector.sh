#!/bin/bash

# QuaiMiner CORE OS - Hardware Auto-Detection System
# Detects GPUs, CPUs, memory, and system information for multi-GPU/multi-rig support

set -e

# Output file for hardware info
HARDWARE_INFO_FILE="/etc/quaiminer/hardware-info.json"
TEMP_INFO_FILE="/tmp/quaiminer-hardware-scan.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 QuaiMiner CORE OS - Hardware Detection${NC}"
echo "=========================================="

# Create temp directory
mkdir -p /tmp/quaiminer-detection
mkdir -p /etc/quaiminer

# Initialize JSON structure
cat > "$TEMP_INFO_FILE" << 'EOF'
{
  "system": {},
  "cpus": [],
  "gpus": [],
  "memory": {},
  "detection_time": "",
  "rig_id": ""
}
EOF

# Function to add JSON field
add_json_field() {
    local key="$1"
    local value="$2"
    local file="$3"
    python3 -c "
import json
import sys
with open('$file', 'r') as f:
    data = json.load(f)
data['$key'] = $value
with open('$file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || {
    # Fallback using jq if available
    if command -v jq &> /dev/null; then
        jq ".$key = $value" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    fi
}
}

# Function to add to array
add_to_array() {
    local array_key="$1"
    local json_value="$2"
    local file="$3"
    python3 -c "
import json
with open('$file', 'r') as f:
    data = json.load(f)
if '$array_key' not in data:
    data['$array_key'] = []
data['$array_key'].append($json_value)
with open('$file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || {
    if command -v jq &> /dev/null; then
        jq ".$array_key += [$json_value]" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    fi
}
}

# Detect System Information
echo -e "${YELLOW}📋 Detecting system information...${NC}"

# OS Information
if command -v lsb_release &> /dev/null; then
    OS_NAME=$(lsb_release -si)
    OS_VERSION=$(lsb_release -sr)
    OS_CODENAME=$(lsb_release -sc)
else
    OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    OS_VERSION=$(grep "^VERSION_ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    OS_CODENAME=$(grep "^VERSION_CODENAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
fi

KERNEL_VERSION=$(uname -r)
ARCHITECTURE=$(uname -m)
HOSTNAME=$(hostname)

# Generate unique rig ID
RIG_ID="${HOSTNAME}-$(cat /etc/machine-id 2>/dev/null | cut -c1-8 || echo $(date +%s))"

echo "  OS: $OS_NAME $OS_VERSION ($OS_CODENAME)"
echo "  Kernel: $KERNEL_VERSION"
echo "  Architecture: $ARCHITECTURE"
echo "  Rig ID: $RIG_ID"

# Update JSON
python3 << PYTHON_EOF
import json
import datetime

with open('$TEMP_INFO_FILE', 'r') as f:
    data = json.load(f)

data['system'] = {
    "os_name": "$OS_NAME",
    "os_version": "$OS_VERSION",
    "os_codename": "$OS_CODENAME",
    "kernel": "$KERNEL_VERSION",
    "architecture": "$ARCHITECTURE",
    "hostname": "$HOSTNAME"
}
data['rig_id'] = "$RIG_ID"
data['detection_time'] = datetime.datetime.now().isoformat()

with open('$TEMP_INFO_FILE', 'w') as f:
    json.dump(data, f, indent=2)
PYTHON_EOF

# Detect CPU Information
echo -e "${YELLOW}💻 Detecting CPU information...${NC}"

CPU_COUNT=$(nproc)
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
CPU_CORES=$(grep -c "^processor" /proc/cpuinfo)
CPU_THREADS=$(grep "siblings" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)

echo "  CPU: $CPU_MODEL"
echo "  Cores: $CPU_CORES"
echo "  Threads: $CPU_THREADS"

python3 << PYTHON_EOF
import json

with open('$TEMP_INFO_FILE', 'r') as f:
    data = json.load(f)

data['cpus'].append({
    "model": "$CPU_MODEL",
    "cores": int("$CPU_CORES"),
    "threads": int("$CPU_THREADS"),
    "count": int("$CPU_COUNT")
})

with open('$TEMP_INFO_FILE', 'w') as f:
    json.dump(data, f, indent=2)
PYTHON_EOF

# Detect Memory Information
echo -e "${YELLOW}💾 Detecting memory information...${NC}"

TOTAL_MEM=$(free -g | grep "^Mem:" | awk '{print $2}')
AVAILABLE_MEM=$(free -g | grep "^Mem:" | awk '{print $7}')

echo "  Total RAM: ${TOTAL_MEM}GB"
echo "  Available: ${AVAILABLE_MEM}GB"

python3 << PYTHON_EOF
import json

with open('$TEMP_INFO_FILE', 'r') as f:
    data = json.load(f)

data['memory'] = {
    "total_gb": int("$TOTAL_MEM"),
    "available_gb": int("$AVAILABLE_MEM")
}

with open('$TEMP_INFO_FILE', 'w') as f:
    json.dump(data, f, indent=2)
PYTHON_EOF

# Detect GPUs
echo -e "${YELLOW}🎮 Detecting GPUs...${NC}"

GPU_COUNT=0

# Detect NVIDIA GPUs
if command -v nvidia-smi &> /dev/null; then
    echo "  Checking for NVIDIA GPUs..."
    NVIDIA_COUNT=$(nvidia-smi --list-gpus 2>/dev/null | wc -l || echo "0")
    
    if [ "$NVIDIA_COUNT" -gt 0 ]; then
        nvidia-smi --query-gpu=index,name,memory.total,driver_version,temperature.gpu,power.draw --format=csv,noheader,nounits | while IFS=',' read -r index name memory driver temp power; do
            GPU_COUNT=$((GPU_COUNT + 1))
            echo "  ✅ NVIDIA GPU #$GPU_COUNT: $(echo $name | xargs)"
            
            python3 << PYTHON_EOF
import json

with open('$TEMP_INFO_FILE', 'r') as f:
    data = json.load(f)

gpu_info = {
    "index": int("$GPU_COUNT") - 1,
    "vendor": "nvidia",
    "model": "$(echo $name | xargs)",
    "memory_mb": int("$(echo $memory | xargs | cut -d' ' -f1)"),
    "driver_version": "$(echo $driver | xargs)",
    "temperature": int("$(echo $temp | xargs)" || 0),
    "power_watts": float("$(echo $power | xargs | cut -d' ' -f1)" || 0),
    "pci_id": "",
    "opencl_available": False,
    "optimized": False
}

data['gpus'].append(gpu_info)

with open('$TEMP_INFO_FILE', 'w') as f:
    json.dump(data, f, indent=2)
PYTHON_EOF
        done
    fi
fi

# Detect AMD GPUs (after NVIDIA to get correct indexing)
if command -v lspci &> /dev/null; then
    echo "  Checking for AMD GPUs..."
    AMD_GPUS=$(lspci | grep -i "VGA\|3D\|Display" | grep -i "AMD\|ATI\|Radeon" || true)
    
    if [ -n "$AMD_GPUS" ]; then
        # Get current GPU count (after NVIDIA detection)
        CURRENT_GPU_COUNT=$(python3 -c "import json; data = json.load(open('$TEMP_INFO_FILE')); print(len(data.get('gpus', [])))" 2>/dev/null || echo "0")
        GPU_INDEX=$CURRENT_GPU_COUNT
        
        echo "$AMD_GPUS" | while IFS= read -r line; do
            GPU_COUNT=$((GPU_COUNT + 1))
            
            PCI_ID=$(echo "$line" | awk '{print $1}')
            GPU_MODEL=$(echo "$line" | sed 's/.*: //')
            
            echo "  ✅ AMD GPU #$GPU_INDEX: $GPU_MODEL"
            
            # Check OpenCL availability
            OPENCL_AVAILABLE=false
            if command -v clinfo &> /dev/null; then
                if clinfo 2>/dev/null | grep -q "AMD\|Radeon"; then
                    OPENCL_AVAILABLE=true
                fi
            fi
            
            # Detect GPU architecture (comprehensive detection for all AMD GPUs)
            ARCHITECTURE="unknown"
            if echo "$GPU_MODEL" | grep -qi "RX 590\|Polaris 20"; then
                ARCHITECTURE="polaris20"
            elif echo "$GPU_MODEL" | grep -qi "RX 580\|RX 570\|RX 560\|RX 550\|Polaris"; then
                ARCHITECTURE="polaris"
            elif echo "$GPU_MODEL" | grep -qi "RX 480\|RX 470\|RX 460"; then
                ARCHITECTURE="polaris"
            elif echo "$GPU_MODEL" | grep -qi "Vega 56\|Vega 64\|Vega Frontier"; then
                ARCHITECTURE="vega"
            elif echo "$GPU_MODEL" | grep -qi "RX 5500\|RX 5600\|RX 5700\|Navi 10\|Navi 14"; then
                ARCHITECTURE="navi10"
            elif echo "$GPU_MODEL" | grep -qi "RX 6600\|RX 6700\|RX 6800\|RX 6900\|Navi 21\|Navi 22\|Navi 23"; then
                ARCHITECTURE="navi21"
            elif echo "$GPU_MODEL" | grep -qi "RX 7600\|RX 7700\|RX 7800\|RX 7900\|Navi 31\|Navi 32\|Navi 33"; then
                ARCHITECTURE="navi31"
            elif echo "$GPU_MODEL" | grep -qi "R9 270\|R9 280\|R9 290\|R9 390"; then
                ARCHITECTURE="gcn3"
            elif echo "$GPU_MODEL" | grep -qi "R9 380\|R9 380X"; then
                ARCHITECTURE="gcn3"
            elif echo "$GPU_MODEL" | grep -qi "R9 370\|R9 360"; then
                ARCHITECTURE="gcn2"
            fi
            
            python3 << PYTHON_EOF
import json

with open('$TEMP_INFO_FILE', 'r') as f:
    data = json.load(f)

# Get current GPU count for correct indexing
current_count = len(data.get('gpus', []))

gpu_info = {
    "index": current_count,
    "vendor": "amd",
    "model": "$GPU_MODEL",
    "pci_id": "$PCI_ID",
    "architecture": "$ARCHITECTURE",
    "opencl_available": $OPENCL_AVAILABLE,
    "driver_version": "",
    "memory_mb": 0,
    "temperature": 0,
    "power_watts": 0,
    "optimized": False
}

data['gpus'].append(gpu_info)

with open('$TEMP_INFO_FILE', 'w') as f:
    json.dump(data, f, indent=2)
PYTHON_EOF
        done
    fi
fi

# Finalize
if [ "$GPU_COUNT" -eq 0 ]; then
    echo -e "${RED}⚠️  No GPUs detected!${NC}"
    echo "  Please ensure GPUs are properly installed and drivers are loaded."
else
    echo -e "${GREEN}✅ Detected $GPU_COUNT GPU(s)${NC}"
fi

# Save hardware info
cp "$TEMP_INFO_FILE" "$HARDWARE_INFO_FILE"
chmod 644 "$HARDWARE_INFO_FILE"

echo ""
echo -e "${GREEN}✅ Hardware detection complete!${NC}"
echo "  Hardware info saved to: $HARDWARE_INFO_FILE"
echo "  Rig ID: $RIG_ID"

# Display summary
echo ""
echo -e "${BLUE}📊 Hardware Summary:${NC}"
cat "$HARDWARE_INFO_FILE" | python3 -m json.tool 2>/dev/null || cat "$HARDWARE_INFO_FILE"

exit 0

