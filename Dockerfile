# ---------- Builder stage ----------
FROM node:18-alpine AS builder

WORKDIR /app

# Install build tools if needed (optional)
RUN apk add --no-cache bash curl tar

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDeps for TypeScript)
RUN npm ci

# Copy the rest of the source
COPY . .

# Build TypeScript
RUN npm run build

# Remove devDependencies to prepare for a clean production install
RUN npm prune --production


# ---------- Runtime stage ----------
FROM node:18-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup -g 1001 -S nodejs \
 && adduser -S -u 1001 -G nodejs nodejs

# Copy compiled app + production node_modules only
COPY --from=builder /app /app
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 5002

# Run the built JS file
CMD ["npm", "start"]
