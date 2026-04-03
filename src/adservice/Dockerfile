FROM eclipse-temurin:19@sha256:f3fbf1ad599d4b5dbdd7ceb55708d10cb9fafb08e094ef91e92aa63b520a232e AS builder

WORKDIR /app

COPY gradlew build.gradle settings.gradle ./
COPY gradle gradle
RUN chmod +x gradlew
RUN ./gradlew downloadRepos

COPY src src
RUN ./gradlew installDist

FROM eclipse-temurin:19.0.1_10-jre-alpine@sha256:fabe27bd9db502d484a11d3f571c2f4ef7bba4a172527084d939935358fb06c4

# Fixed: removed extra dash
RUN apk add --no-cache ca-certificates wget

# Install Google Cloud Profiler Java agent
RUN mkdir -p /opt/cprof && \
    wget -q -O /tmp/cprof.tar.gz https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent_alpine.tar.gz && \
    tar -xzf /tmp/cprof.tar.gz -C /opt/cprof && \
    rm /tmp/cprof.tar.gz

WORKDIR /app
COPY --from=builder /app/build/install/hipstershop .

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 9555
ENTRYPOINT ["./bin/AdService"]