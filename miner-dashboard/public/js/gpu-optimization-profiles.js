/**
 * GPU Optimization Profiles - Energy & Profit Efficient Defaults
 * 
 * This module provides comprehensive GPU-specific optimization profiles
 * that balance energy efficiency with maximum profitability for Quai Network mining.
 * 
 * Each profile includes:
 * - Core clock settings (MHz offset)
 * - Memory clock settings (MHz offset)
 * - Power limit (% or offset)
 * - Fan speed (%)
 * - Voltage (mV offset, if applicable)
 * - Expected hash rate (MH/s)
 * - Expected power consumption (W)
 * - Efficiency rating (MH/s per Watt)
 * - Profitability rating (based on hash/watt ratio)
 */

class GPUOptimizationProfiles {
    constructor() {
        this.profiles = this.loadProfiles();
        this.efficiencyTargets = {
            excellent: 0.08,  // > 0.08 MH/s per Watt
            good: 0.06,      // 0.06-0.08 MH/s per Watt
            acceptable: 0.04, // 0.04-0.06 MH/s per Watt
            poor: 0.02       // < 0.04 MH/s per Watt
        };
    }

    /**
     * Load comprehensive GPU optimization profiles
     * Optimized for energy efficiency and maximum profitability
     */
    loadProfiles() {
        return {
            // ============================================
            // AMD RADEON PROFILES
            // ============================================
            
            // AMD RX 590 (Polaris 20) - Most efficient settings
            'amd-rx-590': {
                vendor: 'AMD',
                architecture: 'Polaris 20',
                name: 'AMD Radeon RX 590',
                // Energy & Profit Efficient Settings
                coreClock: 1215,        // MHz (underclocked for efficiency)
                memoryClock: 1900,      // MHz (slightly underclocked)
                powerLimit: -25,        // -25% from stock (efficiency mode)
                fanSpeed: 60,           // % (balanced cooling)
                voltage: 875,           // mV (undervolted)
                intensity: 20,          // Mining intensity
                worksize: 256,          // Work size
                // Expected Performance
                expectedHashRate: 10.5,  // MH/s (ProgPoW)
                expectedPower: 150,      // Watts
                efficiency: 0.07,        // MH/s per Watt
                profitability: 'excellent',
                qiEfficiency: 'excellent', // QI production efficiency rating
                qiPerKWh: 0.15,          // QI tokens per kWh (energy-based)
                // Temperature targets
                targetTemp: 70,         // °C
                maxTemp: 80,            // °C
                // Notes
                notes: 'Optimized for maximum efficiency. Slight hash rate reduction for significant power savings.',
                recommended: true
            },

            // AMD RX 580 (Polaris 20) - Efficiency optimized
            'amd-rx-580': {
                vendor: 'AMD',
                architecture: 'Polaris 20',
                name: 'AMD Radeon RX 580',
                coreClock: 1150,
                memoryClock: 1900,
                powerLimit: -20,
                fanSpeed: 65,
                voltage: 850,
                intensity: 20,
                worksize: 256,
                expectedHashRate: 9.5,
                expectedPower: 140,
                efficiency: 0.068,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.14,
                targetTemp: 70,
                maxTemp: 80,
                notes: 'Excellent efficiency profile. Best ROI for RX 580.',
                recommended: true
            },

            // AMD RX 570 (Polaris 20) - Budget efficiency
            'amd-rx-570': {
                vendor: 'AMD',
                architecture: 'Polaris 20',
                name: 'AMD Radeon RX 570',
                coreClock: 1100,
                memoryClock: 1850,
                powerLimit: -20,
                fanSpeed: 70,
                voltage: 850,
                intensity: 20,
                worksize: 256,
                expectedHashRate: 8.5,
                expectedPower: 120,
                efficiency: 0.071,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.15,
                targetTemp: 70,
                maxTemp: 80,
                notes: 'Budget-friendly with excellent efficiency.',
                recommended: true
            },

            // AMD RX 6000 Series (RDNA 2) - Modern efficiency
            'amd-rx-6700xt': {
                vendor: 'AMD',
                architecture: 'RDNA 2',
                name: 'AMD Radeon RX 6700 XT',
                coreClock: 2000,
                memoryClock: 2000,
                powerLimit: -15,
                fanSpeed: 55,
                voltage: 1100,
                intensity: 24,
                worksize: 256,
                expectedHashRate: 18.0,
                expectedPower: 180,
                efficiency: 0.10,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.18,
                targetTemp: 65,
                maxTemp: 75,
                notes: 'Modern architecture with excellent efficiency.',
                recommended: true
            },

            'amd-rx-6800': {
                vendor: 'AMD',
                architecture: 'RDNA 2',
                name: 'AMD Radeon RX 6800',
                coreClock: 2100,
                memoryClock: 2000,
                powerLimit: -12,
                fanSpeed: 55,
                voltage: 1150,
                intensity: 26,
                worksize: 256,
                expectedHashRate: 22.0,
                expectedPower: 200,
                efficiency: 0.11,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.20,
                targetTemp: 65,
                maxTemp: 75,
                notes: 'High performance with excellent efficiency.',
                recommended: true
            },

            // AMD RX 7000 Series (RDNA 3) - Latest generation
            'amd-rx-7900xt': {
                vendor: 'AMD',
                architecture: 'RDNA 3',
                name: 'AMD Radeon RX 7900 XT',
                coreClock: 2400,
                memoryClock: 2500,
                powerLimit: -10,
                fanSpeed: 50,
                voltage: 1200,
                intensity: 28,
                worksize: 256,
                expectedHashRate: 32.0,
                expectedPower: 280,
                efficiency: 0.114,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.22,
                targetTemp: 65,
                maxTemp: 75,
                notes: 'Latest generation with best efficiency.',
                recommended: true
            },

            // ============================================
            // NVIDIA PROFILES
            // ============================================

            // NVIDIA RTX 3060 (Ampere) - Efficiency champion
            'nvidia-rtx-3060': {
                vendor: 'NVIDIA',
                architecture: 'Ampere',
                name: 'NVIDIA GeForce RTX 3060',
                coreClock: -200,        // Underclock core
                memoryClock: 1000,       // +1000 MHz memory
                powerLimit: 65,          // 65% power limit
                fanSpeed: 70,
                voltage: 0,              // Locked on most models
                intensity: 24,
                worksize: 128,
                expectedHashRate: 20.0,
                expectedPower: 130,
                efficiency: 0.154,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.25,
                targetTemp: 60,
                maxTemp: 70,
                notes: 'Excellent efficiency. Best ROI for RTX 30 series.',
                recommended: true
            },

            'nvidia-rtx-3070': {
                vendor: 'NVIDIA',
                architecture: 'Ampere',
                name: 'NVIDIA GeForce RTX 3070',
                coreClock: -200,
                memoryClock: 1200,
                powerLimit: 70,
                fanSpeed: 70,
                voltage: 0,
                intensity: 26,
                worksize: 128,
                expectedHashRate: 28.0,
                expectedPower: 180,
                efficiency: 0.156,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.26,
                targetTemp: 60,
                maxTemp: 70,
                notes: 'High performance with excellent efficiency.',
                recommended: true
            },

            'nvidia-rtx-3080': {
                vendor: 'NVIDIA',
                architecture: 'Ampere',
                name: 'NVIDIA GeForce RTX 3080',
                coreClock: -200,
                memoryClock: 1500,
                powerLimit: 70,
                fanSpeed: 70,
                voltage: 0,
                intensity: 28,
                worksize: 128,
                expectedHashRate: 38.0,
                expectedPower: 250,
                efficiency: 0.152,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.25,
                targetTemp: 60,
                maxTemp: 70,
                notes: 'Top-tier performance with excellent efficiency.',
                recommended: true
            },

            // NVIDIA RTX 40 Series (Ada Lovelace) - Latest generation
            'nvidia-rtx-4060': {
                vendor: 'NVIDIA',
                architecture: 'Ada Lovelace',
                name: 'NVIDIA GeForce RTX 4060',
                coreClock: -200,
                memoryClock: 1200,
                powerLimit: 70,
                fanSpeed: 65,
                voltage: 0,
                intensity: 26,
                worksize: 128,
                expectedHashRate: 24.0,
                expectedPower: 140,
                efficiency: 0.171,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.28,
                targetTemp: 60,
                maxTemp: 70,
                notes: 'Latest generation with best efficiency.',
                recommended: true
            },

            'nvidia-rtx-4070': {
                vendor: 'NVIDIA',
                architecture: 'Ada Lovelace',
                name: 'NVIDIA GeForce RTX 4070',
                coreClock: -200,
                memoryClock: 1500,
                powerLimit: 75,
                fanSpeed: 65,
                voltage: 0,
                intensity: 28,
                worksize: 128,
                expectedHashRate: 35.0,
                expectedPower: 200,
                efficiency: 0.175,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.29,
                targetTemp: 60,
                maxTemp: 70,
                notes: 'Excellent efficiency for high performance.',
                recommended: true
            },

            'nvidia-rtx-4080': {
                vendor: 'NVIDIA',
                architecture: 'Ada Lovelace',
                name: 'NVIDIA GeForce RTX 4080',
                coreClock: -200,
                memoryClock: 1500,
                powerLimit: 75,
                fanSpeed: 65,
                voltage: 0,
                intensity: 30,
                worksize: 128,
                expectedHashRate: 48.0,
                expectedPower: 280,
                efficiency: 0.171,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.28,
                targetTemp: 60,
                maxTemp: 70,
                notes: 'Top-tier performance with excellent efficiency.',
                recommended: true
            },

            // NVIDIA GTX 10/16 Series (Pascal/Turing) - Budget efficiency
            'nvidia-gtx-1060': {
                vendor: 'NVIDIA',
                architecture: 'Pascal',
                name: 'NVIDIA GeForce GTX 1060',
                coreClock: 100,
                memoryClock: 500,
                powerLimit: 80,
                fanSpeed: 75,
                voltage: 0,
                intensity: 20,
                worksize: 128,
                expectedHashRate: 8.0,
                expectedPower: 100,
                efficiency: 0.08,
                profitability: 'good',
                qiEfficiency: 'good',
                qiPerKWh: 0.12,
                targetTemp: 65,
                maxTemp: 75,
                notes: 'Budget-friendly with good efficiency.',
                recommended: true
            },

            'nvidia-gtx-1660': {
                vendor: 'NVIDIA',
                architecture: 'Turing',
                name: 'NVIDIA GeForce GTX 1660',
                coreClock: 100,
                memoryClock: 600,
                powerLimit: 80,
                fanSpeed: 75,
                voltage: 0,
                intensity: 22,
                worksize: 128,
                expectedHashRate: 12.0,
                expectedPower: 120,
                efficiency: 0.10,
                profitability: 'excellent',
                qiEfficiency: 'excellent',
                qiPerKWh: 0.16,
                targetTemp: 65,
                maxTemp: 75,
                notes: 'Excellent efficiency for budget mining.',
                recommended: true
            }
        };
    }

