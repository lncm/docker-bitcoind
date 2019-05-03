#!/bin/bash
set -e

# make sure Docker's config folder exists
mkdir -p ~/.docker

# Putting experimental:true to config enables manifest options
echo '{ "experimental": "enabled" }' > ~/.docker/config.json

# put above config into effect
sudo systemctl restart docker

echo "${DOCKER_PASS}" | docker login -u="${DOCKER_USER}" --password-stdin

# print this to verify manifest options are now available
docker version



# Example: lncm/bitcoind:0.18.0
IMAGE_VERSIONED="${SLUG}:${TRAVIS_TAG}"
IMAGE_AMD64_SRC="${IMAGE_VERSIONED}-source-linux-amd64"
#IMAGE_ARM7_SRC="${IMAGE_VERSIONED}-source-linux-armv7"

docker pull "${IMAGE_AMD64_SRC}"
#docker pull "${IMAGE_ARM7_SRC}"

echo     "Pushing manifest ${IMAGE_VERSIONED}"
docker -D manifest create "${IMAGE_VERSIONED}"  "${IMAGE_AMD64_SRC}"  #"${IMAGE_ARM7_SRC}"
#docker manifest annotate  "${IMAGE_VERSIONED}"  "${IMAGE_ARM7_SRC}"  --os linux  --arch arm  --variant v7
docker manifest push      "${IMAGE_VERSIONED}"

# example: lncm/bitcoind:0.18
IMAGE_MINOR_VER="${SLUG}:${VER}"

echo     "Pushing manifest ${IMAGE_MINOR_VER}"
docker -D manifest create "${IMAGE_MINOR_VER}"  "${IMAGE_AMD64_SRC}"  #"${IMAGE_ARM7_SRC}"
#docker manifest annotate  "${IMAGE_MINOR_VER}"  "${IMAGE_ARM7_SRC}"  --os linux  --arch arm  --variant v7
docker manifest push      "${IMAGE_MINOR_VER}"

#example: lncm/bitcoind:latest
IMAGE_LATEST="${SLUG}:latest"

echo     "Pushing manifest ${IMAGE_LATEST}"
docker -D manifest create "${IMAGE_LATEST}"  "${IMAGE_AMD64_SRC}"  #"${IMAGE_ARM7_SRC}"
#docker manifest annotate  "${IMAGE_LATEST}"  "${IMAGE_ARM7_SRC}"  --os linux  --arch arm  --variant v7
docker manifest push      "${IMAGE_LATEST}"



# Example: lncm/bitcoind:0.18.0-binary
IMAGE_VERSIONED="${SLUG}:${TRAVIS_TAG}-binary"
IMAGE_AMD64_BIN="${IMAGE_VERSIONED}-binary-linux-amd64"
#IMAGE_ARM7_BIN="${IMAGE_VERSIONED}-binary-linux-armv7"

docker pull "${IMAGE_AMD64_BIN}"
#docker pull "${IMAGE_ARM7_BIN}"

echo     "Pushing manifest ${IMAGE_VERSIONED}"
docker -D manifest create "${IMAGE_VERSIONED}"  "${IMAGE_AMD64_BIN}"  #"${IMAGE_ARM7_BIN}"
#docker manifest annotate  "${IMAGE_VERSIONED}"  "${IMAGE_ARM7_BIN}"  --os linux  --arch arm  --variant v7
docker manifest push      "${IMAGE_VERSIONED}"

# example: lncm/bitcoind:0.18-binary
IMAGE_MINOR_VER="${SLUG}:${VER}-binary"

echo     "Pushing manifest ${IMAGE_MINOR_VER}"
docker -D manifest create "${IMAGE_MINOR_VER}"  "${IMAGE_AMD64_BIN}"  #"${IMAGE_ARM7_BIN}"
#docker manifest annotate  "${IMAGE_MINOR_BIN}"  "${IMAGE_ARM7_BIN}"  --os linux  --arch arm  --variant v7
docker manifest push      "${IMAGE_MINOR_VER}"

#example: lncm/bitcoind:binary
IMAGE_BINARY="${SLUG}:binary"

echo     "Pushing manifest ${IMAGE_BINARY}"
docker -D manifest create "${IMAGE_BINARY}"  "${IMAGE_AMD64_BIN}"  #"${IMAGE_ARM7_BIN}"
#docker manifest annotate  "${IMAGE_BINARY}"  "${IMAGE_ARM7_BIN}"  --os linux  --arch arm  --variant v7
docker manifest push      "${IMAGE_BINARY}"
