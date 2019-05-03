#!/bin/bash
set -e

if [[ ! -z "${FROM}" ]]; then
    PREFIX="${PREFIX}/${FROM}"
fi

# Magic `sed` command that replaces the last occurrence of `FROM alpine` with `FROM arm32v7/alpine`
#   if base architecture of the final stage needs changing.  Don't ask me about the "3".
if [[ "${ARCH}" = "arm" ]]; then
    sed -i '3,\|^FROM alpine| s|FROM alpine|FROM arm32v7/alpine|' ${PREFIX}/Dockerfile
    echo "${PREFIX}/Dockerfile modified: Final stage image, base CPU architecture changed to: arm32v7"
fi
