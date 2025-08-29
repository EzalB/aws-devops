BINARY_NAME=manager
IMG ?= ghcr.io/yourorg/canary-operator:latest

all: build

build:
	go build -o bin/$(BINARY_NAME) ./cmd/manager

run: build
	./bin/$(BINARY_NAME) --metrics-addr=:8080

test:
	go test ./... -v

docker-build:
	docker build -t $(IMG) .

docker-push:
	docker push $(IMG)

clean:
	rm -rf bin