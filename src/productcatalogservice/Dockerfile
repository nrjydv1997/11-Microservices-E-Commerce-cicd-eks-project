#Stage 1: Buidler stage
FROM golang:1.22-alpine AS buidler

#Install git (required for dependencies)
RUN apk add --no-cache git

#Create working directory
WORKDIR /build

#Copy dependency files first
COPY go.mod go.sum ./

#Download dependencies
RUN go mod download

#Copy Source code
COPY . .

#Build optimized binary
RUN go build -gcflags="${SKAFFOLD_GO_GCFLAGS}" -o /productcatalogservice .

# Stage 2: Runtime stage
FROM alpine:3.19

#Install certificates
RUN apk add --no-cache ca-certificates

#Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

#Create working directory
WORKDIR /app

#Copy binary from builder
COPY --from=builder /build/productcatalogservice .

#Change ownership
RUN chown -R appuser:appgroup /app

#Switch to secure user
USER appuser

#Expose gRPC port
EXPOSE 3550

#Run Service
ENTRYPOINT ["./productcatalogservice"]