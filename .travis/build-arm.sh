#!/bin/bash
set -e

wget https://raw.githubusercontent.com/alpinelinux/alpine-chroot-install/v0.10.0/alpine-chroot-install \
    && echo 'dcceb34aa63767579f533a7f2e733c4d662b0d1b  alpine-chroot-install' | sha1sum -c \
    || exit 1

chmod +x alpine-chroot-install
sudo ./alpine-chroot-install  -a armv7  -b v3.9

/alpine/enter-chroot uname -a
/alpine/enter-chroot env

apk add docker

TAG="${SLUG}:${TRAVIS_TAG:-$TRAVIS_BRANCH}-${FROM}-linux-${ARCH}"

echo "Building ${TAG} with ${PREFIX}/Dockerfile…"

if [[ "${FROM}" = "binary" ]]; then
    docker build  --no-cache  --build-arg "arch=${ARCH}"  -t ${TAG}  ${PREFIX}/${FROM}/

else
    docker build  --no-cache  -t ${TAG}  ${PREFIX}/${FROM}/
fi


# Push image, if tag was specified
if [[ -n "${TRAVIS_TAG}" ]]; then
    echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

    docker push "${TAG}"
fi



