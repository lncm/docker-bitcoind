#!/bin/bash
set -e

TAG="${SLUG}:${TRAVIS_TAG:-$TRAVIS_BRANCH}-${FROM}-linux-${ARCH}"

if [[ "${FROM}" = "binary" ]]; then
    docker build  --no-cache  --build-arg "arch=x86_64"  -t ${TAG}  ${PREFIX}/

else
    docker build  --no-cache  -t ${TAG}  ${PREFIX}/
fi

docker build  --no-cache  --build-arg "${BUILD_ARG}"  -t ${TAG}  ${PREFIX}/

# Push image, if tag was specified
if [[ -n "${TRAVIS_TAG}" ]]; then
    echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

    docker push "${TAG}"
fi



