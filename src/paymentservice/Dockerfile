# Stage 1: Builder
FROM node:20-alpine AS builder

# Install build dependencies for native modules (pprof needs Python + g++)
RUN apk add --no-cache python3 make g++

WORKDIR /build

COPY package.json package-lock.json ./

RUN npm ci --omit=dev

COPY . .

# Stage 2: Runtime
FROM node:20-alpine

# Install security certificates
RUN apk add --no-cache ca-certificates

# Create secure user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build /app

RUN chown -R appuser:appgroup /app

USER appuser

ENV NODE_ENV=production

EXPOSE 50051

ENTRYPOINT ["node", "server.js"]