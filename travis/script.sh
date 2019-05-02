#!/bin/bash
set -e

TAG=$(echo ${SLUG} | cut -d/ -f2)

# Build image for specified architecture, if specified
if [[ ! -z "${ARCH}" ]]; then
    # TODO: if SOURCE=binary: use another Dockerfile instead
    if [[ "${SOURCE}" = "binary" ]]; then
        echo "installation from binary not yet implemented"
        exit 0
    fi

    docker build  --no-cache  -t ${TAG}  "${PREFIX}/"

    # Push image, if tag was specified
    if [[ -n "${TRAVIS_TAG}" ]]; then
        echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

        docker tag  ${TAG}  "${SLUG}:${TRAVIS_TAG}-${ARCH}"
        docker push "${SLUG}:${TRAVIS_TAG}-${ARCH}"
    fi

    exit 0
fi

# This happens when no ARCH was provided.  Specifically, in the deploy job.
echo "Saving images"

LATEST_AMD64="${SLUG}:${TRAVIS_TAG}-linux-amd64"
#LATEST_ARM7="${SLUG}:${TRAVIS_TAG}-linux-armv7"

mkdir images

docker pull ${LATEST_AMD64}
docker save ${LATEST_AMD64} | gzip > "images/${SLUG/\//-}-${TRAVIS_TAG}-linux-amd64.tgz"

#docker pull ${LATEST_ARM7}
#docker save ${LATEST_ARM7} | gzip > "images/${SLUG/\//-}-${TRAVIS_TAG}-linux-armv7.tgz"
