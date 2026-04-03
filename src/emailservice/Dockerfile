FROM python:3.12-alpine

# Install build dependencies
RUN apk add --no-cache gcc g++ musl-dev libffi-dev python3-dev ca-certificates

# Install setuptools first, then requirements system-wide (no --user)
RUN pip install --no-cache-dir setuptools

WORKDIR /app

COPY requirements.txt .

# System-wide install - no path/PYTHONPATH issues
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["python", "email_server.py"]