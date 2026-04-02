############################
# Stage 1: Builder stage
############################
FROM python:3.12-alpine AS builder

WORKDIR /build

# ✅ FIX: Add g++ and python3-dev needed by google-cloud-profiler's C++ extension
RUN apk add --no-cache gcc g++ musl-dev libffi-dev python3-dev

COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt

############################
# Stage 2: Runtime stage
############################
FROM python:3.12-alpine

RUN apk add --no-cache ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local

COPY . .

RUN chown -R appuser:appgroup /app /home/appuser/.local

USER appuser

ENV PATH="/home/appuser/.local/bin:$PATH"

EXPOSE 8080

ENTRYPOINT ["python", "email_server.py"]