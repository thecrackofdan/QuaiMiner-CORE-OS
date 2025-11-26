#!/bin/bash

# QuaiMiner OS - Automated Installation Script
# Installs quai-gpu-miner and sets up automated mining management

set -e

echo "⚡ QuaiMiner OS - Automated Installation"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Configuration
INSTALL_DIR="/opt/quaiminer"
CONFIG_DIR="/etc/quaiminer"
SERVICE_USER="quaiminer"
MINER_REPO="https://github.com/dominant-strategies/quai-gpu-miner.git"

# Step 1: Create service user
echo "👤 Creating service user..."
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/bash -d "$INSTALL_DIR" "$SERVICE_USER"
    echo "✅ Created user: $SERVICE_USER"
else
    echo "ℹ️  User $SERVICE_USER already exists"
fi

# Step 2: Create directories
echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$INSTALL_DIR/logs"
chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"
chown -R "$SERVICE_USER:$SERVICE_USER" "$CONFIG_DIR"
echo "✅ Directories created"

# Step 3: Install dependencies
echo "📦 Installing dependencies..."
apt-get update
apt-get install -y \
    build-essential \
    git \
    cmake \
    libopencl-dev \
    ocl-icd-opencl-dev \
    clinfo \
    curl \
    jq

# Detect GPU type
GPU_TYPE="unknown"
if lspci | grep -i "nvidia" > /dev/null; then
    GPU_TYPE="nvidia"
    echo "🎮 Detected NVIDIA GPU"
elif lspci | grep -i "radeon.*RX.*590\|Polaris.*20" > /dev/null; then
    GPU_TYPE="amd"
    echo "🎮 Detected AMD RX 590 (Polaris 20)"
    echo "💡 RX 590 detected - will apply specific optimizations"
    RX590_DETECTED=true
elif lspci | grep -i "radeon\|amd" > /dev/null; then
    GPU_TYPE="amd"
    echo "🎮 Detected AMD GPU"
    RX590_DETECTED=false
else
    echo "⚠️  Could not detect GPU type"
    read -p "Enter GPU type (nvidia/amd): " GPU_TYPE
    RX590_DETECTED=false
fi

# For AMD GPUs, check if we should run AMD setup integration
if [ "$GPU_TYPE" = "amd" ]; then
    echo "🔧 Checking AMD driver status..."
    if ! command -v clinfo &> /dev/null || ! clinfo 2>/dev/null | grep -q "AMD Accelerated Parallel Processing"; then
        echo "⚠️  AMD OpenCL not detected"
        echo "💡 Run AMD setup integration:"
        echo "   cd quaiminer-os"
        echo "   sudo ./amd-setup-integration.sh"
        echo ""
        read -p "Run AMD setup now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
            if [ -f "$SCRIPT_DIR/amd-setup-integration.sh" ]; then
                bash "$SCRIPT_DIR/amd-setup-integration.sh"
            else
                echo "⚠️  AMD setup script not found. Continuing with basic setup..."
            fi
        fi
    else
        echo "✅ AMD OpenCL already working"
    fi
fi

# Step 4: Install quai-gpu-miner
echo "⚙️  Installing quai-gpu-miner..."
cd "$INSTALL_DIR"

# Check if miner already exists
if [ -d "$INSTALL_DIR/quai-gpu-miner" ]; then
    echo "ℹ️  Miner directory exists, updating..."
    cd quai-gpu-miner
    git pull
else
    echo "📥 Cloning quai-gpu-miner repository..."
    git clone "$MINER_REPO" quai-gpu-miner
    cd quai-gpu-miner
fi

# Build miner
echo "🔨 Building miner..."
make clean || true
make

# Check if build was successful
if [ ! -f "build/ethcoreminer" ]; then
    echo "❌ Build failed! Trying alternative build method..."
    # Try pre-built binaries if available
    if [ "$GPU_TYPE" = "nvidia" ]; then
        echo "📥 Downloading pre-built NVIDIA binary..."
        wget -O build/ethcoreminer https://github.com/dominant-strategies/quai-gpu-miner/releases/latest/download/quai-gpu-miner-nvidia || {
            echo "❌ Failed to download pre-built binary"
            exit 1
        }
        chmod +x build/ethcoreminer
    else
        echo "❌ AMD pre-built binaries not available, build required"
        exit 1
    fi
fi

chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"
echo "✅ Miner installed"

