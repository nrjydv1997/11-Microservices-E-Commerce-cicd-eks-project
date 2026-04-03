# Stage 1: Builder
FROM python:3.12-alpine AS builder

RUN apk add --no-cache gcc g++ musl-dev libffi-dev python3-dev

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

USER appuser

ENV PATH="/home/appuser/.local/bin:$PATH"
# Add this line - tells Python where to find the packages
ENV PYTHONPATH="/home/appuser/.local/lib/python3.12/site-packages:$PYTHONPATH"

EXPOSE 8080

ENTRYPOINT ["python", "email_server.py"]