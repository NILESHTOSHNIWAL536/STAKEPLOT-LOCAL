# ---------- Builder stage ----------
FROM node:24-alpine AS builder
RUN apk add --no-cache mongodb-tools bash curl tar
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
# ---------- Final (runtime) stage ----------
FROM node:18-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=dev
COPY --from=builder /app /app

# Create writable logs directory for the non-root user
RUN mkdir -p /app/logs && chown -R node:node /app/logs

USER node
EXPOSE 5001
CMD ["npm", "run", "dev"]