# Step 5: Create configuration file
echo "⚙️  Creating configuration..."
cat > "$CONFIG_DIR/config.json" << EOF
{
    "miner": {
        "binary": "$INSTALL_DIR/quai-gpu-miner/build/ethcoreminer",
        "args": ["-G"],
        "stratum": "",
        "wallet": "",
        "worker": "rig-$(hostname)",
        "miningMode": "solo"
    },
    "node": {
        "rpcUrl": "http://localhost:8545",
        "stratumProxy": "localhost:3333",
        "requireSynced": true
    },
    "depool": {
        "enabled": false,
        "address": "",
        "port": 0
    },
    "gpu": {
        "type": "$GPU_TYPE",
        "model": "$([ "$RX590_DETECTED" = "true" ] && echo "RX 590" || echo "")",
        "optimization": "$([ "$RX590_DETECTED" = "true" ] && echo "rx590" || echo "generic")",
        "environment": {
            "ROC_ENABLE_PRE_VEGA": "$([ "$RX590_DETECTED" = "true" ] && echo "1" || echo "0")",
            "HSA_OVERRIDE_GFX_VERSION": "$([ "$RX590_DETECTED" = "true" ] && echo "8.0.0" || echo "")",
            "GPU_FORCE_64BIT_PTR": "1",
            "GPU_MAX_HEAP_SIZE": "100",
            "GPU_USE_SYNC_OBJECTS": "1",
            "GPU_MAX_ALLOC_PERCENT": "100",
            "GPU_SINGLE_ALLOC_PERCENT": "100"
        }
    },
    "autoStart": false,
    "autoRestart": true
}
EOF
chown "$SERVICE_USER:$SERVICE_USER" "$CONFIG_DIR/config.json"
chmod 600 "$CONFIG_DIR/config.json"
echo "✅ Configuration created"

# Step 6: Create systemd service
echo "⚙️  Creating systemd service..."
cat > /etc/systemd/system/quaiminer.service << EOF
[Unit]
Description=QuaiMiner OS - Quai Network GPU Miner
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
Group=$SERVICE_USER
WorkingDirectory=$INSTALL_DIR/quai-gpu-miner/build
Environment="ROC_ENABLE_PRE_VEGA=1"
Environment="HSA_OVERRIDE_GFX_VERSION=8.0.0"
Environment="GPU_FORCE_64BIT_PTR=1"
Environment="GPU_MAX_HEAP_SIZE=100"
Environment="GPU_USE_SYNC_OBJECTS=1"
ExecStart=$INSTALL_DIR/quaiminer-wrapper.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
echo "✅ Systemd service created"

# Step 7: Create miner wrapper script
echo "⚙️  Creating miner wrapper..."
cat > "$INSTALL_DIR/quaiminer-wrapper.sh" << 'WRAPPER_EOF'
#!/bin/bash
# QuaiMiner Wrapper Script
# Reads configuration and starts miner with correct parameters

CONFIG_FILE="/etc/quaiminer/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Read configuration
BINARY=$(jq -r '.miner.binary' "$CONFIG_FILE")
STRATUM=$(jq -r '.miner.stratum' "$CONFIG_FILE")
WALLET=$(jq -r '.miner.wallet' "$CONFIG_FILE")
WORKER=$(jq -r '.miner.worker' "$CONFIG_FILE")
ARGS=$(jq -r '.miner.args[]' "$CONFIG_FILE" | tr '\n' ' ')

# Set environment variables from config
ENV_VARS=$(jq -r '.gpu.environment | to_entries[] | "\(.key)=\(.value)"' "$CONFIG_FILE")
while IFS= read -r line; do
    # Skip empty values
    if [ -n "$line" ] && [ "$line" != "=" ]; then
        export "$line"
    fi
done <<< "$ENV_VARS"

# Also load from system environment file if it exists
if [ -f /etc/quaiminer/environment ]; then
    set -a
    source /etc/quaiminer/environment
    set +a
fi

# Build command
CMD="$BINARY $ARGS"

# Add stratum proxy if configured (solo mining with own node)
if [ -n "$STRATUM" ] && [ "$STRATUM" != "null" ] && [ "$STRATUM" != "" ]; then
    # Solo mining: connect to node's stratum proxy
    CMD="$CMD -P $STRATUM"
fi

# Add wallet if configured (for coinbase rewards)
if [ -n "$WALLET" ] && [ "$WALLET" != "null" ] && [ "$WALLET" != "" ]; then
    # Note: Wallet is typically handled by the node, but can be specified here
    CMD="$CMD --coinbase $WALLET"
fi

# Add worker name if specified
if [ -n "$WORKER" ] && [ "$WORKER" != "null" ] && [ "$WORKER" != "" ]; then
    CMD="$CMD --worker $WORKER"
fi

