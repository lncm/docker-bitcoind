#!/bin/bash
set -e

echo "Saving images…"

LATEST_AMD64_SRC="${SLUG}:${TRAVIS_TAG}-source-linux-amd64"
LATEST_AMD64_BIN="${SLUG}:${TRAVIS_TAG}-binary-linux-amd64"
#LATEST_ARM7_SRC="${SLUG}:${TRAVIS_TAG}-source-linux-armv7"
#LATEST_ARM7_BIN="${SLUG}:${TRAVIS_TAG}-binary-linux-armv7"

mkdir images

docker pull ${LATEST_AMD64_SRC}
docker save ${LATEST_AMD64_SRC} | gzip > "images/${SLUG/\//-}-${TRAVIS_TAG}-source-linux-amd64.tgz"

docker pull ${LATEST_AMD64_BIN}
docker save ${LATEST_AMD64_BIN} | gzip > "images/${SLUG/\//-}-${TRAVIS_TAG}-binary-linux-amd64.tgz"

#docker pull ${LATEST_ARM7_SRC}
#docker save ${LATEST_ARM7_SRC} | gzip > "images/${SLUG/\//-}-${TRAVIS_TAG}-source-linux-armv7.tgz"

#docker pull ${LATEST_ARM7_BIN}
#docker save ${LATEST_ARM7_BIN} | gzip > "images/${SLUG/\//-}-${TRAVIS_TAG}-binary-linux-armv7.tgz"
