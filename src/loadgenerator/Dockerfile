#Stage-1 Builder

FROM python:3.12-alpine AS builder

WORKDIR /build

#Install build dependencies (if needed)
RUN apk add --no-cache gcc musl-dev libffi-dev

#Copy dependencies files first
COPY requirements.txt .

#Install dependencies
RUN pip install --user --no-cache-dir -r requirements.txt


####Stage-2 Runtime
FROM python:3.12-alpine

#Install Runtime dependencies
RUN apk add --no-cache ca-certificates

#Create secure user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

#Copy installed python packages
COPY --from=builder /root/.local /home/appuser/.local

#COPY Application file
COPY locustfile.py .

#Change ownership
RUN chown -R appuser:appgroup /app /home/appuser/.local

#Switch to non-root user
USER appuser

#Update PATH
ENV PATH="/home/appuser/.local/bin:$PATH"

#Default locust environment
ENV LOCUST_HOST=http://frontend:8080

#Expose locust UI port
EXPOSE 8089

#Run locust
ENTRYPOINT ["locust", "-f", "locustfile.py", "--host=http://frontend:8080"]
