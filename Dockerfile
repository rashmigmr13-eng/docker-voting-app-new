# Use the latest stable Node.js image (Debian Bookworm)
FROM node:20-slim

# Install system dependencies: curl (for healthchecks) and tini (for proper signal handling)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl tini \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy only package files first (to leverage Docker layer caching)
COPY package*.json ./

# Install dependencies (cleanly and safely)
RUN npm ci --omit=dev \
    && npm cache clean --force

# Copy the rest of the app
COPY . .

# Optional: install nodemon globally for local development
RUN npm install -g nodemon

# Set environment variable for the app port
ENV PORT=80

# Expose the port (so Docker knows which port to open)
EXPOSE 80

# Use tini as the init system (handles zombie processes & signals)
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start the Node.js server
CMD ["node", "server.js"]
