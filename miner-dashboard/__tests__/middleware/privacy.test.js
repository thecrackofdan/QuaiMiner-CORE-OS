/**
 * Privacy Middleware Unit Tests
 */
const {
    sanitizeResponse,
    privacyLog,
    maskWalletAddress,
    containsSensitiveData,
    privacyHeaders
} = require('../../middleware/privacy');

describe('Privacy Middleware', () => {
    describe('sanitizeResponse', () => {
        test('should remove sensitive fields', () => {
            const data = {
                username: 'test',
                password: 'secret123',
                apiKey: 'key123',
                token: 'token123',
                publicData: 'safe'
            };

            const sanitized = sanitizeResponse(data);

            expect(sanitized.password).toBeUndefined();
            expect(sanitized.apiKey).toBeUndefined();
            expect(sanitized.token).toBeUndefined();
            expect(sanitized.username).toBe('test');
            expect(sanitized.publicData).toBe('safe');
        });

        test('should sanitize nested objects', () => {
            const data = {
                user: {
                    name: 'test',
                    password: 'secret',
                    settings: {
                        theme: 'dark',
                        apiKey: 'key123'
                    }
                }
            };

            const sanitized = sanitizeResponse(data);

            expect(sanitized.user.password).toBeUndefined();
            expect(sanitized.user.settings.apiKey).toBeUndefined();
            expect(sanitized.user.name).toBe('test');
            expect(sanitized.user.settings.theme).toBe('dark');
        });

        test('should handle null/undefined', () => {
            expect(sanitizeResponse(null)).toBe(null);
            expect(sanitizeResponse(undefined)).toBe(undefined);
        });

        test('should handle non-object input', () => {
            expect(sanitizeResponse('string')).toBe('string');
            expect(sanitizeResponse(123)).toBe(123);
        });
    });

    describe('maskWalletAddress', () => {
        test('should mask wallet address correctly', () => {
            const address = '0x00215254D1dDdd5D90671bA981688197A2735c1f';
            const masked = maskWalletAddress(address);

            expect(masked).toBe('0x0021...5c1f');
            expect(masked).not.toBe(address);
            expect(masked.length).toBeLessThan(address.length);
        });

        test('should handle invalid input', () => {
            expect(maskWalletAddress(null)).toBe('***');
            expect(maskWalletAddress(undefined)).toBe('***');
            expect(maskWalletAddress('0x123')).toBe('***');
            expect(maskWalletAddress('')).toBe('***');
        });
    });

    describe('containsSensitiveData', () => {
        test('should detect sensitive data', () => {
            const sensitive = {
                password: 'secret',
                wallet: '0x00215254D1dDdd5D90671bA981688197A2735c1f'
            };

            expect(containsSensitiveData(sensitive)).toBe(true);
        });

        test('should not flag safe data', () => {
            const safe = {
                username: 'test',
                publicData: 'safe'
            };

            expect(containsSensitiveData(safe)).toBe(false);
        });

        test('should handle null/undefined', () => {
            expect(containsSensitiveData(null)).toBe(false);
            expect(containsSensitiveData(undefined)).toBe(false);
        });
    });

    describe('privacyHeaders', () => {
        test('should set privacy headers', () => {
            const req = {};
            const res = {
                setHeader: jest.fn()
            };
            const next = jest.fn();

            privacyHeaders(req, res, next);

            expect(res.setHeader).toHaveBeenCalledWith('X-Privacy-Policy', 'No data collection, no tracking');
            expect(res.setHeader).toHaveBeenCalledWith('X-Data-Retention', 'Local only');
            expect(next).toHaveBeenCalled();
        });
    });

    describe('privacyLog', () => {
        test('should log with sanitized data', () => {
            const originalLog = console.log;
            console.log = jest.fn();

            const data = {
                username: 'test',
                password: 'secret'
            };

            privacyLog('Test message', data);

            expect(console.log).toHaveBeenCalled();
            const callArgs = console.log.mock.calls[0];
            expect(callArgs[1].password).toBeUndefined();

            console.log = originalLog;
        });
    });
});

