/**
 * Client-Side Logger - Professional logging utility
 * Replaces console.log/debug/warn/error with structured logging
 */

class ClientLogger {
    constructor() {
        this.logLevel = this.getLogLevel();
        this.logHistory = [];
        this.maxHistory = 100;
        this.enableServerLogging = true;
    }

    getLogLevel() {
        // Check localStorage for log level preference
        const stored = localStorage.getItem('logLevel');
        if (stored) return stored;
        
        // Default based on environment
        return window.location.hostname === 'localhost' ? 'debug' : 'info';
    }

    /**
     * Log levels: debug < info < warn < error
     */
    shouldLog(level) {
        const levels = { debug: 0, info: 1, warn: 2, error: 3 };
        return levels[level] >= levels[this.logLevel];
    }

    formatMessage(level, message, data) {
        const timestamp = new Date().toISOString();
        const logEntry = {
            timestamp,
            level,
            message,
            data: data || null
        };
        
        this.logHistory.push(logEntry);
        if (this.logHistory.length > this.maxHistory) {
            this.logHistory.shift();
        }
        
        return logEntry;
    }

    debug(message, data = null) {
        if (!this.shouldLog('debug')) return;
        const entry = this.formatMessage('debug', message, data);
        console.debug(`[DEBUG] ${message}`, data || '');
        this.sendToServer(entry);
    }

    info(message, data = null) {
        if (!this.shouldLog('info')) return;
        const entry = this.formatMessage('info', message, data);
        console.info(`[INFO] ${message}`, data || '');
        this.sendToServer(entry);
    }

    warn(message, data = null) {
        if (!this.shouldLog('warn')) return;
        const entry = this.formatMessage('warn', message, data);
        console.warn(`[WARN] ${message}`, data || '');
        this.sendToServer(entry);
    }

    error(message, error = null) {
        if (!this.shouldLog('error')) return;
        const entry = this.formatMessage('error', message, {
            error: error?.message || error,
            stack: error?.stack || null
        });
        console.error(`[ERROR] ${message}`, error || '');
        this.sendToServer(entry);
    }

    async sendToServer(entry) {
        if (!this.enableServerLogging) return;
        
        try {
            // Send to server asynchronously (don't block)
            fetch('/api/logs', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(entry),
                keepalive: true // Allow request to complete even if page unloads
            }).catch(() => {
                // Silently fail - don't spam if server is down
            });
        } catch (e) {
            // Ignore errors
        }
    }

    getHistory(level = null) {
        if (level) {
            return this.logHistory.filter(entry => entry.level === level);
        }
        return [...this.logHistory];
    }

    clearHistory() {
        this.logHistory = [];
    }

    setLogLevel(level) {
        this.logLevel = level;
        localStorage.setItem('logLevel', level);
    }
}

// Create global logger instance
if (typeof window !== 'undefined') {
    window.logger = new ClientLogger();
    
    // Replace console methods with logger (optional, can be disabled)
    if (localStorage.getItem('replaceConsole') === 'true') {
        window.console.log = (...args) => window.logger.info(args.join(' '));
        window.console.debug = (...args) => window.logger.debug(args.join(' '));
        window.console.warn = (...args) => window.logger.warn(args.join(' '));
        window.console.error = (...args) => window.logger.error(args.join(' '));
    }
}

