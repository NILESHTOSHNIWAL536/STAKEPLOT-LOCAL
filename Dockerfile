FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs \
 && adduser -S -u 1001 -G nodejs nodejs

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

RUN mkdir -p /app/output /app/logs \
 && chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 5001

CMD ["node", "src/index.js"]
