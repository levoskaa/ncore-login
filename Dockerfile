# Use an official Node.js runtime with a Debian base as a parent image
# for easier installation of Chromium dependencies.
FROM node:24-bullseye-slim

# Set Node.js environment to production, which can optimize some Node.js/Express behaviors
# and is good practice for production images.
ENV NODE_ENV=production
ENV PUPPETEER_SKIP_DOWNLOAD=true

# Install system dependencies required by Puppeteer to run Chromium.
# This list is based on Puppeteer's official troubleshooting guide (pptr.dev/troubleshooting).
# We use --no-install-recommends to keep the image size smaller.
# We clean up apt cache files afterwards to further reduce image size.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    wget \
    xdg-utils \
    chromium \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package*.json ./

# Install project dependencies using npm ci.
# `npm ci` provides faster, more reliable builds for CI/CD environments as it installs
# directly from package-lock.json and ensures a clean slate.
# --only=production ensures only runtime dependencies (not devDependencies) are installed.
RUN npm ci --only=production

# Copy the rest of the application's source code from the build context
# to the working directory in the container.
COPY . .

# Create a non-root user and group for security best practices.
# Running applications as a non-root user limits potential damage if a process is compromised.
RUN groupadd --system pptruser && \
    useradd --system --gid pptruser --create-home pptruser && \
    # Give the new user ownership of the app directory and its home directory
    chown -R pptruser:pptruser /usr/src/app /home/pptruser

# Switch to the non-root user for subsequent commands and for running the application.
USER pptruser

# NCORE_USERNAME and NCORE_PASSWORD must be passed as environment variables.
CMD ["node", "app.js"]
