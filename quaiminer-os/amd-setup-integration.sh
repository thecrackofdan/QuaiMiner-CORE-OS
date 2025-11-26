#!/bin/bash

# AMD RX 590 Setup Integration for QuaiMiner OS
# Integrates the proven AMD setup from quick_amd_setup.sh
# Supports Ubuntu 20.04, 22.04, and 24.04+

set -e

# Detect Ubuntu version
detect_ubuntu_version() {
    if command -v lsb_release &> /dev/null; then
        UBUNTU_VERSION=$(lsb_release -rs)
        UBUNTU_CODENAME=$(lsb_release -cs)
    elif [ -f /etc/os-release ]; then
        UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
        UBUNTU_CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d'=' -f2)
    else
        echo "⚠️  Could not detect Ubuntu version, assuming 22.04"
        UBUNTU_VERSION="22.04"
        UBUNTU_CODENAME="jammy"
    fi
}

detect_ubuntu_version

echo "⚡ QuaiMiner OS - AMD RX 590 Setup Integration"
echo "=============================================="
echo "📋 Detected Ubuntu: $UBUNTU_VERSION ($UBUNTU_CODENAME)"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Detect GPU
GPU_DETECTED=$(lspci | grep -i "Radeon.*RX.*590" | wc -l)
if [ "$GPU_DETECTED" -eq 0 ]; then
    echo "⚠️  RX 590 not detected. Checking for other AMD GPUs..."
    lspci | grep -i "Radeon\|AMD" || echo "No AMD GPUs found"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ RX 590 detected!"
fi

# Install dependencies
echo "📦 Installing dependencies..."
apt-get update
apt-get install -y \
    build-essential \
    dkms \
    linux-headers-$(uname -r) \
    wget \
    gdebi-core \
    software-properties-common \
    clinfo \
    mesa-utils \
    lshw \
    pciutils

# Download and install AMD drivers (if not already installed)
echo "🎯 Checking AMD OpenCL drivers..."
if ! command -v clinfo &> /dev/null || ! clinfo 2>/dev/null | grep -q "AMD Accelerated Parallel Processing\|Mesa"; then
    echo "📥 Installing AMD drivers..."
    
    # Choose installation method based on Ubuntu version
    if [ "$(echo "$UBUNTU_VERSION >= 22.04" | bc -l 2>/dev/null || echo "0")" = "1" ]; then
        # Ubuntu 22.04+ - Prefer Mesa drivers (easier)
        echo "💡 Ubuntu 22.04+ detected - Installing Mesa OpenCL drivers..."
        apt-get install -y mesa-opencl-icd opencl-headers opencl-clhpp-dev
        echo "✅ Mesa drivers installed"
    else
        # Ubuntu 20.04 - Use AMDGPU Pro
        echo "📥 Installing AMDGPU Pro drivers for Ubuntu 20.04..."
        
        mkdir -p /tmp/amd-drivers
        cd /tmp/amd-drivers
        
        DRIVER_FILE="amdgpu-pro-22.40-2211043-ubuntu-20.04.tar.xz"
        
        if [ ! -f "$DRIVER_FILE" ]; then
            echo "📥 Downloading AMDGPU Pro drivers..."
            wget https://drivers.amd.com/drivers/linux/$DRIVER_FILE || {
                echo "⚠️  Failed to download. Trying alternative method..."
                # Alternative: Use amdgpu-install
                wget https://repo.radeon.com/amdgpu-install/6.0.2/ubuntu/focal/amdgpu-install_6.0.60200-1_all.deb
                dpkg -i amdgpu-install_6.0.60200-1_all.deb || true
                apt-get install -f -y
                amdgpu-install --usecase=rocm,opencl --no-dkms -y || {
                    echo "❌ Driver installation failed"
                    exit 1
                }
            }
        fi
        
        if [ -f "$DRIVER_FILE" ]; then
            tar -Jxvf $DRIVER_FILE
            cd amdgpu-pro-22.40-2211043-ubuntu-20.04
            ./amdgpu-pro-install --opencl=rocm,legacy --no-dkms || {
                echo "⚠️  Installation had issues, but continuing..."
            }
        fi
    fi
else
    echo "✅ AMD OpenCL drivers already installed"
fi

# Configure user permissions
echo "🔐 Configuring user permissions..."
SERVICE_USER="quaiminer"
if id "$SERVICE_USER" &>/dev/null; then
    usermod -a -G render,video,rocm "$SERVICE_USER"
    echo "✅ Added $SERVICE_USER to GPU groups"
fi

# Create udev rules
echo "⚙️  Creating udev rules..."
cat > /etc/udev/rules.d/99-amdgpu.rules << 'EOF'
KERNEL=="card[0-9]*", GROUP="render", MODE="0660"
KERNEL=="renderD[0-9]*", GROUP="render", MODE="0660"
EOF

