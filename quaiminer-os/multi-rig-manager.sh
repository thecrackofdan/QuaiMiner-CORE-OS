#!/bin/bash

# QuaiMiner CORE OS - Multi-Rig Management System
# Manages multiple mining rigs from a central location

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RIGS_CONFIG="/etc/quaiminer/rigs-config.json"
RIGS_DIR="/etc/quaiminer/rigs"

mkdir -p "$RIGS_DIR"
mkdir -p /etc/quaiminer

echo -e "${BLUE}🏭 QuaiMiner CORE OS - Multi-Rig Manager${NC}"
echo "========================================"

# Initialize rigs config
init_rigs_config() {
    if [ ! -f "$RIGS_CONFIG" ]; then
        cat > "$RIGS_CONFIG" << EOF
{
  "rigs": [],
  "master_rig": null,
  "sync_interval": 60
}
EOF
    fi
}

# Register current rig
register_rig() {
    local rig_name="$1"
    local rig_ip="${2:-localhost}"
    
    if [ -z "$rig_name" ]; then
        rig_name=$(hostname)
    fi
    
    # Get hardware info
    if [ ! -f "/etc/quaiminer/hardware-info.json" ]; then
        echo -e "${YELLOW}⚠️  Hardware info not found. Running detection...${NC}"
        ./hardware-detector.sh
    fi
    
    RIG_ID=$(python3 -c "import json; print(json.load(open('/etc/quaiminer/hardware-info.json'))['rig_id'])" 2>/dev/null || echo "$rig_name")
    
    # Add rig to config
    python3 << PYTHON_EOF
import json
from datetime import datetime

with open('$RIGS_CONFIG', 'r') as f:
    config = json.load(f)

# Check if rig already exists
rig_exists = False
for rig in config['rigs']:
    if rig['rig_id'] == '$RIG_ID':
        rig['name'] = '$rig_name'
        rig['ip'] = '$rig_ip'
        rig['last_seen'] = datetime.now().isoformat()
        rig_exists = True
        break

if not rig_exists:
    config['rigs'].append({
        "rig_id": "$RIG_ID",
        "name": "$rig_name",
        "ip": "$rig_ip",
        "status": "active",
        "registered": datetime.now().isoformat(),
        "last_seen": datetime.now().isoformat(),
        "gpu_count": 0,
        "hash_rate": 0
    })

with open('$RIGS_CONFIG', 'w') as f:
    json.dump(config, f, indent=2)
PYTHON_EOF
    
    echo -e "${GREEN}✅ Rig registered: $rig_name ($RIG_ID)${NC}"
}

# List all rigs
list_rigs() {
    echo -e "${BLUE}📋 Registered Rigs:${NC}"
    echo ""
    
    python3 << PYTHON_EOF
import json
from datetime import datetime

try:
    with open('$RIGS_CONFIG', 'r') as f:
        config = json.load(f)
    
    if not config.get('rigs'):
        print("  No rigs registered")
    else:
        for i, rig in enumerate(config['rigs'], 1):
            status_icon = "✅" if rig.get('status') == 'active' else "❌"
            print(f"  {i}. {status_icon} {rig['name']} ({rig['rig_id']})")
            print(f"     IP: {rig.get('ip', 'N/A')}")
            print(f"     GPUs: {rig.get('gpu_count', 0)}")
            print(f"     Hash Rate: {rig.get('hash_rate', 0):.2f} MH/s")
            print(f"     Last Seen: {rig.get('last_seen', 'Never')}")
            print()
except Exception as e:
    print(f"  Error: {e}")
PYTHON_EOF
}

# Sync rig status
sync_rig_status() {
    local rig_id="$1"
    
    if [ -z "$rig_id" ]; then
        echo -e "${YELLOW}Syncing all rigs...${NC}"
        # Sync all rigs
    else
        echo -e "${YELLOW}Syncing rig: $rig_id${NC}"
        # Sync specific rig
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "Options:"
    echo "  1. Register this rig"
    echo "  2. List all rigs"
    echo "  3. Sync rig status"
    echo "  4. Exit"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1)
            read -p "Rig name (default: $(hostname)): " rig_name
            read -p "Rig IP (default: localhost): " rig_ip
            register_rig "$rig_name" "$rig_ip"
            ;;
        2)
            list_rigs
            ;;
        3)
            sync_rig_status
            ;;
        4)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

# Main
init_rigs_config

if [ "$#" -eq 0 ]; then
    while true; do
        show_menu
    done
else
    case "$1" in
        register)
            register_rig "$2" "$3"
            ;;
        list)
            list_rigs
            ;;
        sync)
            sync_rig_status "$2"
            ;;
        *)
            echo "Usage: $0 [register|list|sync]"
            exit 1
            ;;
    esac
fi

