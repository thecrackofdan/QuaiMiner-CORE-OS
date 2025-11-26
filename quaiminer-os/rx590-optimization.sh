#!/bin/bash

# AMD RX 590 Optimization Script for QuaiMiner OS
# Applies recommended settings for RX 590 mining

set -e

echo "⚡ QuaiMiner OS - AMD RX 590 Optimization"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Verify RX 590
GPU_DETECTED=$(lspci | grep -i "Radeon.*RX.*590\|Polaris.*20" | wc -l)
if [ "$GPU_DETECTED" -eq 0 ]; then
    echo "⚠️  RX 590 not detected. This script is optimized for RX 590."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Load environment variables
if [ -f /etc/quaiminer/environment ]; then
    source /etc/quaiminer/environment
    echo "✅ Loaded RX 590 environment variables"
else
    echo "⚠️  Environment file not found. Run amd-setup-integration.sh first."
fi

# Create optimization profile
echo "📋 Creating optimization profile..."
cat > /etc/quaiminer/rx590-profile.json << 'PROFILE_EOF'
{
    "gpu": {
        "model": "AMD RX 590",
        "architecture": "Polaris 20",
        "optimization": {
            "coreClock": {
                "target": 1215,
                "min": 1100,
                "max": 1300,
                "unit": "MHz"
            },
            "memoryClock": {
                "target": 1900,
                "min": 1800,
                "max": 2000,
                "unit": "MHz"
            },
            "voltage": {
                "target": 875,
                "min": 850,
                "max": 950,
                "unit": "mV"
            },
            "powerLimit": {
                "target": 165,
                "min": 150,
                "max": 180,
                "unit": "W"
            }
        },
        "expectedPerformance": {
            "hashrate": {
                "min": 10,
                "target": 11,
                "max": 12,
                "unit": "MH/s"
            },
            "powerConsumption": {
                "min": 150,
                "target": 165,
                "max": 180,
                "unit": "W"
            },
            "temperature": {
                "optimal": 70,
                "max": 80,
                "unit": "°C"
            }
        }
    }
}
PROFILE_EOF

echo "✅ Optimization profile created"

# Create tuning script (for advanced users)
cat > /usr/local/bin/quaiminer-tune-rx590 << 'TUNE_EOF'
#!/bin/bash
# AMD RX 590 GPU Tuning Script
# WARNING: GPU tuning can be dangerous. Use at your own risk.

echo "⚡ AMD RX 590 GPU Tuning"
echo "========================"
echo ""
echo "⚠️  WARNING: GPU tuning can damage your hardware if done incorrectly!"
echo "⚠️  Make sure you understand what you're doing before proceeding."
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Check for available tools
if command -v rocm-smi &> /dev/null; then
    echo "✅ rocm-smi found"
    echo ""
    echo "Current GPU status:"
    rocm-smi
    echo ""
    echo "Available tuning options:"
    echo "1. Set power limit: rocm-smi --setpoweroverdrive <percent>"
    echo "2. Set fan speed: rocm-smi --setfan <percent>"
    echo ""
    echo "See /etc/quaiminer/rx590-optimization.md for details"
elif command -v amdgpu-fan &> /dev/null; then
    echo "✅ amdgpu-fan found"
    echo "Edit /etc/amdgpu-fan.conf to configure fan curve"
else
    echo "⚠️  No GPU tuning tools found"
    echo "Install ROCm for rocm-smi: sudo apt install rocm-utils"
fi

echo ""
echo "📖 Full optimization guide: /etc/quaiminer/rx590-optimization.md"
TUNE_EOF

chmod +x /usr/local/bin/quaiminer-tune-rx590
echo "✅ Tuning script created"

echo ""
echo "✅ RX 590 optimization complete!"
echo ""
echo "📋 Available commands:"
echo "  - quaiminer-verify-amd    - Verify AMD setup"
echo "  - quaiminer-tune-rx590    - GPU tuning (advanced)"
echo ""
echo "📖 Documentation:"
echo "  - /etc/quaiminer/rx590-optimization.md"
echo "  - /etc/quaiminer/rx590-profile.json"

