#!/bin/bash

# QuaiMiner CORE - System Test Script
# Tests all components for functionality

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0

echo -e "${BLUE}🧪 QuaiMiner CORE - System Test${NC}"
echo "===================================="
echo ""

# Test 1: Hardware Detector
test_hardware_detector() {
    echo -e "${YELLOW}Test 1: Hardware Detector${NC}"
    if [ -f "./hardware-detector.sh" ]; then
        if bash -n ./hardware-detector.sh 2>/dev/null; then
            echo -e "${GREEN}  ✅ Syntax OK${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}  ❌ Syntax Error${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}  ❌ File not found${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# Test 2: Driver Manager
test_driver_manager() {
    echo -e "${YELLOW}Test 2: Driver Manager${NC}"
    if [ -f "./driver-manager.sh" ]; then
        if bash -n ./driver-manager.sh 2>/dev/null; then
            echo -e "${GREEN}  ✅ Syntax OK${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}  ❌ Syntax Error${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}  ❌ File not found${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# Test 3: GPU Optimizer
test_gpu_optimizer() {
    echo -e "${YELLOW}Test 3: GPU Optimizer${NC}"
    if [ -f "./gpu-optimizer.sh" ]; then
        if bash -n ./gpu-optimizer.sh 2>/dev/null; then
            echo -e "${GREEN}  ✅ Syntax OK${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}  ❌ Syntax Error${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}  ❌ File not found${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# Test 4: Multi-Rig Manager
test_multi_rig_manager() {
    echo -e "${YELLOW}Test 4: Multi-Rig Manager${NC}"
    if [ -f "./multi-rig-manager.sh" ]; then
        if bash -n ./multi-rig-manager.sh 2>/dev/null; then
            echo -e "${GREEN}  ✅ Syntax OK${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}  ❌ Syntax Error${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}  ❌ File not found${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# Test 5: Unified Installer
test_unified_installer() {
    echo -e "${YELLOW}Test 5: Unified Installer${NC}"
    if [ -f "./install-unified.sh" ]; then
        if bash -n ./install-unified.sh 2>/dev/null; then
            echo -e "${GREEN}  ✅ Syntax OK${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}  ❌ Syntax Error${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}  ❌ File not found${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# Test 6: Multi-GPU API
test_multigpu_api() {
    echo -e "${YELLOW}Test 6: Multi-GPU API${NC}"
    if [ -f "./miner-api-multigpu.js" ]; then
        if node -c ./miner-api-multigpu.js 2>/dev/null; then
            echo -e "${GREEN}  ✅ Syntax OK${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}  ❌ Syntax Error${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        echo -e "${RED}  ❌ File not found${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# Test 7: Required Dependencies
test_dependencies() {
    echo -e "${YELLOW}Test 7: Required Dependencies${NC}"
    DEPS_OK=true
    
    # Check for Python 3
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}  ✅ Python 3 found${NC}"
    else
        echo -e "${RED}  ❌ Python 3 not found${NC}"
        DEPS_OK=false
    fi
    
    # Check for jq (optional but helpful)
    if command -v jq &> /dev/null; then
        echo -e "${GREEN}  ✅ jq found${NC}"
    else
        echo -e "${YELLOW}  ⚠️  jq not found (optional)${NC}"
    fi
    
    if [ "$DEPS_OK" = true ]; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# Run all tests
test_hardware_detector
test_driver_manager
test_gpu_optimizer
test_multi_rig_manager
test_unified_installer
test_multigpu_api
test_dependencies

# Summary
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Test Summary:${NC}"
echo -e "${GREEN}  Passed: $PASSED${NC}"
echo -e "${RED}  Failed: $FAILED${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi

