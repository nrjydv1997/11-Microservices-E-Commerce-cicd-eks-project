# Stage 1: Builder
FROM python:3.12-alpine AS builder

# Install C++ compiler for native packages (google-cloud-profiler)
RUN apk add --no-cache g++ make

WORKDIR /build

COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-alpine

RUN apk add --no-cache ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local

COPY . .

RUN chown -R appuser:appgroup /app /home/appuser/.local

# Fixed: /home not /bome
ENV PATH="/home/appuser/.local/bin:$PATH"

USER appuser

EXPOSE 8080

ENTRYPOINT ["python", "recommendation_server.py"]