/**
 * Jest Configuration
 * Test framework for elite code quality
 */
module.exports = {
    testEnvironment: 'node',
    coverageDirectory: 'coverage',
    collectCoverageFrom: [
        '**/*.js',
        '!**/node_modules/**',
        '!**/coverage/**',
        '!**/public/lib/**',
        '!**/*.min.js',
        '!**/tests/**',
        '!jest.config.js',
        '!server.js' // Will add server tests separately
    ],
    coverageThreshold: {
        global: {
            branches: 60,
            functions: 60,
            lines: 60,
            statements: 60
        }
    },
    testMatch: [
        '**/__tests__/**/*.js',
        '**/?(*.)+(spec|test).js'
    ],
    verbose: true,
    clearMocks: true,
    resetMocks: true,
    restoreMocks: true
};

