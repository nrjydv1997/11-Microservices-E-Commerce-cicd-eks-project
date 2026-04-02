#Stage 1: Builder
FROM golang:1.22-alpine AS builder 

#Dependencies k liye git install karo
RUN apk add --no-cache git

#Working directory
WORKDIR /build 

#GO Dependency files copy karo
COPY go.mod go.sum ./

#Dependencies download karo
RUN go mod download

#Baaki code copy karo
COPY . .

#Go binary build karo
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o shippingservice main.go 


#Stage 2: Runtime
FROM alpine:3.19

#Certificate install karo
RUN apk add --no-cache ca-certificate 

#Secure user banao
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

#App directory
WORKDIR /app 

#Builder se binary copy karo
COPY --from=builder /build/shippingservice .

#Ownership change karo
RUN chown appuser:appgroup /app/shippingservice

#Non- root user se run karo
USER appuser

#gRPC PORT
EXPOSE 50051

#Service start karo
ENTRYPOINT ["./shippingservice"]
