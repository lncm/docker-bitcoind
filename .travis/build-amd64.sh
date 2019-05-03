#!/bin/bash
set -e

TAG="${SLUG}:${TRAVIS_TAG:-$TRAVIS_BRANCH}-${FROM}-linux-${ARCH}"

BUILD_ARG=""
if [[ "${FROM}" = "binary" ]]; then
    BUILD_ARG="arch=x86_64"
fi

docker build  --no-cache  --build-arg "${BUILD_ARG}"  -t ${TAG}  ${PREFIX}/

# Push image, if tag was specified
if [[ -n "${TRAVIS_TAG}" ]]; then
    echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

    docker push "${TAG}"
fi



