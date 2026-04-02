############################
# Stage 1: Build Stage
############################
FROM node:20.8.0-alpine AS builder

# ✅ Install Python + build tools needed by node-gyp to compile pprof from source
RUN apk add --no-cache python3 make g++ 

WORKDIR /build

COPY package.json package-lock.json ./

RUN npm ci --omit=dev

# Copy source code
COPY . .

############################
# Stage 2: Runtime Stage
############################
FROM node:20.8.0-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build .

USER appuser

EXPOSE 8080

ENTRYPOINT ["node", "server.js"]