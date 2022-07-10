.PHONY: update-tags docker-build

docker-build:
	docker build ./docker \
		--build-arg VCS_REF=`git rev-parse HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

update-tags:
	git checkout main
	git tag -s -f -a -m "latest series" latest
	git checkout -
	git push origin refs/tags/latest -f

test:
	docker-compose -f ./docker/docker-compose.test.yml down
	docker-compose -f ./docker/docker-compose.test.yml up --build --abort-on-container-exit --exit-code-from=sut
