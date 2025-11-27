/**
 * Winston Structured Logger
 * Professional logging with multiple transports
 */
const winston = require('winston');
const path = require('path');
const fs = require('fs');

const NODE_ENV = process.env.NODE_ENV || 'production';
const LOG_DIR = path.join(__dirname, '../../logs');

// Create logs directory if it doesn't exist
if (!fs.existsSync(LOG_DIR)) {
    fs.mkdirSync(LOG_DIR, { recursive: true });
}

// Custom format for structured logging
const logFormat = winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.splat(),
    winston.format.json()
);

// Console format for development
const consoleFormat = winston.format.combine(
    winston.format.colorize(),
    winston.format.timestamp({ format: 'HH:mm:ss' }),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
        let msg = `${timestamp} [${level}]: ${message}`;
        if (Object.keys(meta).length > 0) {
            msg += ` ${JSON.stringify(meta)}`;
        }
        return msg;
    })
);

// Create logger instance
const logger = winston.createLogger({
    level: process.env.LOG_LEVEL || (NODE_ENV === 'development' ? 'debug' : 'info'),
    format: logFormat,
    defaultMeta: { service: 'quai-miner-dashboard' },
    transports: [
        // Write all logs to combined.log
        new winston.transports.File({
            filename: path.join(LOG_DIR, 'combined.log'),
            maxsize: 10485760, // 10MB
            maxFiles: 5
        }),
        // Write errors to error.log
        new winston.transports.File({
            filename: path.join(LOG_DIR, 'error.log'),
            level: 'error',
            maxsize: 10485760, // 10MB
            maxFiles: 5
        })
    ],
    // Handle exceptions and rejections
    exceptionHandlers: [
        new winston.transports.File({
            filename: path.join(LOG_DIR, 'exceptions.log')
        })
    ],
    rejectionHandlers: [
        new winston.transports.File({
            filename: path.join(LOG_DIR, 'rejections.log')
        })
    ]
});

// Add console transport for development
if (NODE_ENV !== 'production') {
    logger.add(new winston.transports.Console({
        format: consoleFormat
    }));
}

// Sanitize sensitive data before logging
const { sanitizeLogData } = require('../middleware/security');
const { maskWalletAddress } = require('../middleware/privacy');

// Wrap logger methods to sanitize data
const originalLog = logger.log.bind(logger);
logger.log = function(level, message, meta = {}) {
    if (meta && typeof meta === 'object') {
        meta = sanitizeLogData(meta);
        // Mask wallet addresses in message
        if (typeof message === 'string') {
            const walletPattern = /0x[a-fA-F0-9]{40}/g;
            message = message.replace(walletPattern, (match) => maskWalletAddress(match));
        }
    }
    return originalLog(level, message, meta);
};

// Convenience methods
logger.info = (message, meta) => logger.log('info', message, meta);
logger.error = (message, meta) => logger.log('error', message, meta);
logger.warn = (message, meta) => logger.log('warn', message, meta);
logger.debug = (message, meta) => logger.log('debug', message, meta);
logger.verbose = (message, meta) => logger.log('verbose', message, meta);

module.exports = logger;

