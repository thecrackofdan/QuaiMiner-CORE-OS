/**
 * Security Implementation Tests
 * Tests actual security and privacy implementations, not just file existence
 */

const { maskWalletAddress, sanitizeResponse, containsSensitiveData } = require('../middleware/privacy');
const { sanitizeLogData, preventDirectoryTraversal, sanitizeFilePath } = require('../middleware/security');

// Try to load input validation, but handle missing validator module gracefully
let validateWalletAddress, sanitizeString, validateUrl, sanitizeObject;
try {
    const inputValidation = require('../middleware/inputValidation');
    validateWalletAddress = inputValidation.validateWalletAddress;
    sanitizeString = inputValidation.sanitizeString;
    validateUrl = inputValidation.validateUrl;
    sanitizeObject = inputValidation.sanitizeObject;
} catch (error) {
    console.warn('⚠️  Input validation module not available (missing validator dependency)');
    console.warn('   Some tests will be skipped. Install validator: npm install validator');
}

const tests = {
    passed: 0,
    failed: 0,
    errors: []
};

function test(name, fn) {
    try {
        fn();
        tests.passed++;
        console.log(`✅ ${name}`);
    } catch (error) {
        tests.failed++;
        tests.errors.push({ name, error: error.message });
        console.error(`❌ ${name}: ${error.message}`);
    }
}

console.log('🔒 Running Security Implementation Tests...\n');

// ============================================
// PRIVACY TESTS
// ============================================

console.log('🔐 Privacy Implementation Tests:\n');

// Test 1: Wallet address masking
test('Wallet address masking works correctly', () => {
    const address = '0x00215254D1dDdd5D90671bA981688197A2735c1f';
    const masked = maskWalletAddress(address);
    
    if (masked === address) {
        throw new Error('Address was not masked');
    }
    if (!masked.includes('...')) {
        throw new Error('Masked address should contain ...');
    }
    if (masked.length >= address.length) {
        throw new Error('Masked address should be shorter than original');
    }
    // Should show first 6 and last 4 chars (0x + 4 chars = 6 total, then last 4)
    // Format: 0x0021...35c1f
    if (!masked.startsWith('0x0021') || !masked.endsWith('c1f')) {
        throw new Error(`Masking format incorrect. Got: ${masked}, Expected format: 0x0021...c1f`);
    }
});

// Test 2: Masking handles invalid input
test('Wallet address masking handles invalid input', () => {
    const invalid = maskWalletAddress(null);
    if (invalid !== '***') {
        throw new Error('Should return *** for null input');
    }
    
    const short = maskWalletAddress('0x123');
    if (short !== '***') {
        throw new Error('Should return *** for short address');
    }
});

// Test 3: Response sanitization removes sensitive data
test('Response sanitization removes sensitive fields', () => {
    const data = {
        username: 'test',
        password: 'secret123',
        apiKey: 'key123',
        token: 'token123',
        publicData: 'safe'
    };
    
    const sanitized = sanitizeResponse(data);
    
    if (sanitized.password) {
        throw new Error('Password should be removed');
    }
    if (sanitized.apiKey) {
        throw new Error('API key should be removed');
    }
    if (sanitized.token) {
        throw new Error('Token should be removed');
    }
    if (sanitized.username !== 'test') {
        throw new Error('Non-sensitive data should remain');
    }
    if (sanitized.publicData !== 'safe') {
        throw new Error('Public data should remain');
    }
});

// Test 4: Response sanitization handles nested objects
test('Response sanitization handles nested objects', () => {
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
    
    if (sanitized.user.password) {
        throw new Error('Nested password should be removed');
    }
    if (sanitized.user.settings.apiKey) {
        throw new Error('Deeply nested API key should be removed');
    }
    if (sanitized.user.name !== 'test') {
        throw new Error('Nested non-sensitive data should remain');
    }
});

// Test 5: Sensitive data detection
test('Sensitive data detection works', () => {
    const sensitive = {
        password: 'secret',
        wallet: '0x00215254D1dDdd5D90671bA981688197A2735c1f'
    };
    
    if (!containsSensitiveData(sensitive)) {
        throw new Error('Should detect sensitive data');
    }
    
    const safe = {
        username: 'test',
        publicData: 'safe'
    };
    
    if (containsSensitiveData(safe)) {
        throw new Error('Should not flag safe data as sensitive');
    }
});

// ============================================
// SECURITY TESTS
// ============================================

console.log('\n🛡️  Security Implementation Tests:\n');

// Test 6: Log data sanitization
test('Log data sanitization redacts sensitive fields', () => {
    const logData = {
        username: 'test',
        password: 'secret123',
        wallet: '0x00215254D1dDdd5D90671bA981688197A2735c1f',
        apiKey: 'key123'
    };
    
    const sanitized = sanitizeLogData(logData);
    
    if (sanitized.password !== '***REDACTED***') {
        throw new Error('Password should be redacted');
    }
    if (sanitized.wallet !== '***REDACTED***') {
        throw new Error('Wallet should be redacted');
    }
    if (sanitized.apiKey !== '***REDACTED***') {
        throw new Error('API key should be redacted');
    }
    if (sanitized.username !== 'test') {
        throw new Error('Non-sensitive data should remain');
    }
});