udevadm control --reload-rules
udevadm trigger

# Set RX 590 specific environment variables
echo "🌍 Setting up RX 590 environment variables..."
ENV_FILE="/etc/quaiminer/environment"
mkdir -p /etc/quaiminer

cat > "$ENV_FILE" << 'EOF'
# AMD RX 590 Optimization Environment Variables
# These are required for Polaris architecture (RX 590)

# Enable pre-Vega support (required for Polaris)
ROC_ENABLE_PRE_VEGA=1

# Override GFX version for RX 590 (Polaris 20)
HSA_OVERRIDE_GFX_VERSION=8.0.0

# GPU memory optimization
GPU_FORCE_64BIT_PTR=1
GPU_MAX_HEAP_SIZE=100
GPU_USE_SYNC_OBJECTS=1
GPU_MAX_ALLOC_PERCENT=100
GPU_SINGLE_ALLOC_PERCENT=100

# OpenCL optimization
OPENCL_PLATFORMS=AMD
EOF

chmod 644 "$ENV_FILE"
echo "✅ Environment variables configured"

# Create verification script
echo "📋 Creating verification script..."
cat > /usr/local/bin/quaiminer-verify-amd << 'VERIFY_EOF'
#!/bin/bash
echo "=== QuaiMiner OS - AMD RX 590 Verification ==="
echo ""
echo "1. GPU Detection:"
lspci | grep -i "Radeon\|AMD" || echo "No AMD GPU detected"
echo ""
echo "2. OpenCL Platforms:"
clinfo 2>/dev/null | head -30 || echo "❌ OpenCL not working - run clinfo for details"
echo ""
echo "3. Driver Status:"
lsmod | grep amdgpu || echo "❌ amdgpu driver not loaded"
echo ""
echo "4. GPU Device Permissions:"
ls -la /dev/dri/ | grep -E "(card|render)" || echo "❌ GPU devices not found"
echo ""
echo "5. Environment Variables:"
if [ -f /etc/quaiminer/environment ]; then
    cat /etc/quaiminer/environment
else
    echo "⚠️  Environment file not found"
fi
echo ""
echo "6. Service User Groups:"
if id quaiminer &>/dev/null; then
    groups quaiminer
else
    echo "⚠️  quaiminer user not found"
fi
VERIFY_EOF

chmod +x /usr/local/bin/quaiminer-verify-amd
echo "✅ Verification script created"

# Create GPU optimization script (for manual tuning)
echo "📋 Creating GPU optimization guide..."
cat > /etc/quaiminer/rx590-optimization.md << 'OPT_EOF'
# AMD RX 590 Optimization Settings for Quai Mining

## Recommended GPU Settings

### Core Clock
- **Target**: 1215 MHz
- **Range**: 1100-1300 MHz

### Memory Clock
- **Target**: 1900 MHz
- **Range**: 1800-2000 MHz

### Core Voltage
- **Target**: 875 mV
- **Range**: 850-950 mV

### Power Limit
- Adjust based on your PSU capacity
- Typical: 150-180W for mining

## Mining Performance

Expected hashrate on Quai Network:
- **Quai GPU Miner**: 10-12 MH/s
- **Power Consumption**: 150-180W
- **Temperature**: 65-75°C (optimal)

## Tools for GPU Tuning

### Using amdgpu-fan (if available)
```bash
# Install amdgpu-fan
sudo apt install amdgpu-fan

# Configure fan curve
sudo nano /etc/amdgpu-fan.conf
```

### Using rocm-smi (if ROCm installed)
```bash
# Check GPU status
rocm-smi

# Set power limit
rocm-smi --setpoweroverdrive 20  # 20% overdrive
```

### Manual BIOS Modding (Advanced)
- Requires GPU BIOS modification
- Not recommended for beginners
- Can void warranty

## Environment Variables

These are automatically set by QuaiMiner OS:
- `ROC_ENABLE_PRE_VEGA=1`
- `HSA_OVERRIDE_GFX_VERSION=8.0.0`
- `GPU_FORCE_64BIT_PTR=1`
- `GPU_MAX_HEAP_SIZE=100`
- `GPU_USE_SYNC_OBJECTS=1`

## Verification

Run after setup:
```bash
quaiminer-verify-amd
```

## Troubleshooting

See: `amd_opencl_troubleshooting.md` in main repository
OPT_EOF

echo ""
echo "✅ AMD RX 590 setup integration complete!"
echo ""
echo "📋 Next steps:"
echo "1. Reboot system: sudo reboot"
echo "2. Verify setup: quaiminer-verify-amd"
echo "3. Continue with QuaiMiner OS installation"
echo ""
echo "📖 Optimization guide: /etc/quaiminer/rx590-optimization.md"

