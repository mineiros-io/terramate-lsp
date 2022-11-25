# Set default shell to bash
SHELL := /bin/bash -o pipefail -o errexit -o nounset

COVERAGE_REPORT ?= coverage.txt

addlicense=go run github.com/google/addlicense@v1.0.0 -ignore **/*.yml

.PHONY: default
default: help

## Format go code
.PHONY: fmt
fmt:
	go run golang.org/x/tools/cmd/goimports@v0.1.7 -w .

## lint code
.PHONY: lint
lint:
	go run github.com/golangci/golangci-lint/cmd/golangci-lint@v1.49.0 run ./...

## add license to code
.PHONY: license
license:
	$(addlicense) -c "Mineiros GmbH" .

## check if code is licensed properly
.PHONY: license/check
license/check:
	$(addlicense) --check .

## check go modules are tidy
.PHONY: mod/check
mod/check:
	@./hack/mod-check

## tidy up go modules
.PHONY: mod
mod:
	go mod tidy

## generates coverage report
.PHONY: coverage
coverage: 
	go test -count=1 -coverprofile=$(COVERAGE_REPORT) -coverpkg=./...  ./...

## generates coverage report and shows it on the browser locally
.PHONY: coverage/show
coverage/show: coverage
	go tool cover -html=$(COVERAGE_REPORT)

## test code
.PHONY: test
test: 
	go test -count=1 -race ./...

## Build terramate-ls into bin directory
.PHONY: build
build:
	go build -o bin/terramate-ls ./cmd/terramate-ls

## Install terramate-ls on the host
.PHONY: install
install:
	go install ./cmd/terramate-ls

## remove build artifacts
.PHONY: clean
clean:
	rm -rf bin/*

## creates a new release tag
.PHONY: release/tag
release/tag: VERSION?=v$(shell cat VERSION)
release/tag:
	git tag -a $(VERSION) -m "Release $(VERSION)"
	git push origin $(VERSION)

## Display help for all targets
.PHONY: help
help:
	@awk '/^.PHONY: / { \
		msg = match(lastLine, /^## /); \
			if (msg) { \
				cmd = substr($$0, 9, 100); \
				msg = substr(lastLine, 4, 1000); \
				printf "  ${GREEN}%-30s${RESET} %s\n", cmd, msg; \
			} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
