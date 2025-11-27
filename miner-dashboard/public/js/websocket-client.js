/**
 * WebSocket Client for Real-Time Updates
 * Connects to server WebSocket for live data updates
 */

class WebSocketClient {
    constructor(dashboard) {
        this.dashboard = dashboard;
        this.ws = null;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 10;
        this.reconnectDelay = 1000;
        this.isConnected = false;
        this.init();
    }
    
    init() {
        this.connect();
    }
    
    connect() {
        // Determine WebSocket URL
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const host = window.location.host;
        const wsUrl = `${protocol}//${host}`;
        
        try {
            this.ws = new WebSocket(wsUrl);
            
            this.ws.onopen = () => {
                this.isConnected = true;
                this.reconnectAttempts = 0;
                console.log('WebSocket connected');
                
                if (typeof showToast === 'function') {
                    showToast('Real-time updates enabled', 'success');
                }
            };
            
            this.ws.onmessage = (event) => {
                try {
                    const message = JSON.parse(event.data);
                    this.handleMessage(message);
                } catch (error) {
                    console.warn('Failed to parse WebSocket message:', error);
                }
            };
            
            this.ws.onerror = (error) => {
                console.warn('WebSocket error:', error);
            };
            
            this.ws.onclose = () => {
                this.isConnected = false;
                console.log('WebSocket disconnected');
                this.attemptReconnect();
            };
        } catch (error) {
            console.warn('WebSocket not available, falling back to polling:', error);
            this.fallbackToPolling();
        }
    }
    
    handleMessage(message) {
        if (message.type === 'connected') {
            console.log('WebSocket:', message.message);
        } else if (message.type === 'update' && message.data) {
            // Update dashboard with real-time data
            this.updateDashboard(message.data);
        }
    }
    
    updateDashboard(data) {
        if (!this.dashboard) return;
        
        // Update mining data if available
        if (data.miningData) {
            Object.assign(this.dashboard.miningData, data.miningData);
            this.dashboard.updateUI();
        }
        
        // Update profit if available
        if (data.profit !== undefined) {
            const profitEl = document.getElementById('dailyProfit');
            if (profitEl) {
                profitEl.textContent = `$${data.profit.toFixed(2)}`;
            }
        }
        
        // Update hash rate if available
        if (data.hashRate !== undefined) {
            const hashRateEl = document.getElementById('hashRate');
            if (hashRateEl) {
                hashRateEl.textContent = data.hashRate.toFixed(2);
            }
        }
    }
    
    attemptReconnect() {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            console.warn('Max reconnection attempts reached, falling back to polling');
            this.fallbackToPolling();
            return;
        }
        
        this.reconnectAttempts++;
        const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1); // Exponential backoff
        
        setTimeout(() => {
            console.log(`Attempting to reconnect (${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);
            this.connect();
        }, delay);
    }
    
    fallbackToPolling() {
        // WebSocket not available, dashboard will use regular polling
        console.log('Using polling mode for updates');
    }
    
    disconnect() {
        if (this.ws) {
            this.ws.close();
            this.ws = null;
        }
    }
    
    send(data) {
        if (this.ws && this.isConnected) {
            this.ws.send(JSON.stringify(data));
        }
    }
}

// Auto-initialize when dashboard is ready
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        // Wait for dashboard to be initialized
        const initWebSocket = () => {
            if (typeof dashboard !== 'undefined' && dashboard) {
                window.wsClient = new WebSocketClient(dashboard);
            } else {
                setTimeout(initWebSocket, 100);
            }
        };
        initWebSocket();
    });
}

