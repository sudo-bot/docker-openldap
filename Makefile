IMAGE_TAG ?= action-docker-compose
IMAGE_TAG_GHCR ?= ghcr.io/sudo-bot/docker-openldap/docker-openldap:latest

# All: linux/amd64,linux/arm64,linux/riscv64,linux/ppc64le,linux/s390x,linux/386,linux/mips64le,linux/mips64,linux/arm/v7,linux/arm/v6
PLATFORM ?= linux/amd64

ACTION ?= load
PROGRESS_MODE ?= plain

.PHONY: update-tags docker-build docker-push

docker-build:
	# https://github.com/docker/buildx#building
	docker buildx build \
		--tag $(IMAGE_TAG) \
		--progress $(PROGRESS_MODE) \
		--platform $(PLATFORM) \
		--build-arg VCS_REF=`git rev-parse HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--$(ACTION) \
		./docker

docker-tag-ghcr:
	docker tag $(IMAGE_TAG) $(IMAGE_TAG_GHCR)

docker-push:
	docker push $(IMAGE_TAG)

docker-push-ghcr:
	docker push $(IMAGE_TAG_GHCR)

update-tags:
	git checkout main
	git tag -s -f -a -m "latest series" latest
	git checkout -
	git push origin refs/tags/latest -f

test:
	BUILDKIT_PROGRESS=plain docker compose -f ./docker/docker-compose.test.yml down
	BUILDKIT_PROGRESS=plain docker compose -f ./docker/docker-compose.test.yml up --build --abort-on-container-exit --exit-code-from=sut
