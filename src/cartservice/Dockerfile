############################
# Stage 1: Build Stage
############################
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

RUN addgroup -S buildgroup && adduser -S builduser -G buildgroup

WORKDIR /build

# Copy only project file first (dependency caching)
COPY src/cartservice.csproj ./

# ✅ FIX: Restore WITHOUT -r flag so grpc.tools picks linux_musl_x64 protoc
# that matches the Alpine (musl) build environment
RUN dotnet restore cartservice.csproj

# Copy remaining source code
COPY src/ ./

# ✅ FIX: Publish also WITHOUT --no-restore so it re-resolves
# the correct native tools for linux-musl-x64
RUN dotnet publish cartservice.csproj \
    -c Release \
    -r linux-musl-x64 \
    --self-contained true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=true \
    -p:TrimMode=Full \
    -p:EnableCompressionInSingleFile=true \
    -o /app

############################
# Stage 2: Runtime Stage
############################
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine3.18

RUN apk add --no-cache \
    ca-certificates \
    tzdata

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/cartservice .

RUN chown appuser:appgroup /app/cartservice

USER appuser

ENV DOTNET_EnableDiagnostics=0 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    ASPNETCORE_HTTP_PORTS=7070 \
    COMPlus_EnableDiagnostics=0

EXPOSE 7070

ENTRYPOINT ["/app/cartservice"]