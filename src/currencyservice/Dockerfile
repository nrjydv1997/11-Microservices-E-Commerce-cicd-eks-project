
############################
# Stage 1: Builder stage
############################
FROM node:20.8.0-alpine@sha256:37750e51d61bef92165b2e29a77da4277ba0777258446b7a9c99511f119db096 AS builder

# Create working directory
WORKDIR /build

# Copy dependency files first (cache optimization)
COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy source code
COPY . .

############################
# Stage 2: Runtime stage
############################
FROM node:20-alpine

# Install certificates (secure HTTPS communication)
RUN apk add --no-cache ca-certificates

# Create secure user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create app directory
WORKDIR /app

# Copy only necessary files
COPY --from=builder /build /app

# Change ownership
RUN chown -R appuser:appgroup /app

# Switch to secure user
USER appuser

# Expose service port
EXPOSE 7000

# Environment optimization
ENV NODE_ENV=production

# Run application
ENTRYPOINT ["node", "server.js"]
