#!/bin/bash

# QuaiMiner CORE OS - Unified Installation Script
# One script to install everything: hardware detection, drivers, optimization, and miner setup

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/opt/quaiminer"
CONFIG_DIR="/etc/quaiminer"
LOG_DIR="/var/log/quaiminer"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     QuaiMiner CORE OS - Unified Installation System       ║"
echo "║     Multi-GPU • Multi-Rig • Auto-Detection • Auto-Setup   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

# Create directories
echo -e "${BLUE}📁 Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$INSTALL_DIR/logs"
echo -e "${GREEN}✅ Directories created${NC}"

# Step 1: Hardware Detection
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1/5: Hardware Detection${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "$SCRIPT_DIR/hardware-detector.sh" ]; then
    chmod +x "$SCRIPT_DIR/hardware-detector.sh"
    "$SCRIPT_DIR/hardware-detector.sh"
else
    echo -e "${YELLOW}⚠️  Hardware detector script not found${NC}"
fi

# Step 2: Driver Management
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2/5: Driver Management${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "$SCRIPT_DIR/driver-manager.sh" ]; then
    chmod +x "$SCRIPT_DIR/driver-manager.sh"
    "$SCRIPT_DIR/driver-manager.sh"
else
    echo -e "${YELLOW}⚠️  Driver manager script not found${NC}"
fi

# Step 3: GPU Optimization
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3/5: GPU Optimization${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "$SCRIPT_DIR/gpu-optimizer.sh" ]; then
    chmod +x "$SCRIPT_DIR/gpu-optimizer.sh"
    "$SCRIPT_DIR/gpu-optimizer.sh"
else
    echo -e "${YELLOW}⚠️  GPU optimizer script not found${NC}"
fi

# Step 4: Install Quai Miner
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4/5: Installing Quai GPU Miner${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "$SCRIPT_DIR/install.sh" ]; then
    # Use existing install script but skip hardware detection (already done)
    echo -e "${YELLOW}Installing quai-gpu-miner...${NC}"
    # Extract just the miner installation part
    MINER_REPO="https://github.com/dominant-strategies/quai-gpu-miner.git"
    
    cd "$INSTALL_DIR"
    if [ -d "quai-gpu-miner" ]; then
        echo "  Updating existing miner..."
        cd quai-gpu-miner
        git pull
    else
        echo "  Cloning miner repository..."
        git clone "$MINER_REPO" quai-gpu-miner
        cd quai-gpu-miner
    fi
    
    echo "  Building miner..."
    make clean || true
    make
    
    if [ ! -f "build/ethcoreminer" ]; then
        echo -e "${RED}❌ Build failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Miner installed${NC}"
else
    echo -e "${YELLOW}⚠️  Install script not found${NC}"
fi

# Step 5: Configuration
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5/5: Configuration${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Create default config
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    GPU_COUNT=$(python3 -c "import json; data = json.load(open('$CONFIG_DIR/hardware-info.json')); print(len(data.get('gpus', [])))" 2>/dev/null || echo "1")
    
    cat > "$CONFIG_DIR/config.json" << EOF
{
  "rig_id": "$(python3 -c "import json; print(json.load(open('$CONFIG_DIR/hardware-info.json'))['rig_id'])" 2>/dev/null || echo 'rig-$(hostname)')",
  "stratum_url": "stratum://localhost:3333",
  "node_rpc": "http://localhost:8545",
  "wallet": "",
  "worker": "$(hostname)",
  "gpu_count": $GPU_COUNT,
  "auto_start": true,
  "optimization": {
    "enabled": true,
    "power_limit_percent": 80,
    "memory_overclock": 0,
    "core_underclock": 0
  }
}
EOF
    echo -e "${GREEN}✅ Default configuration created${NC}"
fi

# Register rig
if [ -f "$SCRIPT_DIR/multi-rig-manager.sh" ]; then
    chmod +x "$SCRIPT_DIR/multi-rig-manager.sh"
    "$SCRIPT_DIR/multi-rig-manager.sh" register "$(hostname)" "localhost"
fi

# Installation complete
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "  1. Configure your node RPC and stratum URL:"
echo "     sudo nano $CONFIG_DIR/config.json"
echo ""
echo "  2. Start the miner:"
echo "     sudo systemctl start quaiminer"
echo ""
echo "  3. Monitor your rigs:"
echo "     sudo $SCRIPT_DIR/multi-rig-manager.sh list"
echo ""
echo -e "${YELLOW}⚠️  Reboot recommended to ensure all drivers are loaded${NC}"
echo ""

