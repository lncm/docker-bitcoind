# This Dockerfile builds Bitcoind … TODO:

# Bitcoin Core version to be build
#   NOTE: Unlike other images this one is NOT prefixed with `v`, as many things (like download URLs) use this form instead.
ARG VERSION=0.19.0.1

# Target CPU archtecture of built bitcoind binaries
ARG ARCH

# Define default versions so that they don't have to be repreated throughout the file
ARG VER_ALPINE=3.11

ARG USER=bitcoind
ARG DIR=/data

# `SOURCE=git` can be used for rc releases
ARG SOURCE=release



#
##
#
FROM alpine:${VER_ALPINE} AS preparer-base

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories

RUN apk add --no-cache  gnupg

ENV KEYS 71A3B16735405025D447E8F274810B012346C9A6 01EA5486DE18A882D4C2684590C8019E36C2E964

# Try to fetch keys from keyservers listed below.  On first success terminate with `exit 0`.  If loop is not interrupted,
#   it means all attempts failed, and `exit 1` is called.
RUN for srv in  keyserver.ubuntu.com  hkp://p80.pool.sks-keyservers.net:80  ha.pool.sks-keyservers.net  keyserver.pgp.com  pgp.mit.edu; do \
        timeout 9s  gpg  --keyserver "${srv}"  --recv-keys ${KEYS}  >/dev/null 2<&1 && \
            { echo "OK:  ${srv}" && exit 0; } || \
            { echo "ERR: ${srv} fail=$?"; } ; \
    done && exit 1

RUN gpg --list-keys && \
    gpg --list-keys ${KEYS}



#
## Option #1: [default] Fetch bitcoind source from release tarballs
#
FROM preparer-base AS preparer-release

ARG VERSION

# Download checksums
ADD https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc  ./

# Download source code (intentionally different website than checksums)
ADD https://bitcoin.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}.tar.gz ./

# Verify that hashes are signed with the previously imported key
RUN gpg --verify SHA256SUMS.asc

# Verify that downloaded source-code archive matches exactly the hash that's provided
RUN grep " bitcoin-${VERSION}.tar.gz\$" SHA256SUMS.asc | sha256sum -c -

# Extract
RUN tar -xzf "bitcoin-${VERSION}.tar.gz" && \
    rm  -f   "bitcoin-${VERSION}.tar.gz"



#
## Option #2: Fetch bitcoind source from Github
#
FROM preparer-base AS preparer-git

ARG VERSION

RUN apk add --no-cache git

# Fetch the source code at a specific TAG
RUN git clone  -b "v${VERSION}"  --depth=1  https://github.com/bitcoin/bitcoin.git  "/bitcoin-${VERSION}/"

# Verify tag, and copy source code to predetermined location on success
RUN cd "/bitcoin-${VERSION}/" && \
    git verify-tag "v${VERSION}"



#
## Alias due to `COPY --from=` not accepting ARGs
#
FROM preparer-${SOURCE} AS preparer



#
## Build bitcoind (regardless on how the source code was obtained)
#
# NOTE: this stage is _qemu-lated_
FROM ${ARCH:+${ARCH}/}alpine:${VER_ALPINE} AS builder

ARG VERSION
ARG SOURCE

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories

# TODO: Are all of those necessary(?)
RUN apk add --no-cache \
        gnupg \
        autoconf \
        automake \
        boost-dev \
        build-base \
        chrpath \
        file \
        libevent-dev \
        libressl \
        libressl-dev \
        libtool \
        linux-headers \
        protobuf-dev \
        zeromq-dev

# Fetch pre-built berkeleydb
# TODO:  Add optional in-this-file stage for buildling berkeleydb
COPY  --from=lncm/berkeleydb:db-4.8.30.NC /opt/  /opt/

#
COPY  --from=preparer /bitcoin-${VERSION}/  /bitcoin-${VERSION}/

# Change to the extracted directory
WORKDIR /bitcoin-${VERSION}/


ENV BITCOIN_PREFIX /opt/bitcoin-${VERSION}

RUN ./autogen.sh
RUN ./configure LDFLAGS=-L/opt/db4/lib/ CPPFLAGS=-I/opt/db4/include/ \
    --prefix="${BITCOIN_PREFIX}" \
    --disable-man \
    --disable-shared \
    --disable-ccache \
    --enable-static \
    --enable-reduce-exports \
    --without-gui \
    --without-libs \
    --with-utils \
    --with-daemon

RUN make -j$(($(nproc) + 1)) check
RUN make install

# List installed binaries pre-strip
RUN ls -lh ${BITCOIN_PREFIX}/bin/

RUN strip -v ${BITCOIN_PREFIX}/bin/bitcoind
RUN strip -v ${BITCOIN_PREFIX}/bin/bitcoin-cli
RUN strip -v ${BITCOIN_PREFIX}/bin/bitcoin-wallet
RUN strip -v ${BITCOIN_PREFIX}/bin/bitcoin-tx

# List installed binaries after stripping
RUN ls -lh "${BITCOIN_PREFIX}/bin/"

# Print sha256 hashes of final binaries
RUN sha256sum ${BITCOIN_PREFIX}/bin/bitcoin*



#
##
#
# NOTE: `${ARCH:+${ARCH}/}` - if ARCH is set, append `/` to it, leave it empty otherwise
# NOTE: this stage is _qemu-lated_
FROM ${ARCH:+${ARCH}/}alpine:${VER_ALPINE} AS final

ARG VERSION
ARG USER
ARG DIR

LABEL maintainer="Damian Mee (@meeDamian)"

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories

# TODO: Are all of those necessary(?)
RUN apk add --no-cache  libressl  libstdc++  boost-thread  boost-chrono  boost-filesystem  libevent  libsodium  libzmq

COPY  --from=builder /opt/bitcoin-${VERSION}/bin/  /usr/local/bin/

# NOTE: Default GID == UID == 1000
RUN adduser --disabled-password \
            --home "${DIR}/" \
            --gecos "" \
            "${USER}"

USER ${USER}

# Needed to prevent `VOLUME ${DIR}/.bitcoind/` being created with `root` as owner
RUN mkdir -p "${DIR}/.bitcoin/"

# Expose volume containing all `bitcoind` data
VOLUME ${DIR}/.bitcoin/

# REST interface
EXPOSE 8080

# P2P network (mainnet, testnet & regnet respectively)
EXPOSE 8333 18333 18444

# RPC interface (mainnet, testnet & regnet respectively)
EXPOSE 8332 18332 18443

# ZMQ ports (for transactions & blocks respectively)
EXPOSE 28332 28333

ENTRYPOINT ["bitcoind"]

CMD ["-zmqpubrawblock=tcp://0.0.0.0:28332", "-zmqpubrawtx=tcp://0.0.0.0:28333"]
