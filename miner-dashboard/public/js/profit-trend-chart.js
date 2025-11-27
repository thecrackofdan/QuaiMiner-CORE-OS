/**
 * Profit Trend Chart - Real-time profit tracking over time
 * Shows profit history to help miners understand profitability trends
 */

class ProfitTrendChart {
    constructor(dashboard) {
        this.dashboard = dashboard;
        this.chart = null;
        this.profitHistory = [];
        this.maxDataPoints = 60; // Last 60 data points (5 minutes at 5-second intervals)
        this.init();
    }
    
    init() {
        // Create chart container if it doesn't exist
        this.createChartContainer();
        
        // Initialize chart
        this.initChart();
        
        // Update chart periodically
        setInterval(() => this.updateChart(), 5000); // Every 5 seconds
    }
    
    createChartContainer() {
        // Check if container already exists
        if (document.getElementById('profitTrendChart')) return;
        
        // Find the daily profit card
        const dailyProfitCard = document.getElementById('dailyProfitCard');
        if (!dailyProfitCard) return;
        
        // Create chart section after the hero stats
        const heroStats = document.querySelector('.mining-stats-hero');
        if (!heroStats) return;
        
        const chartSection = document.createElement('div');
        chartSection.className = 'profit-trend-section';
        chartSection.style.cssText = `
            margin-top: 2rem;
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1.5rem;
        `;
        chartSection.innerHTML = `
            <h3 style="margin: 0 0 1rem 0; color: var(--quai-primary); display: flex; align-items: center; gap: 0.5rem;">
                📈 Profit Trend (Last Hour)
                <span class="info-icon-small" data-tooltip="Real-time profit tracking over the last hour. Shows how your profitability changes over time.">ℹ️</span>
            </h3>
            <div style="position: relative; height: 200px;">
                <canvas id="profitTrendChart"></canvas>
            </div>
            <div style="margin-top: 1rem; display: flex; gap: 1rem; font-size: 0.85rem; color: var(--text-secondary);">
                <div>
                    <strong>Current:</strong> <span id="currentProfitValue">$0.00</span>
                </div>
                <div>
                    <strong>Average:</strong> <span id="averageProfitValue">$0.00</span>
                </div>
                <div>
                    <strong>Peak:</strong> <span id="peakProfitValue">$0.00</span>
                </div>
            </div>
        `;
        
        // Insert after hero stats section
        const parentSection = heroStats.closest('section');
        if (parentSection) {
            parentSection.after(chartSection);
        }
    }
    
    initChart() {
        const ctx = document.getElementById('profitTrendChart');
        if (!ctx) return;
        
        if (typeof Chart === 'undefined') {
            console.warn('Chart.js not loaded. Profit trend chart will not be available.');
            return;
        }
        
        this.chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Daily Profit ($)',
                    data: [],
                    borderColor: '#00ff00',
                    backgroundColor: 'rgba(0, 255, 0, 0.1)',
                    tension: 0.4,
                    fill: true,
                    pointRadius: 2,
                    pointHoverRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        labels: {
                            color: '#CCCCCC'
                        }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        callbacks: {
                            label: function(context) {
                                return `Profit: $${context.parsed.y.toFixed(2)}`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        ticks: {
                            color: '#CCCCCC',
                            callback: function(value) {
                                return '$' + value.toFixed(2);
                            }
                        },
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        }
                    },
                    x: {
                        ticks: {
                            color: '#CCCCCC',
                            maxTicksLimit: 12
                        },
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        }
                    }
                },
                interaction: {
                    intersect: false,
                    mode: 'index'
                }
            }
        });
    }
    
    addProfitPoint(profit) {
        const now = new Date();
        const timeLabel = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        
        // Add to history
        this.profitHistory.push({
            time: timeLabel,
            profit: profit,
            timestamp: now.getTime()
        });
        
        // Keep only last maxDataPoints
        if (this.profitHistory.length > this.maxDataPoints) {
            this.profitHistory.shift();
        }
    }
    
    updateChart() {
        if (!this.chart) return;
        
        // Get current profit from dashboard
        const dailyProfitEl = document.getElementById('dailyProfit');
        if (!dailyProfitEl) return;
        
        // Parse current profit value
        const profitText = dailyProfitEl.textContent.replace('$', '').trim();
        const currentProfit = parseFloat(profitText) || 0;
        
        // Add to history
        this.addProfitPoint(currentProfit);
        
        // Update chart data
        const labels = this.profitHistory.map(d => d.time);
        const data = this.profitHistory.map(d => d.profit);
        
        this.chart.data.labels = labels;
        this.chart.data.datasets[0].data = data;
        
        // Update color based on profit trend
        if (data.length > 1) {
            const recent = data.slice(-5); // Last 5 points
            const avg = recent.reduce((a, b) => a + b, 0) / recent.length;
            const isIncreasing = currentProfit > avg;
            
            // Green if profitable and increasing, yellow if profitable but decreasing, red if losing
            if (currentProfit > 0) {
                this.chart.data.datasets[0].borderColor = isIncreasing ? '#00ff00' : '#ffff00';
                this.chart.data.datasets[0].backgroundColor = isIncreasing 
                    ? 'rgba(0, 255, 0, 0.1)' 
                    : 'rgba(255, 255, 0, 0.1)';
            } else {
                this.chart.data.datasets[0].borderColor = '#ff0000';
                this.chart.data.datasets[0].backgroundColor = 'rgba(255, 0, 0, 0.1)';
            }
        }
        
        // Update statistics
        this.updateStatistics(data, currentProfit);
        
        // Update chart
        this.chart.update('none'); // 'none' mode for smooth updates
    }
    
    updateStatistics(data, currentProfit) {
        if (data.length === 0) return;
        
        // Calculate average
        const average = data.reduce((a, b) => a + b, 0) / data.length;
        
        // Find peak
        const peak = Math.max(...data);
        
        // Update UI
        const currentEl = document.getElementById('currentProfitValue');
        const averageEl = document.getElementById('averageProfitValue');
        const peakEl = document.getElementById('peakProfitValue');
        
        if (currentEl) {
            currentEl.textContent = `$${currentProfit.toFixed(2)}`;
            currentEl.style.color = currentProfit >= 0 ? '#00ff00' : '#ff0000';
        }
        if (averageEl) {
            averageEl.textContent = `$${average.toFixed(2)}`;
            averageEl.style.color = average >= 0 ? '#00ff00' : '#ff0000';
        }
        if (peakEl) {
            peakEl.textContent = `$${peak.toFixed(2)}`;
            peakEl.style.color = '#00ff00';
        }
    }
}

// Auto-initialize when dashboard is ready
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        // Wait for dashboard to be initialized
        const initProfitChart = () => {
            if (typeof dashboard !== 'undefined' && dashboard) {
                window.profitTrendChart = new ProfitTrendChart(dashboard);
            } else {
                setTimeout(initProfitChart, 100);
            }
        };
        initProfitChart();
    });
}