// Test 7: Directory traversal prevention
test('Directory traversal prevention blocks .. patterns', () => {
    if (preventDirectoryTraversal('../etc/passwd')) {
        throw new Error('Should block directory traversal with ..');
    }
    if (preventDirectoryTraversal('../../etc/passwd')) {
        throw new Error('Should block multiple .. patterns');
    }
    if (preventDirectoryTraversal('/etc/passwd')) {
        throw new Error('Should block absolute paths');
    }
    if (!preventDirectoryTraversal('safe-file.txt')) {
        throw new Error('Should allow safe file names');
    }
});

// Test 8: File path sanitization
test('File path sanitization removes dangerous patterns', () => {
    const dangerous = '../etc/passwd';
    const sanitized = sanitizeFilePath(dangerous);
    
    if (sanitized && sanitized.includes('..')) {
        throw new Error('Should remove .. patterns');
    }
    
    const safe = 'reports/mining-stats.csv';
    const safeSanitized = sanitizeFilePath(safe);
    
    if (safeSanitized !== safe) {
        throw new Error('Should preserve safe paths');
    }
});

// ============================================
// INPUT VALIDATION TESTS
// ============================================

console.log('\n✅ Input Validation Tests:\n');

// Test 9: Wallet address validation (if available)
if (validateWalletAddress) {
    test('Wallet address validation accepts valid addresses', () => {
        const valid = '0x00215254D1dDdd5D90671bA981688197A2735c1f';
        
        if (!validateWalletAddress(valid)) {
            throw new Error('Should accept valid wallet address');
        }
    });

    test('Wallet address validation rejects invalid addresses', () => {
        const invalid = [
            '0x123', // Too short
            '00215254D1dDdd5D90671bA981688197A2735c1f', // Missing 0x
            '0x00215254D1dDdd5D90671bA981688197A2735c1f123', // Too long
            '0x00215254D1dDdd5D90671bA981688197A2735c1g', // Invalid character
            null,
            undefined,
            ''
        ];
        
        for (const addr of invalid) {
            if (validateWalletAddress(addr)) {
                throw new Error(`Should reject invalid address: ${addr}`);
            }
        }
    });
} else {
    console.log('⏭️  Skipping wallet address validation tests (module not available)');
}

// Test 10: String sanitization (if available)
if (sanitizeString) {
    test('String sanitization removes null bytes and limits length', () => {
        const withNull = 'test\0string';
        const sanitized = sanitizeString(withNull);
        
        if (sanitized.includes('\0')) {
            throw new Error('Should remove null bytes');
        }
        
        const long = 'a'.repeat(2000);
        const limited = sanitizeString(long, 100);
        
        if (limited.length > 100) {
            throw new Error('Should limit string length');
        }
    });
} else {
    console.log('⏭️  Skipping string sanitization tests (module not available)');
}

// Test 11: URL validation (if available)
if (validateUrl) {
    test('URL validation accepts valid URLs', () => {
        const valid = [
            'http://localhost:8545',
            'https://example.com',
            'stratum://localhost:3333',
            'stratum+tcp://pool.example.com:3333'
        ];
        
        for (const url of valid) {
            if (!validateUrl(url)) {
                throw new Error(`Should accept valid URL: ${url}`);
            }
        }
    });

    test('URL validation rejects invalid URLs', () => {
        const invalid = [
            'not-a-url',
            'ftp://example.com', // Wrong protocol
            'javascript:alert(1)', // Dangerous protocol
            '',
            null
        ];
        
        for (const url of invalid) {
            if (validateUrl(url)) {
                throw new Error(`Should reject invalid URL: ${url}`);
            }
        }
    });
} else {
    console.log('⏭️  Skipping URL validation tests (module not available)');
}

// Test 12: Object sanitization (if available)
if (sanitizeObject) {
    test('Object sanitization sanitizes nested structures', () => {
        const obj = {
            name: 'test\0name',
            nested: {
                value: 'safe',
                dangerous: '../path'
            },
            array: ['item1', 'item\02']
        };
        
        const sanitized = sanitizeObject(obj);
        
        if (sanitized.name.includes('\0')) {
            throw new Error('Should sanitize string values');
        }
        if (sanitized.array[1].includes('\0')) {
            throw new Error('Should sanitize array values');
        }
        if (sanitized.nested.value !== 'safe') {
            throw new Error('Should preserve safe values');
        }
    });
} else {
    console.log('⏭️  Skipping object sanitization tests (module not available)');
}

// ============================================
// SUMMARY
// ============================================

console.log('\n📊 Test Results:');
console.log(`✅ Passed: ${tests.passed}`);
console.log(`❌ Failed: ${tests.failed}`);

if (tests.errors.length > 0) {
    console.log(`\n❌ Errors:`);
    tests.errors.forEach(({ name, error }) => {
        console.log(`  - ${name}: ${error}`);
    });
}

const totalTests = tests.passed + tests.failed;
const passRate = totalTests > 0 ? ((tests.passed / totalTests) * 100).toFixed(1) : 0;

console.log(`\n📈 Pass Rate: ${passRate}%`);

if (tests.failed === 0) {
    console.log('\n✅ All security implementation tests passed!');
    process.exit(0);
} else {
    console.log(`\n⚠️  ${tests.failed} test(s) failed. Please review.`);
    process.exit(1);
}

