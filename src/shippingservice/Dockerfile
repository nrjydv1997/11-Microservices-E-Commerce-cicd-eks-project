# Stage 1: Builder
FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git

WORKDIR /build

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o shippingservice .

# Stage 2: Runtime
FROM alpine:3.19

# Fixed: ca-certificates (plural)
RUN apk add --no-cache ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build/shippingservice .

RUN chown appuser:appgroup /app/shippingservice

USER appuser

EXPOSE 50051

ENTRYPOINT ["./shippingservice"]