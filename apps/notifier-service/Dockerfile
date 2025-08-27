FROM golang:1.21-alpine AS build
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build \
    cd cmd/notifier && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags "-s -w" -o /out/notifier

FROM gcr.io/distroless/base-debian12:nonroot
WORKDIR /app
COPY --from=build /out/notifier /app/notifier
USER nonroot:nonroot
EXPOSE 8081
ENTRYPOINT ["/app/notifier"]