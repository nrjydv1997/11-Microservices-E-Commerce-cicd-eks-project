# Stage 1: Builder
FROM python:3.11-alpine AS builder

RUN apk add --no-cache g++ make

WORKDIR /build

COPY requirements.txt .

# Install to a specific target dir
RUN pip install --no-cache-dir --target=/build/packages -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy installed packages
COPY --from=builder /build/packages /app/packages

COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

# Point Python to the packages
ENV PYTHONPATH="/app/packages:$PYTHONPATH"
ENV PATH="/app/packages/bin:$PATH"

EXPOSE 8089

ENTRYPOINT ["locust", "--host=http://frontend:80"]