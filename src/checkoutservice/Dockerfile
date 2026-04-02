############################
# Stage 1: Builder stage
############################
FROM node:20.8.0-alpine@sha256:37750e51d61bef92165b2e29a77da4277ba0777258446b7a9c99511f119db096 AS builder

WORKDIR /build

COPY package.json package-lock.json ./

# ✅ FIX: Install build tools needed by node-gyp to compile pprof from source
# pprof@3.2.1 has no pre-built binary for node-v115-linux-x64-musl (Node 20 + Alpine)
# so it must compile from source, which requires python3 + make + g++
RUN apk add --no-cache python3 make g++

RUN npm ci --omit=dev

COPY . .

############################
# Stage 2: Runtime stage
############################
FROM node:20-alpine

RUN apk add --no-cache ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build /app

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 7000

ENV NODE_ENV=production

ENTRYPOINT ["node", "server.js"]
