# Stage 1: Builder stage
FROM golang:1.21.3-alpine@sha256:926f7f7e1ab8509b4e91d5ec6d5916ebb45155b0c8920291ba9f361d65385806 AS builder


# Install git (required for downloading dependencies)
RUN apk add --no-cache git


# Create working directory
WORKDIR /build


# Copy dependency files first (for caching)
COPY go.mod go.sum ./


# Download dependencies
RUN go mod download


# Copy source code
COPY . .


# Build binary
RUN go build -o checkoutservice main.go


########################################################
# Stage 2: Runtime stage
FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

WORKDIR /app


# Install certificates
RUN apk add --no-cache ca-certificates


# Copy binary from builder
COPY --from=builder /build/checkoutservice .


# Create secure user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup


# Change ownership
RUN chown appuser:appgroup /app/checkoutservice


# Switch to secure user
USER appuser


# Expose port
EXPOSE 5050

# Run application
ENTRYPOINT ["./checkoutservice"]