/**
 * Mobile Dashboard Enhancements
 * Provides optimized mobile experience with simplified view
 */

class MobileEnhancements {
    constructor() {
        this.isMobile = this.detectMobile();
        this.simplifiedView = false;
        this.init();
    }
    
    detectMobile() {
        return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ||
               (window.innerWidth <= 768);
    }
    
    init() {
        if (!this.isMobile) return;
        
        // Add mobile-specific optimizations
        this.optimizeForMobile();
        this.addMobileControls();
        this.setupTouchGestures();
        this.optimizeCharts();
    }
    
    optimizeForMobile() {
        // Hide non-essential elements on mobile
        const elementsToHide = [
            '.leaderboard-section',
            '.achievements-section',
            '.ml-features-section'
        ];
        
        elementsToHide.forEach(selector => {
            const elements = document.querySelectorAll(selector);
            elements.forEach(el => {
                el.style.display = 'none';
            });
        });
        
        // Simplify hero stats - show only essential
        const heroStats = document.querySelectorAll('.hero-stat-card');
        if (heroStats.length > 4) {
            // Hide less critical stats on mobile
            for (let i = 4; i < heroStats.length; i++) {
                heroStats[i].style.display = 'none';
            }
        }
        
        // Make profit card more prominent on mobile
        const profitCard = document.getElementById('dailyProfitCard');
        if (profitCard) {
            profitCard.style.order = '-1'; // Move to front
            profitCard.style.flexBasis = '100%'; // Full width
        }
    }
    
    addMobileControls() {
        // Add floating action button for quick actions
        const fab = document.createElement('button');
        fab.id = 'mobileFAB';
        fab.className = 'mobile-fab';
        fab.innerHTML = '⚡';
        fab.title = 'Quick Actions';
        fab.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: var(--quai-primary, #ff0000);
            color: white;
            border: none;
            font-size: 24px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(255, 0, 0, 0.4);
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
        `;
        
        fab.addEventListener('click', () => this.showQuickActions());
        document.body.appendChild(fab);
    }
    
    showQuickActions() {
        // Create quick actions menu
        const menu = document.createElement('div');
        menu.id = 'quickActionsMenu';
        menu.style.cssText = `
            position: fixed;
            bottom: 90px;
            right: 20px;
            background: var(--bg-card, #1a1a1a);
            border: 1px solid var(--border-color, #333);
            border-radius: 12px;
            padding: 1rem;
            min-width: 200px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            z-index: 1001;
        `;
        
        menu.innerHTML = `
            <div style="margin-bottom: 0.5rem; font-weight: bold; color: var(--quai-primary);">Quick Actions</div>
            <button class="quick-action-btn" data-action="start">▶️ Start Mining</button>
            <button class="quick-action-btn" data-action="stop">⏹️ Stop Mining</button>
            <button class="quick-action-btn" data-action="stats">📊 View Stats</button>
            <button class="quick-action-btn" data-action="settings">⚙️ Settings</button>
            <button class="quick-action-btn" data-action="close">✕ Close</button>
        `;
        
        // Add styles for buttons
        const style = document.createElement('style');
        style.textContent = `
            .quick-action-btn {
                display: block;
                width: 100%;
                padding: 0.75rem;
                margin: 0.25rem 0;
                background: var(--bg-secondary, #2a2a2a);
                color: var(--text-primary, #fff);
                border: 1px solid var(--border-color, #333);
                border-radius: 6px;
                cursor: pointer;
                text-align: left;
            }
            .quick-action-btn:active {
                background: var(--quai-primary, #ff0000);
            }
        `;
        document.head.appendChild(style);
        
        // Add event listeners
        menu.querySelectorAll('.quick-action-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.target.dataset.action;
                this.handleQuickAction(action);
                menu.remove();
            });
        });
        
        document.body.appendChild(menu);
        
        // Close on outside click
        setTimeout(() => {
            document.addEventListener('click', function closeMenu(e) {
                if (!menu.contains(e.target) && e.target.id !== 'mobileFAB') {
                    menu.remove();
                    document.removeEventListener('click', closeMenu);
                }
            });
        }, 100);
    }
    
    handleQuickAction(action) {
        switch(action) {
            case 'start':
                if (typeof dashboard !== 'undefined' && dashboard.startMining) {
                    dashboard.startMining();
                }
                break;
            case 'stop':
                if (typeof dashboard !== 'undefined' && dashboard.stopMining) {
                    dashboard.stopMining();
                }
                break;
            case 'stats':
                document.getElementById('miningStatsSection')?.scrollIntoView({ behavior: 'smooth' });
                break;
            case 'settings':
                const settingsBtn = document.getElementById('settingsBtn');
                if (settingsBtn) settingsBtn.click();
                break;
        }
    }
    
    setupTouchGestures() {
        // Swipe to refresh
        let touchStartY = 0;
        let touchEndY = 0;
        
        document.addEventListener('touchstart', (e) => {
            touchStartY = e.changedTouches[0].screenY;
        });
        
        document.addEventListener('touchend', (e) => {
            touchEndY = e.changedTouches[0].screenY;
            this.handleSwipe();
        });
    }
    
    handleSwipe() {
        const swipeThreshold = 100;
        const diff = touchStartY - touchEndY;
        
        // Swipe down to refresh
        if (diff < -swipeThreshold && window.scrollY === 0) {
            if (typeof dashboard !== 'undefined' && dashboard.updateUI) {
                dashboard.updateUI();
                if (typeof showToast === 'function') {
                    showToast('Refreshed', 'success');
                }
            }
        }
    }
    
    optimizeCharts() {
        // Reduce chart data points on mobile for better performance
        if (typeof HistoricalCharts !== 'undefined') {
            // Charts will be optimized automatically
        }
        
        // Make charts responsive
        const charts = document.querySelectorAll('canvas');
        charts.forEach(chart => {
            chart.style.maxHeight = '200px';
        });
    }
}

// Initialize mobile enhancements
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        window.mobileEnhancements = new MobileEnhancements();
    });
}

