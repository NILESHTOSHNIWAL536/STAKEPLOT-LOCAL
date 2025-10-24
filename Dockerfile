# ---------- Builder stage ----------
FROM node:24-alpine AS builder
# If you need mongodb tools during build (e.g. for scripts run at build-time),
# they will be installed here and won't be copied into the final image.
RUN apk add --no-cache mongodb-tools bash curl tar
WORKDIR /app
# Copy package files first to leverage Docker layer cache
COPY package*.json ./
# Install production dependencies only (faster, smaller). If you need devDependencies
# for a build step (TypeScript, bundlers), change this to `npm ci` and run the build.
RUN npm ci --only=production
# Copy the rest of the application source
COPY . .
# If your app has a build step uncomment the following line and adjust the script name:
# RUN npm run build
# ---------- Final (runtime) stage ----------
FROM node:18-alpine AS runtime
WORKDIR /app
# Set NODE_ENV to production in the runtime image
ENV NODE_ENV=dev
# Copy app + production node_modules from the builder stage
COPY --from=builder /app /app
# Create a non-root user and take ownership of app files

USER node

EXPOSE 5000
# Keep the same command you were using. If you want to run the production start script,
# replace ["npm","run","dev"] with ["npm","run","start"] or ["node","dist/index.js"] as needed.
CMD ["npm", "run", "dev"]