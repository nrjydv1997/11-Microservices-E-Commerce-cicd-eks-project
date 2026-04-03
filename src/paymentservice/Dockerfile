# Stage 2: Runtime
FROM node:20-alpine

RUN apk add --no-cache ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/server.js .
COPY --from=builder /build/charge.js .
COPY --from=builder /build/index.js .
COPY --from=builder /build/package.json .
COPY --from=builder /build/proto ./proto

RUN chown -R appuser:appgroup /app

USER appuser

ENV NODE_ENV=production

EXPOSE 50051

ENTRYPOINT ["node", "server.js"]