/**
 * Security Middleware Unit Tests
 */
const {
    sanitizeLogData,
    securityHeaders,
    secureRequestLogger,
    validateOrigin,
    preventDirectoryTraversal,
    sanitizeFilePath
} = require('../../middleware/security');

describe('Security Middleware', () => {
    describe('sanitizeLogData', () => {
        test('should redact sensitive fields', () => {
            const data = {
                username: 'test',
                password: 'secret123',
                apiKey: 'key123',
                token: 'token123',
                wallet: '0x00215254D1dDdd5D90671bA981688197A2735c1f'
            };

            const sanitized = sanitizeLogData(data);

            expect(sanitized.password).toBe('***REDACTED***');
            expect(sanitized.apiKey).toBe('***REDACTED***');
            expect(sanitized.token).toBe('***REDACTED***');
            expect(sanitized.wallet).toBe('***REDACTED***');
            expect(sanitized.username).toBe('test');
        });

        test('should handle null/undefined input', () => {
            expect(sanitizeLogData(null)).toBe(null);
            expect(sanitizeLogData(undefined)).toBe(undefined);
        });

        test('should handle non-object input', () => {
            expect(sanitizeLogData('string')).toBe('string');
            expect(sanitizeLogData(123)).toBe(123);
        });
    });

    describe('securityHeaders', () => {
        test('should set security headers', () => {
            const req = {};
            const res = {
                setHeader: jest.fn()
            };
            const next = jest.fn();

            securityHeaders(req, res, next);

            expect(res.setHeader).toHaveBeenCalledWith('X-Content-Type-Options', 'nosniff');
            expect(res.setHeader).toHaveBeenCalledWith('X-Frame-Options', 'DENY');
            expect(res.setHeader).toHaveBeenCalledWith('X-XSS-Protection', '1; mode=block');
            expect(next).toHaveBeenCalled();
        });
    });

    describe('secureRequestLogger', () => {
        test('should log non-sensitive endpoints', () => {
            const originalLog = console.log;
            console.log = jest.fn();

            const req = {
                method: 'GET',
                path: '/api/stats',
                ip: '127.0.0.1',
                get: jest.fn().mockReturnValue('test-agent')
            };
            const res = {};
            const next = jest.fn();

            secureRequestLogger(req, res, next);

            expect(console.log).toHaveBeenCalled();
            expect(next).toHaveBeenCalled();

            console.log = originalLog;
        });

        test('should not log sensitive endpoints', () => {
            const originalLog = console.log;
            console.log = jest.fn();

            const req = {
                method: 'POST',
                path: '/api/auth/login',
                ip: '127.0.0.1',
                get: jest.fn().mockReturnValue('test-agent')
            };
            const res = {};
            const next = jest.fn();

            secureRequestLogger(req, res, next);

            expect(console.log).not.toHaveBeenCalled();
            expect(next).toHaveBeenCalled();

            console.log = originalLog;
        });
    });

    describe('validateOrigin', () => {
        test('should allow requests in development', () => {
            const originalEnv = process.env.NODE_ENV;
            process.env.NODE_ENV = 'development';

            const req = {
                get: jest.fn().mockReturnValue('http://localhost:3000')
            };
            const res = {};
            const next = jest.fn();

            validateOrigin(req, res, next);

            expect(next).toHaveBeenCalled();

            process.env.NODE_ENV = originalEnv;
        });

        test('should validate origin in production', () => {
            const originalEnv = process.env.NODE_ENV;
            process.env.NODE_ENV = 'production';
            process.env.ALLOWED_ORIGINS = 'https://example.com';

            const req = {
                get: jest.fn().mockReturnValue('https://example.com')
            };
            const res = {
                status: jest.fn().mockReturnThis(),
                json: jest.fn()
            };
            const next = jest.fn();

            validateOrigin(req, res, next);

            expect(next).toHaveBeenCalled();

            process.env.NODE_ENV = originalEnv;
            delete process.env.ALLOWED_ORIGINS;
        });
    });

    describe('preventDirectoryTraversal', () => {
        test('should block directory traversal patterns', () => {
            expect(preventDirectoryTraversal('../etc/passwd')).toBe(false);
            expect(preventDirectoryTraversal('../../etc/passwd')).toBe(false);
            expect(preventDirectoryTraversal('/etc/passwd')).toBe(false);
            expect(preventDirectoryTraversal('path//to/file')).toBe(false);
        });

        test('should allow safe paths', () => {
            expect(preventDirectoryTraversal('safe-file.txt')).toBe(true);
            expect(preventDirectoryTraversal('reports/mining-stats.csv')).toBe(true);
        });

        test('should handle invalid input', () => {
            expect(preventDirectoryTraversal(null)).toBe(false);
            expect(preventDirectoryTraversal(undefined)).toBe(false);
            expect(preventDirectoryTraversal(123)).toBe(false);
        });
    });

    describe('sanitizeFilePath', () => {
        test('should remove directory traversal patterns', () => {
            const result = sanitizeFilePath('../etc/passwd');
            expect(result).not.toContain('..');
        });

        test('should remove leading slashes', () => {
            const result = sanitizeFilePath('/etc/passwd');
            expect(result).not.toStartWith('/');
        });

        test('should allow safe paths', () => {
            const safe = 'reports/mining-stats.csv';
            expect(sanitizeFilePath(safe)).toBe(safe);
        });

        test('should return null for invalid paths', () => {
            expect(sanitizeFilePath(null)).toBe(null);
            expect(sanitizeFilePath(undefined)).toBe(null);
            expect(sanitizeFilePath('path/with/../invalid')).toBe(null);
        });
    });
});

