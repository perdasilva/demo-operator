CONTAINER_TOOL ?= docker

BUNDLE_IMG ?= quay.io/olmtest/kubecon25/demo-operator-bundle:v0.0.1
CATALOG_IMG ?= quay.io/olmtest/kubecon25/demo-catalog:v0.0.1

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: all
all: docker-buildx

# PLATFORMS defines the target platforms for the manager image be built to provide support to multiple
# architectures. (i.e. make docker-buildx IMG=myregistry/mypoperator:0.0.1). To use this option you need to:
# - be able to use docker buildx. More info: https://docs.docker.com/build/buildx/
# - have enabled BuildKit. More info: https://docs.docker.com/develop/develop-images/build_enhancements/
# - be able to push the image to your registry (i.e. if you do not set a valid value via IMG=<myregistry/image:<tag>> then the export will fail)
# To adequately provide solutions that are compatible with multiple platforms, you should consider using this option.
PLATFORMS ?= linux/arm64,linux/amd64,linux/s390x,linux/ppc64le

# --- NEW: Define a reusable recipe for building a single image ---
# $1: The source Dockerfile (e.g., bundle.Dockerfile)
# $2: The full image tag (e.g., ${BUNDLE_IMG})
define build_cross_platform
    @echo "--- Building $1 ---"
    # copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into .cross file
    sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' $1 > $1.cross
    # Build and push the image
    - $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag $2 -f $1.cross .
    # Clean up the .cross file
    rm $1.cross
endef
# --- End of new block ---

.PHONY: docker-buildx
docker-buildx: ## Build and push docker images for bundle and catalog.
    ## Set BUNDLE_IMG and CATALOG_IMG vars (e.g., make docker-buildx BUNDLE_IMG=... CATALOG_IMG=...)
    # Create builder once
	- $(CONTAINER_TOOL) buildx create --name demo-operator-builder
	$(CONTAINER_TOOL) buildx use demo-operator-builder

	# Build both images using the canned recipe
	$(call build_cross_platform,bundle.Dockerfile,${BUNDLE_IMG})
	$(call build_cross_platform,catalog.Dockerfile,${CATALOG_IMG})

	# Remove builder once
	- $(CONTAINER_TOOL) buildx rm demo-operator-builder
