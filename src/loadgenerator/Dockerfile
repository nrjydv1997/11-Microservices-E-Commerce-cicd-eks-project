# Stage 1: Builder
FROM python:3.11-alpine AS builder

RUN apk add --no-cache gcc g++ make python3-dev linux-headers

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --target=/build/packages -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build/packages /app/packages

COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

ENV PYTHONPATH="/app/packages:$PYTHONPATH"
ENV PATH="/app/packages/bin:$PATH"

EXPOSE 8089

ENTRYPOINT ["locust", "--host=http://frontend:80"]