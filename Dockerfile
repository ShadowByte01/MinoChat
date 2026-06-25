# Mino Chat — Render signaling server
# Dockerfile at repo root so Render can find it regardless of rootDir settings.
FROM node:20-slim

WORKDIR /app

# Copy only what the server needs
COPY render_server/package.json ./
RUN npm install --omit=dev

COPY render_server/src ./src

ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

CMD ["node", "src/server.js"]
