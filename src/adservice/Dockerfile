FROM eclipse-temurin:19@sha256:f3fbf1ad599d4b5dbdd7ceb55708d10cb9fafb08e094ef91e92aa63b520a232e as builder

WORKDIR /app

COPY gradlew build.gradle settings.gradle ./
COPY gradle gradle
RUN chmod +x gradlew
RUN ./gradlew downloadRepos

COPY src src
RUN ./gradlew installDist

FROM eclipse-temurin:19.0.1_10-jre-alpine@sha256:fabe27bd9db502d484a11d3f571c2f4ef7bba4a172527084d939935358fb06c4

RUN apk add --no-cache -ca-certificates

WORKDIR /app
COPY --from=builder /app/build/install/hipstershop .

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 9555
ENTRYPOINT ["./bin/AdService"]