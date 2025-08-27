APP_NAME=notifier-service
APP_VERSION?=0.1.0
BUILD_DIR=bin
MAIN=./cmd/server/main.go

DOCKER_IMAGE?=${APP_NAME}:${APP_VERSION}

.PHONY: all build run test lint docker-build docker-run clean

all: build

## Build the Go binary
build:
	@echo ">> Building ${APP_NAME}"
	GO111MODULE=on go build -o ${BUILD_DIR}/${APP_NAME} ${MAIN}

## Run locally
run:
	@echo ">> Running ${APP_NAME}"
	${BUILD_DIR}/${APP_NAME}

## Run unit tests
test:
	@echo ">> Running tests"
	go test ./... -v

## Run golangci-lint
lint:
	@echo ">> Linting Go code"
	golangci-lint run ./...

## Build docker image
docker-build:
	@echo ">> Building Docker image ${DOCKER_IMAGE}"
	docker build -t ${DOCKER_IMAGE} .

## Run docker container (with ports mapped)
docker-run:
	@echo ">> Running ${DOCKER_IMAGE}"
	docker run --rm -p 8080:8080 -p 9090:9090 ${DOCKER_IMAGE}

## Clean build artifacts
clean:
	@echo ">> Cleaning up"
	rm -rf ${BUILD_DIR}
