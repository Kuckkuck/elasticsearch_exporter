#PKG    = github.com/Kuckkuck/elasticsearch_exporter
PREFIX := /usr

all: build/elasticsearch_exporter

GO            := GOPATH=$(CURDIR) GOBIN=$(CURDIR)/build go
GO_BUILDFLAGS :=
GO_LDFLAGS    := -s -w

# This target uses the incremental rebuild capabilities of the Go compiler to speed things up.
# If no source files have changed, `go install` exits quickly without doing anything.
build/elasticsearch_exporter: FORCE
	$(GO) install $(GO_BUILDFLAGS) -ldflags '$(GO_LDFLAGS)' 

# which packages to test with static checkers?
GO_ALLPKGS := $(PKG) $(shell go list)
# which packages to measure coverage for?
GO_COVERPKGS := $(shell go list | grep -v plugins)
# output files from `go test`
GO_COVERFILES := $(patsubst %,build/%.cover.out,$(subst /,_,$(GO_TESTPKGS)))

# down below, I need to substitute spaces with commas; because of the syntax,
# I have to get these separators from variables
space := $(null) $(null)
comma := ,

check: all static-check build/cover.html FORCE
	@echo -e "\e[1;32m>> All tests successful.\e[0m"
static-check: FORCE
	@if s="$$(gofmt -s -l *.go pkg 2>/dev/null)"                            && test -n "$$s"; then printf ' => %s\n%s\n' gofmt  "$$s"; false; fi
	$(GO) vet $(GO_ALLPKGS)
build/%.cover.out: prepare-check FORCE
	$(GO) test $(GO_BUILDFLAGS) -ldflags '$(GO_LDFLAGS)' -coverprofile=$@ -covermode=count -coverpkg=$(subst $(space),$(comma),$(GO_COVERPKGS)) $(subst _,/,$*)
build/cover.out: $(GO_COVERFILES)
	pkg/test/util/gocovcat.go $(GO_COVERFILES) > $@
build/cover.html: build/cover.out
	$(GO) tool cover -html $< -o $@

install: FORCE all
	install -D -m 0755 build/elasticsearch_exporter "$(DESTDIR)$(PREFIX)/bin/limes"

clean: FORCE
	rm -f -- build/elasticsearch_exporter

build/docker.tar: clean
	make GO_LDFLAGS="-s -w -linkmode external -extldflags -static" DESTDIR='$(CURDIR)/build/install' install
	( cd build/install && tar cf - . ) > build/docker.tar

DOCKER       := docker
DOCKER_IMAGE := Kuckkuck/elasticsearch_exporter
DOCKER_TAG   := latest

docker: build/docker.tar
	$(DOCKER) build -t "$(DOCKER_IMAGE):$(DOCKER_TAG)" .

vendor: FORCE
	@# vendoring by https://github.com/holocm/golangvend
	golangvend

.PHONY: FORCE
