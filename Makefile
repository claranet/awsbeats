.PHONY: all

GO_VERSION=$(shell go version | cut -d ' ' -f 3,4 | sed -e 's/ /-/g' | sed -e 's/\//-/g')
BEATS_VERSION ?= "master"
AWSBEATS_VERSION ?= "1-snapshot"

all: test build beats

test:
	go test ./firehose -v -coverprofile=coverage.txt -covermode=atomic

build:
	go build -buildmode=plugin ./plugins/firehose
	@mkdir -p "$(CURDIR)/target"
	@mv firehose.so "$(CURDIR)/target/firehose.so-$(AWSBEATS_VERSION)-$(BEATS_VERSION)-$(GO_VERSION)"

beats:
ifdef BEATS_VERSION
	@echo "Building filebeats:$(BEATS_VERSION)..."
	@cd "$$GOPATH/src/github.com/elastic/beats/filebeat" &&\
	git checkout $(BEATS_VERSION) &&\
	make &&\
	mv filebeat "$(CURDIR)/target/filebeat-$(BEATS_VERSION)-$(GO_VERSION)"
else
	$(error BEATS_VERSION is undefined)
endif
