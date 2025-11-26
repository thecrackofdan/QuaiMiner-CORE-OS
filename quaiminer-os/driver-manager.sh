#!/bin/bash

# QuaiMiner CORE OS - Automatic Driver Management System
# Detects, installs, and updates GPU drivers automatically

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DRIVER_CONFIG="/etc/quaiminer/driver-config.json"
LOG_FILE="/var/log/quaiminer/driver-manager.log"

mkdir -p /var/log/quaiminer
mkdir -p /etc/quaiminer

echo -e "${BLUE}🔧 QuaiMiner CORE OS - Driver Manager${NC}"
echo "===================================="

# Detect Ubuntu version
detect_ubuntu_version() {
    if command -v lsb_release &> /dev/null; then
        UBUNTU_VERSION=$(lsb_release -rs)
        UBUNTU_CODENAME=$(lsb_release -cs)
    elif [ -f /etc/os-release ]; then
        UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
        UBUNTU_CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f2)
    else
        UBUNTU_VERSION="22.04"
        UBUNTU_CODENAME="jammy"
    fi
    echo "📋 Ubuntu: $UBUNTU_VERSION ($UBUNTU_CODENAME)"
}

# Check NVIDIA driver status
check_nvidia_driver() {
    if command -v nvidia-smi &> /dev/null; then
        DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)
        echo -e "${GREEN}✅ NVIDIA driver installed: $DRIVER_VERSION${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  NVIDIA driver not found${NC}"
        return 1
    fi
}

# Install/Update NVIDIA driver
install_nvidia_driver() {
    echo -e "${YELLOW}📥 Installing NVIDIA drivers...${NC}"
    
    # Add NVIDIA PPA
    add-apt-repository -y ppa:graphics-drivers/ppa 2>/dev/null || true
    apt-get update
    
    # Detect recommended driver
    RECOMMENDED=$(ubuntu-drivers devices 2>/dev/null | grep "recommended" | awk '{print $5}' | head -1)
    
    if [ -n "$RECOMMENDED" ]; then
        echo "  Installing recommended driver: $RECOMMENDED"
        apt-get install -y "$RECOMMENDED"
    else
        echo "  Installing latest NVIDIA driver..."
        apt-get install -y nvidia-driver-535 || apt-get install -y nvidia-driver-525
    fi
    
    echo -e "${GREEN}✅ NVIDIA driver installed${NC}"
    echo "  ⚠️  Reboot required for changes to take effect"
}

# Check AMD driver status
check_amd_driver() {
    if command -v clinfo &> /dev/null; then
        if clinfo 2>/dev/null | grep -q "AMD Accelerated Parallel Processing\|Mesa"; then
            echo -e "${GREEN}✅ AMD OpenCL driver detected${NC}"
            return 0
        fi
    fi
    
    if lsmod | grep -q "amdgpu"; then
        echo -e "${YELLOW}⚠️  AMD driver loaded but OpenCL not available${NC}"
        return 1
    else
        echo -e "${YELLOW}⚠️  AMD driver not found${NC}"
        return 1
    fi
}

# Install/Update AMD driver
install_amd_driver() {
    echo -e "${YELLOW}📥 Installing AMD drivers...${NC}"
    
    detect_ubuntu_version
    
    # For Ubuntu 22.04+, prefer Mesa drivers
    if [ "$(echo "$UBUNTU_VERSION >= 22.04" | bc -l 2>/dev/null || echo "0")" = "1" ]; then
        echo "  Installing Mesa OpenCL drivers (recommended for Ubuntu 22.04+)..."
        apt-get update
        apt-get install -y mesa-opencl-icd opencl-headers opencl-clhpp-dev clinfo
        
        # Also install ROCm for better performance
        if [ "$UBUNTU_CODENAME" = "jammy" ]; then
            wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add -
            echo "deb [arch=amd64] https://repo.radeon.com/rocm/apt/5.7/ubuntu jammy main" | tee /etc/apt/sources.list.d/rocm.list
            apt-get update
            apt-get install -y rocm-opencl-dev rocm-utils
        fi
    else
        # Ubuntu 20.04 - Use AMDGPU Pro
        echo "  Installing AMDGPU Pro drivers for Ubuntu 20.04..."
        cd /tmp
        
        DRIVER_FILE="amdgpu-pro-22.40-2211043-ubuntu-20.04.tar.xz"
        if [ ! -f "$DRIVER_FILE" ]; then
            wget "https://drivers.amd.com/drivers/linux/$DRIVER_FILE"
        fi
        
        if [ -f "$DRIVER_FILE" ]; then
            tar -Jxvf "$DRIVER_FILE"
            cd amdgpu-pro-22.40-2211043-ubuntu-20.04
            ./amdgpu-pro-install --opencl=rocm,legacy --no-dkms || true
        fi
    fi
    
    # Configure permissions
    usermod -a -G render,video,rocm quaiminer 2>/dev/null || true
    
    echo -e "${GREEN}✅ AMD driver installed${NC}"
}

# Main driver management
main() {
    detect_ubuntu_version
    
    # Detect GPUs
    NVIDIA_GPUS=0
    AMD_GPUS=0
    
    if command -v nvidia-smi &> /dev/null; then
        NVIDIA_GPUS=$(nvidia-smi --list-gpus 2>/dev/null | wc -l || echo "0")
    fi
    
    if command -v lspci &> /dev/null; then
        AMD_GPUS=$(lspci | grep -i "VGA\|3D\|Display" | grep -i "AMD\|ATI\|Radeon" | wc -l || echo "0")
    fi
    
    echo "🎮 Detected GPUs:"
    echo "  NVIDIA: $NVIDIA_GPUS"
    echo "  AMD: $AMD_GPUS"
    echo ""
    
    # Handle NVIDIA
    if [ "$NVIDIA_GPUS" -gt 0 ]; then
        if ! check_nvidia_driver; then
            read -p "Install NVIDIA drivers? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_nvidia_driver
            fi
        else
            # Check for updates
            echo "  Checking for driver updates..."
            apt-get update
            if apt-get upgrade -s nvidia-driver-* 2>/dev/null | grep -q "Inst"; then
                echo -e "${YELLOW}  Driver updates available${NC}"
                read -p "Update NVIDIA drivers? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    apt-get upgrade -y nvidia-driver-*
                    echo "  ⚠️  Reboot required"
                fi
            fi
        fi
    fi
    
    # Handle AMD
    if [ "$AMD_GPUS" -gt 0 ]; then
        if ! check_amd_driver; then
            read -p "Install AMD drivers? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_amd_driver
            fi
        else
            echo "  AMD drivers are up to date"
        fi
    fi
    
    # Save driver config
    cat > "$DRIVER_CONFIG" << EOF
{
  "ubuntu_version": "$UBUNTU_VERSION",
  "ubuntu_codename": "$UBUNTU_CODENAME",
  "nvidia_drivers": {
    "installed": $([ "$NVIDIA_GPUS" -gt 0 ] && check_nvidia_driver >/dev/null 2>&1 && echo "true" || echo "false"),
    "version": "$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 || echo "")"
  },
  "amd_drivers": {
    "installed": $([ "$AMD_GPUS" -gt 0 ] && check_amd_driver >/dev/null 2>&1 && echo "true" || echo "false"),
    "opencl_available": $(clinfo 2>/dev/null | grep -q "AMD\|Mesa" && echo "true" || echo "false")
  },
  "last_updated": "$(date -Iseconds)"
}
EOF
    
    echo ""
    echo -e "${GREEN}✅ Driver management complete!${NC}"
}

main "$@"