    /**
     * Get optimization profile for a GPU
     */
    getProfile(gpuName, vendor) {
        if (!gpuName || !vendor) return null;

        const name = gpuName.toLowerCase().trim();
        const ven = vendor.toLowerCase().trim();

        // AMD matching
        if (ven.includes('amd') || ven.includes('radeon')) {
            if (name.includes('590')) return this.profiles['amd-rx-590'];
            if (name.includes('580')) return this.profiles['amd-rx-580'];
            if (name.includes('570')) return this.profiles['amd-rx-570'];
            if (name.includes('6700')) return this.profiles['amd-rx-6700xt'];
            if (name.includes('6800')) return this.profiles['amd-rx-6800'];
            if (name.includes('7900')) return this.profiles['amd-rx-7900xt'];
        }

        // NVIDIA matching
        if (ven.includes('nvidia') || ven.includes('geforce')) {
            if (name.includes('3060')) return this.profiles['nvidia-rtx-3060'];
            if (name.includes('3070')) return this.profiles['nvidia-rtx-3070'];
            if (name.includes('3080')) return this.profiles['nvidia-rtx-3080'];
            if (name.includes('4060')) return this.profiles['nvidia-rtx-4060'];
            if (name.includes('4070')) return this.profiles['nvidia-rtx-4070'];
            if (name.includes('4080')) return this.profiles['nvidia-rtx-4080'];
            if (name.includes('1060')) return this.profiles['nvidia-gtx-1060'];
            if (name.includes('1660')) return this.profiles['nvidia-gtx-1660'];
        }

        return null;
    }

