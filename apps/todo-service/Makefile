APP_NAME=todo-service
APP_VERSION?=0.1.0
BUILD_DIR=build/libs
JAR_FILE=${BUILD_DIR}/${APP_NAME}-${APP_VERSION}.jar

DOCKER_IMAGE?=${APP_NAME}:${APP_VERSION}

.PHONY: all build run test docker-build docker-run clean

all: build

## Build Spring Boot JAR
build:
	@echo ">> Building ${APP_NAME}"
	./gradlew clean build -x test

## Run locally
run:
	@echo ">> Running ${APP_NAME}"
	./gradlew bootRun

## Run tests
test:
	@echo ">> Running tests"
	./gradlew test

## Build docker image
docker-build:
	@echo ">> Building Docker image ${DOCKER_IMAGE}"
	docker build -t ${DOCKER_IMAGE} .

## Run docker container (with ports mapped)
docker-run:
	@echo ">> Running ${DOCKER_IMAGE}"
	docker run --rm -p 8080:8080 ${DOCKER_IMAGE}

## Clean build artifacts
clean:
	@echo ">> Cleaning up"
	./gradlew clean
