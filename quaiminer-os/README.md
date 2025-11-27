# Quai GPU Miner - Custom Mining OS

**Custom mining operating system for Quai Network mining**

Quai GPU Miner is a complete mining management system designed for easy Quai Network mining. Get started mining with automatic GPU detection, driver installation, and a beautiful web interface.

## 🎯 What It Does

- ✅ **Solo Mining**: Mine directly to your own Quai node - 100% of rewards, no fees
- ✅ **Automated Miner Installation**: Installs and configures quai-gpu-miner automatically
- ✅ **Stratum Proxy Integration**: Connect your miner to your node's stratum proxy
- ✅ **Auto-Start Mining**: Automatically starts mining on boot
- ✅ **Remote Management**: Control your miner from anywhere via web dashboard
- ✅ **Real-Time Monitoring**: Monitor mining performance, GPU stats, and profitability
- ✅ **Multi-Rig Support**: Manage multiple solo mining rigs

## 🚀 Quick Start

### Prerequisites
1. **Install AMD/NVIDIA Drivers** (one-time setup)
   - **For AMD RX 590**: Run `./amd-setup-integration.sh` (integrated from quick_amd_setup.sh)
   - **For other AMD GPUs**: Run `../quick_amd_setup.sh` or `./amd-setup-integration.sh`
   - **For NVIDIA**: Install NVIDIA drivers

2. **Install Quai GPU Miner**
   ```bash
   cd quaiminer-os
   chmod +x install.sh
   sudo ./install.sh
   ```

3. **Configure Solo Mining**
   - Ensure your Quai node is running and synced
   - Start your node's stratum proxy (usually on localhost:3333)
   - Open dashboard: `http://localhost:3000`
   - Configure your miner:
     - **Stratum Address**: `stratum://localhost:3333` (or your node's IP)
     - **Wallet Address**: Your Quai wallet address
     - **Node RPC**: `http://localhost:8545` (your node's RPC endpoint)
   - Click "Save Configuration"
   - Start mining!

That's it! You're now solo mining directly to your own node. All block rewards go to your wallet with no pool fees.

## 📋 Components

### 1. Automated Installation (`install.sh`)
- Installs quai-gpu-miner from source or pre-built binaries
- Sets up systemd service for auto-start
- Configures environment variables
- Creates configuration directory

### 2. Miner Service (`quaiminer.service`)
- Systemd service for automatic startup
- Handles miner process management
- Auto-restart on failure
- Logs to systemd journal

### 3. Configuration Manager (`config-manager.sh`)
- Manages stratum proxy configuration
- Updates miner config files
- Validates connection strings
- Restarts miner when config changes

### 4. Web Dashboard Integration
- Stratum proxy configuration interface
- Start/stop/restart miner controls
- Real-time status monitoring
- Configuration history

### 5. API Endpoints (`server.js`)
- `/api/miner/start` - Start mining
- `/api/miner/stop` - Stop mining
- `/api/miner/status` - Get miner status
- `/api/miner/config` - Get/set configuration

## 🎮 AMD RX 590 Support

QuaiMiner OS includes **specialized support for AMD RX 590** with:
- ✅ Automated driver installation
- ✅ RX 590-specific environment variables
- ✅ GPU optimization profiles
- ✅ Verification and tuning tools

### Quick AMD RX 590 Setup

```bash
# Run AMD setup integration (includes driver installation)
cd quaiminer-os
sudo ./amd-setup-integration.sh

# Apply RX 590 optimizations
sudo ./rx590-optimization.sh

# Verify setup
quaiminer-verify-amd
```

### RX 590 Optimization

Expected performance with optimizations:
- **Hashrate**: 10-12 MH/s
- **Power**: 150-180W
- **Temperature**: 65-75°C (optimal)

See `/etc/quaiminer/rx590-optimization.md` for detailed tuning guide.

## 🔧 Configuration

### Solo Mining Configuration

**Solo Mining Setup:**
```
# Configure your miner to connect to your node's stratum proxy
1. Open dashboard → Settings → Miner Configuration
2. Set Stratum Address: stratum://localhost:3333 (or your node's IP)
3. Set Wallet Address: Your Quai wallet address
4. Set Node RPC: http://localhost:8545 (your node's RPC)
5. Save configuration
6. Start mining!

# Your miner connects directly to your node
stratum://localhost:3333          # Local node
stratum://192.168.1.100:3333      # Remote node
```

**Stratum Proxy Configuration:**
```
# Your Quai node's stratum proxy (usually port 3333)
# Local node:
stratum://localhost:3333
stratum://127.0.0.1:3333

# Remote node (if node is on another machine):
stratum://192.168.1.100:3333
stratum://your-node-ip:3333
```

**Note:** This system is designed for solo mining. Your miner connects directly to your Quai node's stratum proxy, and all block rewards go to your wallet with no pool fees.

### Environment Variables

**Automatically configured by install script:**
- `ROC_ENABLE_PRE_VEGA=1` (for AMD Polaris cards like RX 590)
- `HSA_OVERRIDE_GFX_VERSION=8.0.0` (for RX 590)
- `GPU_FORCE_64BIT_PTR=1`
- `GPU_MAX_HEAP_SIZE=100`
- `GPU_USE_SYNC_OBJECTS=1`
- `GPU_MAX_ALLOC_PERCENT=100`
- `GPU_SINGLE_ALLOC_PERCENT=100`

**For AMD RX 590:**
These are automatically set when RX 590 is detected. See `/etc/quaiminer/environment` for the complete list.

## 📊 Dashboard Features

- **Solo Mining Configuration**: Configure your miner to connect to your node's stratum proxy
- **Real-Time Monitoring**: Hash rate, shares, temperature, power usage
- **Profitability Tracking**: Track your mining profitability with real-time calculations
- **GPU Management**: Individual GPU metrics and health monitoring
- **Node Integration**: Connect to your own Quai node's RPC and stratum proxy
- **Miner Controls**: Start, stop, restart with one click
- **Logs Viewer**: View miner output in real-time
- **Multi-Rig Management**: Manage multiple solo mining rigs
- **Historical Data**: Track performance over time with charts
- **Auto Chain Switching**: Automatically mines the most profitable Quai chain

## 🔄 Auto-Start on Boot

The miner automatically starts on system boot via systemd service:
```bash
# Check status
sudo systemctl status quaiminer

# Enable auto-start
sudo systemctl enable quaiminer

# Start now
sudo systemctl start quaiminer
```

## 🌐 Remote Management

Access your mining rig from anywhere:
1. Set up port forwarding (optional)
2. Access dashboard: `http://your-rig-ip:3000`
3. Configure and control mining remotely

## 🛠️ Troubleshooting

### Miner Not Starting
```bash
# Check service status
sudo systemctl status quaiminer

# View logs
sudo journalctl -u quaiminer -f

# Check configuration
cat /etc/quaiminer/config.json
```

### Stratum Connection Issues
- Verify stratum address format (stratum://host:port)
- Check network connectivity to your node
- Verify firewall rules (port 3333)
- Check miner logs for connection errors
- Ensure your Quai node's stratum proxy is running

## 📝 Next Steps

1. Install QuaiMiner OS
2. Configure your stratum address (your node's stratum proxy)
3. Start mining
4. Monitor via dashboard

For detailed documentation, see:
- [Installation Guide](INSTALL.md)
- [Configuration Guide](CONFIG.md)
- [API Documentation](API.md)

