# QI Token Integration - Energy-Based Mining

## Overview

QI tokens are **energy-based tokens** tied to the energy consumed during mining. Unlike QUAI tokens which are based on hash rate and block discovery, QI tokens are directly proportional to energy consumption with efficiency multipliers.

## Key Principles

1. **Energy-Based Production**: QI production = Energy (kWh) × Efficiency Multiplier × Network Factor
2. **Efficiency Matters**: More energy-efficient GPUs produce more QI tokens per kWh
3. **Chain-Specific Rates**: Zone chains (Cyprus-1, Paxos-1, etc.) offer 20% higher QI production
4. **Optimal Settings**: Lower power consumption with maintained hash rate maximizes QI production

## Implementation

### New Files Created

1. **`miner-dashboard/public/js/qi-token-calculator.js`**
   - Comprehensive QI token production calculator
   - Energy-based calculations
   - Efficiency multipliers based on GPU efficiency ratings
   - Chain-specific network factors
   - Combined QUAI + QI profitability calculations

2. **Enhanced `miner-dashboard/public/js/gpu-optimization-profiles.js`**
   - Added `qiEfficiency` rating to each GPU profile
   - Added `qiPerKWh` metric for QI production per kWh
   - All profiles optimized for maximum QI production

### Updated Files

1. **`miner-dashboard/public/js/dashboard.js`**
   - Updated QI earnings calculation to use energy-based formula
   - Replaced percentage-based QI calculation with energy-based calculation
   - Integrated QITokenCalculator for accurate QI production

2. **`miner-dashboard/public/js/profitability-calculator.js`**
   - Added QI token production to profitability calculations
   - Added QI value and QI per kWh metrics
   - Combined QUAI + QI revenue for total profitability

3. **`miner-dashboard/public/js/smart-defaults.js`**
   - Integrated with GPUOptimizationProfiles for energy-efficient defaults
   - All default settings optimized for maximum QI production

4. **`miner-dashboard/public/index.html`**
   - Added script tags for GPU optimization profiles and QI calculator
   - Scripts loaded early for proper initialization

## QI Production Formula

```
QI Production = Energy (kWh) × Base Rate (0.1 QI/kWh) × Efficiency Multiplier × Network Factor
```

### Efficiency Multipliers

- **Excellent** (> 0.08 MH/s per Watt): 1.5x multiplier
- **Good** (0.06-0.08 MH/s per Watt): 1.2x multiplier
- **Acceptable** (0.04-0.06 MH/s per Watt): 1.0x multiplier
- **Poor** (< 0.04 MH/s per Watt): 0.8x multiplier

### Network Factors

- **Prime Chain**: 1.0x
- **Region Chains** (Cyprus, Paxos, Hydra): 1.1x
- **Zone Chains** (Cyprus-1, Paxos-1, etc.): 1.2x

## GPU Optimization for QI Production

All GPU profiles are now optimized for:
1. **Energy Efficiency**: Lower power consumption
2. **Hash Rate Maintenance**: Maintain hash rate while reducing power
3. **Maximum QI per kWh**: Optimize for QI production efficiency

### Example: AMD RX 590

- **Power**: 150W (reduced from stock ~225W)
- **Hash Rate**: 10.5 MH/s
- **Efficiency**: 0.07 MH/s per Watt (Excellent)
- **QI per kWh**: 0.15 QI/kWh
- **Daily QI** (at 150W): ~0.54 QI/day

## Recommendations for Maximum QI Production

1. **Undervolt GPU**: Reduce voltage by 50-100mV to lower power draw
2. **Optimize Power Limit**: Use 70-80% of max power for best efficiency
3. **Mine on Zone Chains**: 20% higher QI production rates
4. **Maintain Optimal Temperatures**: 60-70°C for maximum efficiency
5. **Use Energy-Efficient Profiles**: Select GPU profiles optimized for efficiency

## Benefits

1. **Accurate QI Calculations**: Energy-based calculations reflect actual QI production
2. **Efficiency Optimization**: GPUs optimized for maximum QI per kWh
3. **Combined Profitability**: Total revenue includes both QUAI and QI earnings
4. **Chain Selection**: Zone chains offer higher QI production rates
5. **Professional UI**: Clear QI metrics and recommendations in dashboard

## Status

✅ **Complete**: QI token integration with energy-based calculations
✅ **Complete**: GPU optimization profiles with QI efficiency ratings
✅ **Complete**: Profitability calculator with QI production
✅ **Complete**: Dashboard integration with QI earnings tracking

---

**Date**: 2024-12-26
**Focus**: Energy-Based QI Token Mining

