/**
 * QI Token Calculator - Energy-Based QI Token Production
 * 
 * QI tokens are tied to the energy consumed during mining.
 * More energy-efficient mining produces more QI tokens per unit of energy.
 * 
 * Formula: QI Production = Energy Consumed × Efficiency Multiplier × Network Factor
 * 
 * Key Principles:
 * - Lower power consumption = Higher QI efficiency
 * - Better hash/watt ratio = More QI per kWh
 * - Energy-efficient GPUs maximize QI production
 */

class QITokenCalculator {
    constructor() {
        // QI token production constants (energy-based)
        // These values represent QI tokens per kWh of energy consumed
        this.baseQIPerKWh = 0.1; // Base QI production per kWh
        
        // Efficiency multipliers (higher efficiency = more QI per kWh)
        this.efficiencyMultipliers = {
            excellent: 1.5,  // > 0.08 MH/s per Watt
            good: 1.2,       // 0.06-0.08 MH/s per Watt
            acceptable: 1.0,  // 0.04-0.06 MH/s per Watt
            poor: 0.8        // < 0.04 MH/s per Watt
        };
        
        // Network factors (may vary by chain/region)
        this.networkFactors = {
            Prime: 1.0,      // Prime chain
            Cyprus: 1.1,    // Cyprus region (slightly higher QI)
            Paxos: 1.1,     // Paxos region
            Hydra: 1.1,     // Hydra region
            'Cyprus-1': 1.2, // Zone chains (higher QI)
            'Cyprus-2': 1.2,
            'Cyprus-3': 1.2,
            'Paxos-1': 1.2,
            'Paxos-2': 1.2,
            'Paxos-3': 1.2,
            'Hydra-1': 1.2,
            'Hydra-2': 1.2,
            'Hydra-3': 1.2
        };
        
        // QI price (can be updated from network data)
        this.qiPriceUSD = 0.005; // Default QI price in USD
    }

    /**
     * Calculate QI token production based on energy consumption
     * @param {number} powerUsage - Power usage in Watts
     * @param {number} hours - Time period in hours
     * @param {number} efficiency - Mining efficiency (MH/s per Watt)
     * @param {string} chain - Chain name (Prime, Cyprus, etc.)
     * @returns {Object} QI production data
     */
    calculateQIProduction(powerUsage, hours, efficiency, chain = 'Prime') {
        // Calculate energy consumed (kWh)
        const energyKWh = (powerUsage / 1000) * hours;
        
        // Determine efficiency rating
        const efficiencyRating = this.getEfficiencyRating(efficiency);
        const efficiencyMultiplier = this.efficiencyMultipliers[efficiencyRating];
        
        // Get network factor
        const networkFactor = this.networkFactors[chain] || 1.0;
        
        // Calculate QI production
        // Formula: QI = Energy (kWh) × Base Rate × Efficiency Multiplier × Network Factor
        const qiProduced = energyKWh * this.baseQIPerKWh * efficiencyMultiplier * networkFactor;
        
        // Calculate QI value in USD
        const qiValueUSD = qiProduced * this.qiPriceUSD;
        
        // Calculate QI per kWh (efficiency metric)
        const qiPerKWh = qiProduced / energyKWh;
        
        return {
            qiProduced: qiProduced,
            qiValueUSD: qiValueUSD,
            energyKWh: energyKWh,
            efficiencyRating: efficiencyRating,
            efficiencyMultiplier: efficiencyMultiplier,
            networkFactor: networkFactor,
            qiPerKWh: qiPerKWh,
            chain: chain
        };
    }

    /**
     * Calculate QI production for a GPU
     * @param {Object} gpu - GPU data object
     * @param {number} hours - Time period in hours
     * @param {string} chain - Chain name
     * @returns {Object} QI production data
     */
    calculateGPUQI(gpu, hours = 24, chain = 'Prime') {
        const powerUsage = gpu.powerUsage || gpu.expectedPower || 150;
        const hashRate = gpu.hashRate || gpu.expectedHashRate || 10;
        
        // Calculate efficiency (MH/s per Watt)
        const efficiency = hashRate / powerUsage;
        
        return this.calculateQIProduction(powerUsage, hours, efficiency, chain);
    }

