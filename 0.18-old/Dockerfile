# Build stage for Bitcoin Core
FROM alpine:3.9 AS bitcoin-core

# fetch already built berkeleydb
COPY --from=lncm/berkeleydb:db-4.8.30.NC-linux-arm /opt /opt

# Replace `http:` repositories with `https:` ones
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN echo 'https://alpine.global.ssl.fastly.net/alpine/edge/testing' >> /etc/apk/repositories

# install packages necessary to build Bitcoind
RUN apk add --no-cache --update \
    autoconf \
    automake \
    boost-dev \
    build-base \
    chrpath \
    crosstool-ng \
    curl \
    file \
    g++ \
    gcc \
    git \
    gnupg \
    libevent-dev \
    libressl \
    libressl-dev \
    libtool \
    linux-headers \
    make \
    protobuf-dev \
    tar \
    wget \
    zeromq-dev

# We are inside Docker container.  It's easier to run as root, and no damage can be done anyway… so ¯\_(ツ)_/¯
ENV CT_EXPERIMENTAL=y
ENV CT_ALLOW_BUILD_AS_ROOT=y
ENV CT_ALLOW_BUILD_AS_ROOT_SURE=y

RUN apk add xz patch binutils

RUN ct-ng arm-unknown-linux-musleabi

RUN ct-ng -d build || true

RUN tail -n 200 build.log



# Alpine gotchas:
#
# `apk add --update wget` has to be run.
#       Otherwise "wget: unrecognized option: progress=dot:binary" is returned
#
# `apk add --update tor` has to be run.
#       Otherwise "tar: invalid tar magic" is returned
#
# `apk add --update patch`
#       Otherwise: "/usr/bin/patch: unrecognized option: 0"
#
# Just missing & needs installing: xz strip (part of binutils)
