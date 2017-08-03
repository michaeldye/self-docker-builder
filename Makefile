SHELL := /bin/bash
ARCH := $(shell tools/ubuntu-archname.bash)

# docker build container
DOCKERB_CNAME := self-docker-builder
DOCKERB_INAME := $(DOCKERB_CNAME)-i
DOCKERB_TAG := $(shell git log -1 --no-merges --oneline --pretty=format:"%h" HEAD)
DOCKERB_OPTS := --rm --no-cache

$(shell tools/flag.bash "$(DOCKERB_INAME):$(DOCKERB_TAG)" $(ARCH))
$(shell tools/flag.bash "$(DOCKERB_CNAME)" $(ARCH))

ifndef self_DIR
$(error "self_DIR is not set, please execute the build again with the variable set to the path of you local copy of Watson's Self platform (https://github.com/watson-intu/self)")
endif

# docker execution container; minimal self runtime stuff packed into a container
DOCKERE_INAME := self
DOCKERE_TAG := $(shell cd $(self_DIR) && git log -1 --no-merges --oneline --pretty=format:"%h" HEAD)
DOCKERE_OPTS := --rm --no-cache

$(shell tools/flag.bash "$(DOCKERE_INAME):$(DOCKERE_TAG)" $(ARCH))

ARTIFACTS := ./dist-self/self_instance

all: $(DOCKERE_INAME)_$(DOCKERE_TAG)-$(ARCH).flag

ifndef verbose
.SILENT:
endif

clean:
	@echo "Cleaning sources in build container, use *distclean* containers and images created by this project"
	# TODO: use this when the clean script for self doesn't remove the toolchain
	# docker exec -it $(DOCKERB_CNAME) /self/scripts/clean.sh
	-docker exec -it $(DOCKERB_CNAME) rm -Rf /self/bin/linux
	rm -Rf dist-self/

# clean everything, including docker images
distclean: mostlyclean
	@echo "Cleaning containers and images"
	-docker rm -f $(DOCKERB_CNAME) $(DOCKERE_CNAME)
	for image in $(DOCKERE_INAME) $(DOCKERB_INAME); do \
		docker images -qa $$image | xargs -n1 | sort | uniq | xargs docker rmi -f; \
	done
	rm -f *.flag

# do not remove docker images
mostlyclean: clean
	@echo "cleaning artifacts"
	rm -f Dockerfile-linux-*.bld Dockerfile-linux-*.ex

# targets for build infrastructure
Dockerfile-linux-$(ARCH).bld: Dockerfile-linux.bld.tmpl
	tools/Dockerfile-render-bld.bash $(ARCH) Dockerfile-linux.bld.tmpl Dockerfile-linux-$(ARCH).bld

# TODO: this image flag turned out to be newer than the container flag and so forces a rebuild, why?
$(DOCKERB_INAME)_$(DOCKERB_TAG)-$(ARCH).flag: Dockerfile-linux-$(ARCH).bld
	@echo "Building container image $(DOCKERB_INAME) ($(DOCKERB_INAME)_$(DOCKERB_TAG)-$(ARCH).flag)"
	docker build $(DOCKERB_OPTS) -t $(DOCKERB_INAME) -f Dockerfile-linux-$(ARCH).bld . && docker tag $(DOCKERB_INAME) $(DOCKERB_INAME):$(DOCKERB_TAG)

$(DOCKERB_CNAME)-$(ARCH).flag: $(DOCKERB_INAME)_$(DOCKERB_TAG)-$(ARCH).flag
	@echo "Running container $(DOCKERB_CNAME) $(DOCKERB_CNAME)-$(ARCH).flag"
	docker run -v $(self_DIR):/self -d --name $(DOCKERB_CNAME) -it $(DOCKERB_INAME):$(DOCKERB_TAG) /bin/sh

dist-self:
	mkdir -p dist-self

artifacts: $(ARTIFACTS)

# target for building code in the build container and copying distributable artifacts out of it
$(ARTIFACTS): $(DOCKERB_CNAME)-$(ARCH).flag | dist-self
	@echo "Making $(ARTIFACTS)"
	docker exec -it $(DOCKERB_CNAME) /self/scripts/build_linux.sh
	docker cp $(DOCKERB_CNAME):/self/bin/linux/. ./dist-self/

Dockerfile-linux-$(ARCH).ex: Dockerfile-linux.ex.tmpl
	tools/Dockerfile-render-ex.bash $(ARCH) Dockerfile-linux.ex.tmpl Dockerfile-linux-$(ARCH).ex

$(DOCKERE_INAME)_$(DOCKERE_TAG)-$(ARCH).flag: Dockerfile-linux-$(ARCH).ex $(ARTIFACTS)
	@echo "Building container image $(DOCKERE_INAME)"
	docker build $(DOCKERE_OPTS) -t $(DOCKERE_INAME) -f Dockerfile-linux-$(ARCH).ex . && docker tag $(DOCKERE_INAME) $(DOCKERE_INAME):$(DOCKERE_TAG)

# to allay confusion, leave these around
.PRECIOUS: $(DOCKERB_CNAME)-$(ARCH).flag $(DOCKERB_INAME)_$(DOCKERB_TAG)-$(ARCH).flag $(DOCKERE_INAME)_$(DOCKERE_TAG)-$(ARCH).flag

.PHONY: artifacts
