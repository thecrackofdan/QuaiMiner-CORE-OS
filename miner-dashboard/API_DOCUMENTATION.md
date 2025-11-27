# API Documentation

## Base URL
```
http://localhost:3000
```

## Authentication
Most endpoints are public. Some endpoints may require authentication in the future.

## Endpoints

### Health Check
```http
GET /api/health
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-26T12:00:00.000Z",
  "uptime": 12345.67
}
```

### Mining Statistics
```http
GET /api/stats
```

**Response:**
```json
{
  "hashRate": 10.5,
  "shares": {
    "accepted": 123,
    "rejected": 5
  },
  "earnings": 0.001234,
  "powerUsage": 150,
  "isMining": true,
  "gpus": [
    {
      "id": 0,
      "name": "AMD RX 590",
      "hashRate": 10.5,
      "temperature": 72,
      "fanSpeed": 65,
      "powerUsage": 150,
      "memoryTemp": 78
    }
  ],
  "network": {
    "nodeSynced": true,
    "currentChain": "Prime",
    "blockHeight": 1234567,
    "difficulty": 1234567890
  }
}
```

### GPU List
```http
GET /api/gpus
```

**Response:**
```json
{
  "gpus": [
    {
      "id": 0,
      "name": "AMD RX 590",
      "hashRate": 10.5,
      "temperature": 72,
      "fanSpeed": 65,
      "powerUsage": 150
    }
  ]
}
```

### Pool Configuration
```http
GET /api/pools
```

**Response:**
```json
{
  "success": true,
  "pools": [
    {
      "id": "solo",
      "name": "Solo Mining (Your Node)",
      "url": "stratum://localhost:3333",
      "host": "localhost",
      "port": 3333,
      "fee": 0,
      "feePercent": "0%",
      "mining": "Quai Network (All Chains)",
      "payout": "When block found",
      "minPayout": "Block reward",
      "uptime": "99.9%",
      "recommended": true,
      "description": "Mine directly to your own Quai node via stratum proxy. 100% of rewards, no fees.",
      "features": ["100% of rewards", "No fees", "Supports decentralization", "Full control", "Your own node"]
    }
  ],
  "message": "Solo mining configuration - connect to your own node"
}
```

### Node RPC Proxy
```http
POST /api/node/rpc
Content-Type: application/json

{
  "method": "eth_blockNumber",
  "params": []
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "result": "0x12d687",
  "id": 1
}
```

### Miner Logs
```http
GET /api/miner/logs?lines=100&gpu_index=0
```

**Response:**
```json
{
  "logs": [
    "2024-12-26 12:00:00 [INFO] Miner started",
    "2024-12-26 12:00:01 [INFO] GPU 0: Hash rate 10.5 MH/s"
  ],
  "total": 100
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request",
  "message": "Method is required and must be a string"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "message": "An error occurred"
}
```

## Rate Limiting

- API endpoints: 100 requests per 15 minutes per IP
- Auth endpoints: 5 requests per 15 minutes per IP
- Block endpoints: 10 requests per minute per IP

## Security

- All endpoints use Helmet.js security headers
- CORS is configured for production
- Input validation on all endpoints
- Sensitive data is masked in logs

