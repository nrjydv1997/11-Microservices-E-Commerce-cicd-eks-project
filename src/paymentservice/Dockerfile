# Stage 1: Builder
FROM node:20-alpine AS builder

# Create working directory 
WORKDIR /build

# Copy dependency file 
COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm ci --omit=dev

COPY . .

# Stage 2: Runtime
FROM node:20-alpine

# Install security certificates
RUN apk add --no-cache ca-certificates

# Create secure user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create application directory
WORKDIR /app

# Copy builder application from builder stage
COPY --from=builder /build /app

# Change ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set environment
ENV NODE_ENV=production

# Expose service port
EXPOSE 50051

# Start payment service
ENTRYPOINT ["node", "server.js"]