############################
# Stage 1: Build Stage
############################
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

# Create non-root build user (security best practice)
RUN addgroup -S buildgroup && adduser -S builduser -G buildgroup

WORKDIR /build

# Copy only project file first (dependency caching)
COPY src/cartservice.csproj ./

# Restore dependencies
RUN dotnet restore cartservice.csproj \
    -r linux-musl-x64

# Copy remaining source code
COPY src/ ./

# Publish optimized self-contained binary
RUN dotnet publish cartservice.csproj \
    -c Release \
    -r linux-musl-x64 \
    --self-contained true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=true \
    -p:TrimMode=Full \
    -p:EnableCompressionInSingleFile=true \
    --no-restore \
    -o /app

############################
# Stage 2: Runtime Stage
############################
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine3.18

# Install security updates
RUN apk add --no-cache \
    ca-certificates \
    tzdata

# Create secure non-root runtime user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only final binary
COPY --from=builder /app/cartservice .

# Change ownership to secure user
RUN chown appuser:appgroup /app/cartservice

# Switch to non-root user
USER appuser

# Security hardening
ENV DOTNET_EnableDiagnostics=0 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    ASPNETCORE_HTTP_PORTS=7070 \
    COMPlus_EnableDiagnostics=0

# Expose service port
EXPOSE 7070

# Run application
ENTRYPOINT ["/app/cartservice"]