echo "🚀 Starting QuaiMiner..."
echo "📋 Command: $CMD"
echo ""

# Execute miner
exec $CMD
WRAPPER_EOF

chmod +x "$INSTALL_DIR/quaiminer-wrapper.sh"
chown "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR/quaiminer-wrapper.sh"
echo "✅ Wrapper script created"

# Step 8: Create config manager script
echo "⚙️  Creating configuration manager..."
cat > /usr/local/bin/quaiminer-config << 'CONFIG_EOF'
#!/bin/bash
# QuaiMiner Configuration Manager

CONFIG_FILE="/etc/quaiminer/config.json"

case "$1" in
    set-stratum)
        if [ -z "$2" ]; then
            echo "Usage: quaiminer-config set-stratum <stratum_address>"
            echo "Example: quaiminer-config set-stratum stratum://localhost:3333"
            exit 1
        fi
        jq ".miner.stratum = \"$2\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "✅ Stratum proxy configured: $2"
        echo "🔄 Restart miner to apply changes: sudo systemctl restart quaiminer"
        ;;
    set-wallet)
        if [ -z "$2" ]; then
            echo "Usage: quaiminer-config set-wallet <wallet_address>"
            exit 1
        fi
        jq ".miner.wallet = \"$2\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "✅ Wallet configured: $2"
        echo "🔄 Restart miner to apply changes: sudo systemctl restart quaiminer"
        ;;
    show)
        cat "$CONFIG_FILE" | jq .
        ;;
    set-node-rpc)
        if [ -z "$2" ]; then
            echo "Usage: quaiminer-config set-node-rpc <rpc_url>"
            echo "Example: quaiminer-config set-node-rpc http://localhost:8545"
            exit 1
        fi
        jq ".node.rpcUrl = \"$2\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "✅ Node RPC configured: $2"
        ;;
    enable-depool)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: quaiminer-config enable-depool <depool_address> <port>"
            exit 1
        fi
        jq ".depool.enabled = true | .depool.address = \"$2\" | .depool.port = $3" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "✅ Depool enabled: $2:$3"
        echo "⚠️  Depool functionality is coming soon!"
        ;;
    disable-depool)
        jq ".depool.enabled = false" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "✅ Depool disabled"
        ;;
    *)
        echo "QuaiMiner OS Configuration Manager"
        echo "Solo Mining with Your Own Node"
        echo ""
        echo "Usage:"
        echo "  quaiminer-config set-stratum <address>     - Set node's stratum proxy address"
        echo "  quaiminer-config set-wallet <address>      - Set wallet address for coinbase"
        echo "  quaiminer-config set-node-rpc <url>        - Set Quai node RPC URL"
        echo "  quaiminer-config enable-depool <addr> <port> - Enable depool (future feature)"
        echo "  quaiminer-config disable-depool            - Disable depool"
        echo "  quaiminer-config show                      - Show current configuration"
        echo ""
        echo "Examples:"
        echo "  quaiminer-config set-stratum stratum://localhost:3333"
        echo "  quaiminer-config set-node-rpc http://localhost:8545"
        ;;
esac
CONFIG_EOF

chmod +x /usr/local/bin/quaiminer-config
echo "✅ Configuration manager created"

# Step 9: Reload systemd and enable service
echo "⚙️  Setting up systemd..."
systemctl daemon-reload
systemctl enable quaiminer
echo "✅ Service enabled (not started - configure stratum proxy first)"

# Step 10: Add user to render/video groups (for GPU access)
if [ "$GPU_TYPE" = "amd" ]; then
    echo "👤 Adding user to GPU access groups..."
    usermod -a -G render,video "$SERVICE_USER"
    echo "✅ User added to GPU groups"
fi

echo ""
echo "✅ QuaiMiner OS Installation Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Ensure your Quai node is running and synced"
echo "2. Start your node's stratum proxy (usually on localhost:3333)"
echo "3. Configure stratum proxy address:"
echo "   sudo quaiminer-config set-stratum stratum://localhost:3333"
echo ""
echo "4. (Optional) Set wallet address for coinbase rewards:"
echo "   sudo quaiminer-config set-wallet YOUR_WALLET_ADDRESS"
echo ""
echo "5. Start mining:"
echo "   sudo systemctl start quaiminer"
echo ""
echo "6. Check status:"
echo "   sudo systemctl status quaiminer"
echo ""
echo "7. View logs:"
echo "   sudo journalctl -u quaiminer -f"
echo ""
echo "🌐 Or use the web dashboard at http://localhost:3000"
echo ""
echo "💡 Remember: This is for SOLO MINING with your own Quai node!"

