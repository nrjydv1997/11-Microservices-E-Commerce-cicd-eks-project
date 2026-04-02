#stage 1: Builder
FROM python:3.12-alpine AS builder

#App k liye working directory
WORKDIR /build

#Copy dependency list
COPY requirements.txt .

#Install dependencies
RUN pip install --user --no-cache-dir -r requirements.txt


###Stage 2: Runtime
FROM python:3.12-alpine

#Install Secure Certificate
RUN apk add --no-cache ca-certificates

#Secure user 
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

#Create Directory for app
WORKDIR /app

#Copy packages from builder stage
COPY --from=builder /root/.local /home/appuser/.local

#Copy application code
COPY . .

#Change ownership
RUN chown appuser:appgroup /app /home/appuser/.local

#Update PATH
ENV PATH="/bome/appuser/.local/bin:$PATH"

#RUn by non-root user
USER appuser

#Service Port
EXPOSE 8080

#Start Service
ENTRYPOINT ["python", "recommendation_server.py"]
