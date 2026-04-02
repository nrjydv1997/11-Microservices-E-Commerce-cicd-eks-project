############################
# Stage 1: Build Stage
############################
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

# ✅ KEY FIX: Install protoc natively on Alpine (musl-compatible)
# grpc.tools linux_x64 protoc is glibc-linked and cannot run on musl/Alpine
RUN apk add --no-cache protobuf protobuf-dev

RUN addgroup -S buildgroup && adduser -S builduser -G buildgroup

WORKDIR /build

# Copy only project file first (dependency caching)
COPY src/cartservice.csproj ./

# Restore with linux-musl-x64 runtime
RUN dotnet restore cartservice.csproj \
    -r linux-musl-x64

# Copy remaining source code
COPY src/ ./

# ✅ Tell grpc.tools to use the system-installed protoc, not its own bundled binary
RUN dotnet publish cartservice.csproj \
    -c Release \
    -r linux-musl-x64 \
    --self-contained true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=true \
    -p:TrimMode=Full \
    -p:EnableCompressionInSingleFile=true \
    -p:Protobuf_ProtocFullPath=/usr/bin/protoc \
    --no-restore \
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