FROM python:3.12-alpine AS builder

WORKDIR /build

RUN apk add --no-cache gcc musl-dev libffi-dev


COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt


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