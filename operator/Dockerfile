FROM golang:1.21-alpine as builder
WORKDIR /workspace
COPY go.mod go.sum ./
RUN apk add --no-cache git
RUN go env -w GOPROXY=https://proxy.golang.org
COPY . .
RUN go build -o /out/manager ./cmd/manager

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=builder /out/manager /usr/local/bin/manager
ENTRYPOINT ["/usr/local/bin/manager"]