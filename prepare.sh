#!/bin/bash
set -e

wget -N https://github.com/multiarch/qemu-user-static/releases/download/v4.0.0-5/x86_64_qemu-arm-static.tar.gz
tar -xvf x86_64_qemu-arm-static.tar.gz

docker run --rm --privileged multiarch/qemu-user-static:register
