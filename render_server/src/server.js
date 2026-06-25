// Mino Chat — WebRTC signaling server
// Made by Lost Weeds (Abhinit) · X Hub · MIT License
//
// Minimal WebSocket-based signaling that supports up to ~500 viewers per room.
// For full SFU transcoding, swap this for LiveKit / mediasoup — the Flutter
// client supports both via the same signaling shape.

import express from "express";
import cors from "cors";
import { WebSocketServer } from 'ws';
import { v4 as uuid } from 'uuid';
import http from 'node:http';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => res.json({ ok: true, ts: Date.now() }));
app.get('/', (_req, res) => res.json({
  name: 'Mino Chat Signaling',
  version: '0.1.0',
  author: 'Lost Weeds (Abhinit) · X Hub',
  rooms: rooms.size,
  connections: clients.size,
}));

const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

/** @type {Map<string, Set<string>>} roomId -> set of clientIds */
const rooms = new Map();
/** @type {Map<string, {ws: import('ws').WebSocket, roomId?: string, role?: string, userId?: string}>} */
const clients = new Map();

function broadcast(roomId, message, exceptClientId = null) {
  const members = rooms.get(roomId);
  if (!members) return;
  const payload = JSON.stringify(message);
  for (const clientId of members) {
    if (clientId === exceptClientId) continue;
    const client = clients.get(clientId);
    if (client && client.ws.readyState === client.ws.OPEN) {
      client.ws.send(payload);
    }
  }
}

wss.on('connection', (ws) => {
  const clientId = uuid();
  clients.set(clientId, { ws });

  ws.on('message', (raw) => {
    let msg;
    try { msg = JSON.parse(raw.toString()); } catch { return; }
    const client = clients.get(clientId);
    if (!client) return;

    switch (msg.type) {
      case 'join': {
        const { roomId, userId, role } = msg;
        client.roomId = roomId;
        client.userId = userId;
        client.role = role || 'audience';
        if (!rooms.has(roomId)) rooms.set(roomId, new Set());
        rooms.get(roomId).add(clientId);
        // Notify others
        broadcast(roomId, {
          type: 'peer-joined',
          clientId,
          userId,
          role: client.role,
        }, clientId);
        // Tell joiner how many peers exist
        ws.send(JSON.stringify({
          type: 'joined',
          roomId,
          peerCount: rooms.get(roomId).size - 1,
        }));
        break;
      }
      case 'leave': {
        leaveRoom(clientId);
        break;
      }
      case 'offer':
      case 'answer':
      case 'candidate': {
        if (!client.roomId) break;
        // Forward to target or broadcast
        if (msg.target) {
          const target = clients.get(msg.target);
          if (target && target.ws.readyState === target.ws.OPEN) {
            target.ws.send(JSON.stringify({ ...msg, from: clientId }));
          }
        } else {
          broadcast(client.roomId, { ...msg, from: clientId }, clientId);
        }
        break;
      }
      case 'raise-hand': {
        if (!client.roomId) break;
        broadcast(client.roomId, {
          type: 'hand-raised',
          clientId,
          userId: client.userId,
          raised: !!msg.raised,
        });
        break;
      }
      case 'speaker-change': {
        if (!client.roomId) break;
        broadcast(client.roomId, {
          type: 'speaker-change',
          clientId,
          userId: client.userId,
          speaking: !!msg.speaking,
        });
        break;
      }
      default:
        // Unknown — ignore
        break;
    }
  });

  ws.on('close', () => {
    leaveRoom(clientId);
    clients.delete(clientId);
  });

  ws.on('error', () => {
    leaveRoom(clientId);
    clients.delete(clientId);
  });
});

function leaveRoom(clientId) {
  const client = clients.get(clientId);
  if (!client || !client.roomId) return;
  const members = rooms.get(client.roomId);
  if (members) {
    members.delete(clientId);
    if (members.size === 0) rooms.delete(client.roomId);
    else broadcast(client.roomId, { type: 'peer-left', clientId, userId: client.userId });
  }
  client.roomId = undefined;
}

const PORT = process.env.PORT || 8080;
server.listen(PORT, () => {
  console.log(`[Mino Signaling] listening on :${PORT}`);
});
