/**
 * API Health Endpoint Integration Tests
 */
const request = require('supertest');

// Mock the server for testing
let app;
beforeAll(() => {
    // Set test environment
    process.env.NODE_ENV = 'test';
    
    // Create minimal Express app for testing
    const express = require('express');
    app = express();
    app.use(express.json());
    
    // Health endpoint
    app.get('/api/health', (req, res) => {
        res.json({
            status: 'ok',
            timestamp: new Date().toISOString(),
            uptime: process.uptime()
        });
    });
});

describe('API Health Endpoint', () => {
    test('GET /api/health should return 200', async () => {
        const response = await request(app)
            .get('/api/health')
            .expect(200);

        expect(response.body).toHaveProperty('status');
        expect(response.body.status).toBe('ok');
        expect(response.body).toHaveProperty('timestamp');
        expect(response.body).toHaveProperty('uptime');
    });

    test('should return valid timestamp', async () => {
        const response = await request(app)
            .get('/api/health')
            .expect(200);

        const timestamp = new Date(response.body.timestamp);
        expect(timestamp.getTime()).toBeGreaterThan(0);
    });

    test('should return uptime as number', async () => {
        const response = await request(app)
            .get('/api/health')
            .expect(200);

        expect(typeof response.body.uptime).toBe('number');
        expect(response.body.uptime).toBeGreaterThanOrEqual(0);
    });
});

