# Stage 1: Builder stage

FROM golang:1.22-alpine AS Builder

# Install git (required for dependencies)
RUN apk add --no-cache git

# Create working directory
WORKDIR /build

# Copy dependency files first (cache optimization)
COPY go.mod go.sum ./

#Download dependencies
RUN go mod download

#Copy source code
COPY . .

# Build optimized binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o frontend main.go


############################
# Stage 2: Runtime stage
############################
FROM alpine:3.19

# Install certificates (HTTPS support)
RUN apk add --no-cache ca-certificates

#Create secure non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

#Create working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/frontend .

# Copy static files and templates
COPY --from=builder /build/static ./static
COPY --from=builder /build/templates ./templates

# Change ownership
RUN chown -R appuser:appgroup /app

#Switch to secure
USER appuser


#Expose frontend port
EXPOSE 8080

#Run frontend service
ENTRYPOINT ["./frontend"]