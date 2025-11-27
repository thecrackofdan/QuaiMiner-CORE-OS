/**
 * ESLint Configuration
 * Strict rules for elite code quality
 */
module.exports = {
    env: {
        node: true,
        es2021: true,
        browser: true
    },
    extends: [
        'eslint:recommended'
    ],
    parserOptions: {
        ecmaVersion: 2021,
        sourceType: 'module'
    },
    rules: {
        // Error prevention
        'no-console': ['warn', { allow: ['warn', 'error'] }],
        'no-debugger': 'error',
        'no-alert': 'error',
        'no-var': 'error',
        'prefer-const': 'error',
        'no-unused-vars': ['warn', { 
            argsIgnorePattern: '^_',
            varsIgnorePattern: '^_'
        }],
        
        // Code quality
        'eqeqeq': ['error', 'always'],
        'curly': ['error', 'all'],
        'no-eval': 'error',
        'no-implied-eval': 'error',
        'no-new-func': 'error',
        'no-script-url': 'error',
        
        // Best practices
        'no-else-return': 'warn',
        'no-empty-function': 'warn',
        'no-magic-numbers': ['warn', { 
            ignore: [0, 1, -1, 2, 10, 100, 1000],
            ignoreArrayIndexes: true
        }],
        'prefer-arrow-callback': 'warn',
        'prefer-template': 'warn',
        
        // Security
        'no-new-require': 'error',
        'no-path-concat': 'error',
        
        // Style (will be handled by Prettier, but good to have)
        'semi': ['error', 'always'],
        'quotes': ['warn', 'single', { avoidEscape: true }],
        'comma-dangle': ['warn', 'never'],
        'indent': ['warn', 4, { SwitchCase: 1 }],
        'max-len': ['warn', { code: 120, ignoreUrls: true }]
    },
    globals: {
        // Browser globals
        'window': 'readonly',
        'document': 'readonly',
        'navigator': 'readonly',
        'fetch': 'readonly',
        'WebSocket': 'readonly',
        
        // Dashboard globals
        'CONFIG': 'readonly',
        'MiningDashboard': 'readonly',
        'ErrorHandler': 'readonly',
        'GPUTuner': 'readonly',
        'AutoSetup': 'readonly',
        'OneClickMining': 'readonly'
    },
    ignorePatterns: [
        'node_modules/',
        'public/lib/',
        '*.min.js',
        'coverage/',
        'dist/',
        'build/'
    ]
};