    /**
     * Calculate optimal QI production settings for a GPU
     * @param {Object} gpuProfile - GPU optimization profile
     * @param {string} chain - Chain name
     * @returns {Object} Optimal QI production data
     */
    calculateOptimalQI(gpuProfile, chain = 'Prime') {
        const powerUsage = gpuProfile.expectedPower || 150;
        const hashRate = gpuProfile.expectedHashRate || 10;
        const efficiency = gpuProfile.efficiency || (hashRate / powerUsage);
        
        // Calculate daily QI production
        const dailyQI = this.calculateQIProduction(powerUsage, 24, efficiency, chain);
        
        // Calculate monthly and yearly projections
        const monthlyQI = this.calculateQIProduction(powerUsage, 24 * 30, efficiency, chain);
        const yearlyQI = this.calculateQIProduction(powerUsage, 24 * 365, efficiency, chain);
        
        return {
            daily: dailyQI,
            monthly: monthlyQI,
            yearly: yearlyQI,
            efficiency: efficiency,
            efficiencyRating: this.getEfficiencyRating(efficiency),
            recommendations: this.getQIRecommendations(gpuProfile, efficiency)
        };
    }

    /**
     * Get efficiency rating based on MH/s per Watt
     */
    getEfficiencyRating(efficiency) {
        if (efficiency >= 0.08) return 'excellent';
        if (efficiency >= 0.06) return 'good';
        if (efficiency >= 0.04) return 'acceptable';
        return 'poor';
    }

    /**
     * Get recommendations for maximizing QI production
     */
    getQIRecommendations(gpuProfile, currentEfficiency) {
        const recommendations = [];
        const rating = this.getEfficiencyRating(currentEfficiency);
        
        if (rating === 'poor' || rating === 'acceptable') {
            recommendations.push({
                type: 'power',
                message: 'Reduce power limit to improve energy efficiency',
                impact: 'High',
                action: 'Lower power limit by 10-15% to increase QI per kWh'
            });
        }
        
        if (gpuProfile.powerLimit > -10) {
            recommendations.push({
                type: 'undervolt',
                message: 'Undervolt GPU to reduce power consumption',
                impact: 'High',
                action: 'Reduce voltage by 50-100mV to lower power draw'
            });
        }
        
        if (rating !== 'excellent') {
            recommendations.push({
                type: 'optimize',
                message: 'Optimize GPU settings for better efficiency',
                impact: 'Medium',
                action: 'Use energy-efficient profile from GPU optimizer'
            });
        }
        
        return recommendations;
    }

    /**
     * Compare QI production across different GPU profiles
     */
    compareQIProduction(profiles, chain = 'Prime') {
        return profiles.map(profile => {
            const qiData = this.calculateOptimalQI(profile, chain);
            return {
                profile: profile,
                qiData: qiData,
                dailyQI: qiData.daily.qiProduced,
                dailyValue: qiData.daily.qiValueUSD,
                efficiency: qiData.efficiency,
                rating: qiData.efficiencyRating
            };
        }).sort((a, b) => b.dailyQI - a.dailyQI); // Sort by QI production (highest first)
    }

    /**
     * Calculate combined QUAI + QI profitability
     */
    calculateCombinedProfitability(quaiEarnings, qiData, electricityCost) {
        const totalRevenue = quaiEarnings + qiData.qiValueUSD;
        const totalCost = (qiData.energyKWh / 24) * electricityCost; // Daily cost
        const profit = totalRevenue - totalCost;
        const profitMargin = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0;
        
        return {
            totalRevenue: totalRevenue,
            totalCost: totalCost,
            profit: profit,
            profitMargin: profitMargin,
            quaiEarnings: quaiEarnings,
            qiEarnings: qiData.qiValueUSD,
            qiProduced: qiData.qiProduced
        };
    }

    /**
     * Update QI price from network data
     */
    updateQIPrice(priceUSD) {
        this.qiPriceUSD = priceUSD;
    }

    /**
     * Get QI production efficiency tips
     */
    getEfficiencyTips() {
        return [
            {
                tip: 'Undervolt your GPU',
                description: 'Reducing voltage lowers power consumption while maintaining hash rate, increasing QI per kWh',
                impact: 'High'
            },
            {
                tip: 'Optimize power limit',
                description: 'Lower power limits improve efficiency. Aim for 70-80% of max power for best QI production',
                impact: 'High'
            },
            {
                tip: 'Mine on Zone chains',
                description: 'Zone chains (Cyprus-1, Paxos-1, etc.) offer 20% higher QI production rates',
                impact: 'Medium'
            },
            {
                tip: 'Maintain optimal temperatures',
                description: 'Lower temperatures allow for better efficiency. Keep GPUs at 60-70°C for maximum QI',
                impact: 'Medium'
            },
            {
                tip: 'Use energy-efficient GPU profiles',
                description: 'Select GPU profiles optimized for energy efficiency to maximize QI production',
                impact: 'High'
            }
        ];
    }
}

// Export for use
if (typeof window !== 'undefined') {
    window.QITokenCalculator = QITokenCalculator;
}

