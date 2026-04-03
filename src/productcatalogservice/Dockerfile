# Stage 1: Builder
FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git

WORKDIR /build

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -gcflags="${SKAFFOLD_GO_GCFLAGS}" -o /build/productcatalogservice .

# Stage 2: Runtime
FROM alpine:3.19

RUN apk add --no-cache ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build/productcatalogservice .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3550

ENTRYPOINT ["./productcatalogservice"]