    /**
     * Get default settings for a GPU (fallback if no profile found)
     */
    getDefaultSettings(vendor) {
        const ven = (vendor || '').toLowerCase();
        
        if (ven.includes('amd') || ven.includes('radeon')) {
            return {
                coreClock: 1200,
                memoryClock: 1900,
                powerLimit: -20,
                fanSpeed: 60,
                intensity: 20,
                worksize: 256,
                expectedHashRate: 10.0,
                expectedPower: 150,
                efficiency: 0.067,
                profitability: 'good'
            };
        } else if (ven.includes('nvidia') || ven.includes('geforce')) {
            return {
                coreClock: -200,
                memoryClock: 1000,
                powerLimit: 70,
                fanSpeed: 70,
                intensity: 24,
                worksize: 128,
                expectedHashRate: 20.0,
                expectedPower: 150,
                efficiency: 0.133,
                profitability: 'excellent'
            };
        }

        // Generic fallback
        return {
            coreClock: 0,
            memoryClock: 200,
            powerLimit: 80,
            fanSpeed: 60,
            intensity: 20,
            worksize: 256,
            expectedHashRate: 10.0,
            expectedPower: 150,
            efficiency: 0.067,
            profitability: 'acceptable'
        };
    }

    /**
     * Calculate efficiency rating
     */
    getEfficiencyRating(efficiency) {
        if (efficiency >= this.efficiencyTargets.excellent) return 'excellent';
        if (efficiency >= this.efficiencyTargets.good) return 'good';
        if (efficiency >= this.efficiencyTargets.acceptable) return 'acceptable';
        return 'poor';
    }

    /**
     * Get all recommended profiles
     */
    getRecommendedProfiles() {
        return Object.values(this.profiles).filter(p => p.recommended);
    }

    /**
     * Get profiles by vendor
     */
    getProfilesByVendor(vendor) {
        const ven = (vendor || '').toLowerCase();
        return Object.values(this.profiles).filter(p => 
            p.vendor.toLowerCase().includes(ven)
        );
    }
}

// Export for use
if (typeof window !== 'undefined') {
    window.GPUOptimizationProfiles = GPUOptimizationProfiles;
}

