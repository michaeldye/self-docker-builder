SHELL := /bin/bash
ARCH := $(shell tools/ubuntu-archname.bash)

# do not name the following two the same thing
DOCKERB_CNAME := self-docker-builder
DOCKERB_INAME := $(DOCKERB_CNAME)-i
DOCKERB_TAG := $(shell git log -1 --no-merges --oneline --pretty=format:"%h" HEAD)
DOCKERB_OPTS := --rm --no-cache

# TODO: do dynamic path setting per-subproject, add make targets for each
self_DIR := /tmp/self

all: $(DOCKERB_CNAME)

ifndef verbose
.SILENT:
endif

clean:
	@echo "cleaning sources"

# clean everything, including docker images
distclean: mostlyclean
	-docker rm -f $(DOCKERB_CNAME)
	-images="$(shell docker images -qa $(DOCKERB_INAME))" && [[ "$$images" != "" ]] && echo $$images | xargs -n1 | sort | uniq | xargs docker rmi -f

# do not remove docker images
mostlyclean: clean
	@echo "cleaning just artifacts"
	rm -f Dockerfile-linux-*.bld

Dockerfile-linux-$(ARCH).bld: Dockerfile-linux.bld.tmpl
	tools/Dockerfile-render.bash $(ARCH) Dockerfile-linux.bld.tmpl Dockerfile-linux-$(ARCH).bld

$(DOCKERB_INAME): Dockerfile-linux-$(ARCH).bld
	-[[ "$(shell docker images -qa $(DOCKERB_INAME))" == "" ]] && docker build $(DOCKERB_OPTS) -t $(DOCKERB_INAME) -f Dockerfile-linux-$(ARCH).bld . && docker tag $(DOCKERB_INAME) $(DOCKERB_INAME):$(DOCKERB_TAG)

$(DOCKERB_CNAME): $(DOCKERB_INAME)
	-[[ "$(shell docker ps -aq -f name=$(DOCKERB_CNAME))" == "" ]] && docker run -v $(self_DIR):/self -d --name $(DOCKERB_CNAME) -it $(DOCKERB_INAME):$(DOCKERB_TAG) /bin/sh

# some phony targets do their own up-to-date checking b/c they don't fit nicely with the make paradigm (like Docker)
.PHONY: $(DOCKERB_CNAME) $(DOCKERB_INAME)
