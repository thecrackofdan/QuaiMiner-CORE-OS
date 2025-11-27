/**
 * Script Loader - Optimized script loading with lazy loading
 * Loads critical scripts immediately, defers non-critical scripts
 */

class ScriptLoader {
    constructor() {
        this.criticalScripts = [
            'js/utils.js',
            'js/toast.js',
            'js/config.js',
            'js/dashboard.js'
        ];
        
        this.deferredScripts = [
            'js/gpu-optimization-profiles.js', // Load GPU profiles early
            'js/qi-token-calculator.js', // Load QI calculator early
            'js/historical-charts.js',
            'js/profitability-calculator.js',
            'js/profit-trend-chart.js',
            'js/multi-gpu.js',
            'js/leaderboard.js',
            'js/achievements.js',
            'js/setup-wizard.js',
            'js/enhanced-onboarding.js',
            'js/ml-features.js',
            'js/mining-insights.js',
            'js/gpu-tuner.js',
            'js/merged-mining-wizard.js',
            'js/profit-optimizer.js',
            'js/multi-rig-manager.js',
            'js/safe-evaluator.js',
            'js/alert-manager.js',
            'js/auto-chain-switcher.js',
            'js/quai-metrics-ui.js',
            'js/alerts-ui.js',
            'js/staking-manager.js',
            'js/staking-ui.js',
            'js/auto-setup.js',
            'js/smart-defaults.js',
            'js/one-click-mining.js',
            'js/quai-features.js',
            'js/enhanced-animations.js',
            'js/error-handler.js',
            'js/rewards-tracker.js',
            'js/gpu-optimizer.js',
            'js/stability-monitor.js',
            'js/ui-improvements.js'
        ];
        
        this.loadedScripts = new Set();
    }
    
    /**
     * Load a script dynamically
     */
    loadScript(src) {
        return new Promise((resolve, reject) => {
            // Check if already loaded
            if (this.loadedScripts.has(src)) {
                resolve();
                return;
            }
            
            // Check if script tag already exists
            const existing = document.querySelector(`script[src="${src}"]`);
            if (existing) {
                this.loadedScripts.add(src);
                resolve();
                return;
            }
            
            const script = document.createElement('script');
            script.src = src;
            script.async = true;
            script.onload = () => {
                this.loadedScripts.add(src);
                resolve();
            };
            script.onerror = () => {
                if (window.logger) window.logger.warn(`Failed to load script: ${src}`);
                reject(new Error(`Failed to load ${src}`));
            };
            document.head.appendChild(script);
        });
    }
    
    /**
     * Load critical scripts immediately
     */
    async loadCriticalScripts() {
        const promises = this.criticalScripts.map(src => this.loadScript(src));
        await Promise.all(promises);
    }
    
    /**
     * Load deferred scripts when needed
     */
    async loadDeferredScripts() {
        // Load in batches to avoid overwhelming the browser
        const batchSize = 5;
        for (let i = 0; i < this.deferredScripts.length; i += batchSize) {
            const batch = this.deferredScripts.slice(i, i + batchSize);
            await Promise.all(batch.map(src => this.loadScript(src).catch(() => {})));
            
            // Small delay between batches
            if (i + batchSize < this.deferredScripts.length) {
                await new Promise(resolve => setTimeout(resolve, 100));
            }
        }
    }
    
    /**
     * Load scripts when they're needed (lazy loading)
     */
    loadOnDemand(scriptName) {
        const script = this.deferredScripts.find(s => s.includes(scriptName));
        if (script) {
            return this.loadScript(script);
        }
        return Promise.reject(new Error(`Script not found: ${scriptName}`));
    }
    
    /**
     * Initialize script loading
     */
    async init() {
        // Load critical scripts first
        await this.loadCriticalScripts();
        
        // Load deferred scripts after a short delay (when page is interactive)
        if (document.readyState === 'complete') {
            // Page already loaded, load deferred scripts immediately
            this.loadDeferredScripts();
        } else {
            // Wait for page to be interactive
            window.addEventListener('load', () => {
                // Small delay to let critical scripts initialize
                setTimeout(() => {
                    this.loadDeferredScripts();
                }, 500);
            });
        }
    }
}

// Initialize script loader
if (typeof window !== 'undefined') {
    window.scriptLoader = new ScriptLoader();
    
    // Start loading when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            window.scriptLoader.init();
        });
    } else {
        window.scriptLoader.init();
    }
}

