FROM python:3.11-alpine

# google-cloud-profiler needs C++ compiler to build
RUN apk add --no-cache gcc g++ make musl-dev python3-dev ca-certificates

RUN pip install --no-cache-dir setuptools

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["python", "recommendation_server.py"]