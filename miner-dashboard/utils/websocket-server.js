/**
 * WebSocket Server for Real-Time Updates
 * Provides real-time data push instead of polling
 */

const http = require('http');

class WebSocketServer {
    constructor(expressApp) {
        this.server = http.createServer(expressApp);
        this.clients = new Set();
        this.broadcastInterval = null;
        this.init();
    }
    
    init() {
        // Upgrade HTTP connections to WebSocket
        this.server.on('upgrade', (request, socket, head) => {
            this.handleUpgrade(request, socket, head);
        });
    }
    
    handleUpgrade(request, socket, head) {
        // Simple WebSocket handshake (RFC 6455)
        const key = this.getWebSocketKey(request);
        if (!key) {
            socket.destroy();
            return;
        }
        
        const acceptKey = this.generateAcceptKey(key);
        const response = [
            'HTTP/1.1 101 Switching Protocols',
            'Upgrade: websocket',
            'Connection: Upgrade',
            `Sec-WebSocket-Accept: ${acceptKey}`,
            '',
            ''
        ].join('\r\n');
        
        socket.write(response);
        
        // Create client connection
        const client = {
            socket: socket,
            id: Date.now().toString(),
            send: (data) => this.sendToClient(client, data)
        };
        
        this.clients.add(client);
        
        // Handle client disconnect
        socket.on('close', () => {
            this.clients.delete(client);
        });
        
        socket.on('error', () => {
            this.clients.delete(client);
        });
        
        // Send welcome message
        this.sendToClient(client, JSON.stringify({
            type: 'connected',
            message: 'WebSocket connection established'
        }));
    }
    
    getWebSocketKey(request) {
        const headers = request.headers;
        return headers['sec-websocket-key'];
    }
    
    generateAcceptKey(key) {
        const crypto = require('crypto');
        const WS_MAGIC_STRING = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
        const hash = crypto.createHash('sha1').update(key + WS_MAGIC_STRING).digest('base64');
        return hash;
    }
    
    sendToClient(client, data) {
        try {
            const frame = this.createFrame(data);
            client.socket.write(frame);
        } catch (error) {
            // Client disconnected
            this.clients.delete(client);
        }
    }
    
    createFrame(data) {
        // Simple WebSocket frame (text frame, no masking for server)
        const payload = Buffer.from(data, 'utf8');
        const payloadLength = payload.length;
        
        let frame;
        if (payloadLength < 126) {
            frame = Buffer.allocUnsafe(2 + payloadLength);
            frame[0] = 0x81; // FIN + text frame
            frame[1] = payloadLength;
            payload.copy(frame, 2);
        } else if (payloadLength < 65536) {
            frame = Buffer.allocUnsafe(4 + payloadLength);
            frame[0] = 0x81;
            frame[1] = 126;
            frame.writeUInt16BE(payloadLength, 2);
            payload.copy(frame, 4);
        } else {
            frame = Buffer.allocUnsafe(10 + payloadLength);
            frame[0] = 0x81;
            frame[1] = 127;
            frame.writeUIntBE(payloadLength, 2, 6);
            payload.copy(frame, 8);
        }
        
        return frame;
    }
    
    broadcast(data) {
        const message = typeof data === 'string' ? data : JSON.stringify(data);
        this.clients.forEach(client => {
            this.sendToClient(client, message);
        });
    }
    
    startBroadcasting(getDataFn, interval = 5000) {
        if (this.broadcastInterval) {
            clearInterval(this.broadcastInterval);
        }
        
        this.broadcastInterval = setInterval(() => {
            if (this.clients.size > 0) {
                const data = getDataFn();
                this.broadcast({
                    type: 'update',
                    timestamp: Date.now(),
                    data: data
                });
            }
        }, interval);
    }
    
    stopBroadcasting() {
        if (this.broadcastInterval) {
            clearInterval(this.broadcastInterval);
            this.broadcastInterval = null;
        }
    }
    
    getServer() {
        return this.server;
    }
    
    getClientCount() {
        return this.clients.size;
    }
}

module.exports = WebSocketServer;

