# ---------- Builder stage ----------
FROM node:24 AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl tar && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
# ---------- Final (runtime) stage ----------
FROM node:18
WORKDIR /app
ENV NODE_ENV=dev
ENV SPACY_HOME=/app/spacy_models

# Install Python 3, pip, and dependencies for spacy
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-full python3-pip && rm -rf /var/lib/apt/lists/*

# Remove PEP 668 externally-managed-environment marker to allow pip installs in container
RUN rm /usr/lib/python3.*/EXTERNALLY-MANAGED

# Install spacy and download model
RUN pip install --no-cache-dir spacy && \
    python3 -m spacy download en_core_web_sm

COPY --from=builder /app /app

# Create writable logs and output directories, and spacy models directory for the non-root user
RUN mkdir -p /app/logs /app/output /app/spacy_models && \
    chown -R node:node /app/logs /app/output /app/spacy_models && \
    chmod +x /app/scrapemail.py

# Ensure python3 is accessible
RUN ln -sf /usr/bin/python3 /usr/local/bin/python3

USER node
EXPOSE 5001
CMD ["npm", "run", "dev"]
