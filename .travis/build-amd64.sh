#!/bin/bash
set -e

TAG="${SLUG}:${TRAVIS_TAG:-$TRAVIS_BRANCH}-${FROM}-linux-${ARCH}"

echo "Building ${TAG} with ${PREFIX}/Dockerfile…"

if [[ "${FROM}" = "binary" ]]; then
    docker build  --no-cache  --build-arg "arch=x86_64"  -t ${TAG}  ${PREFIX}/${FROM}/

else
    docker build  --no-cache  -t ${TAG}  ${PREFIX}/${FROM}/
fi


# Push image, if tag was specified
if [[ -n "${TRAVIS_TAG}" ]]; then
    echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

    docker push "${TAG}"
fi



