# This Dockerfile builds Bitcoin Core and packages it into a minimal `final` image

# VERSION of Bitcoin Core to be build
#   NOTE: Unlike our other images this one is NOT prefixed with `v`,
#           as many things (like download URLs) use this form instead.
ARG VERSION=0.21.2


# CPU architecture to build binaries for
ARG ARCH

# Define default versions so that they don't have to be repeated throughout the file
ARG VER_ALPINE=3.12

# $USER name, and data $DIR to be used in the `final` image
ARG USER=bitcoind
ARG DIR=/data

# Choose where to get bitcoind sources from, options: release, git
#   NOTE: Only `SOURCE=git` can be used for RC releases
ARG SOURCE=release

# Choose where to get BerkeleyDB from, options: prebuilt, compile
#   NOTE: When compiled here total execution time exceeds allowed CI limits, so pre-built one is used by default
ARG BDB_SOURCE=prebuilt



#
## `preparer-base` installs dependencies needed by both ways of fetching the source,
#       as well as imports GPG keys needed to verify authenticity of the source.
#
FROM alpine:${VER_ALPINE} AS preparer-base

# Make sure APKs are downloaded over SSL. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories

RUN apk add --no-cache  gnupg

ENV KEYS 71A3B16735405025D447E8F274810B012346C9A6 01EA5486DE18A882D4C2684590C8019E36C2E964
RUN timeout 16s  gpg  --keyserver keyserver.ubuntu.com  --recv-keys $KEYS

# Print imported keys, but also ensure there's no other keys in the system
RUN gpg --list-keys | tail -n +3 | tee /tmp/keys.txt && \
    gpg --list-keys $KEYS | diff - /tmp/keys.txt



#
## Option #1: [default] Fetch bitcoind source from release tarballs
#
FROM preparer-base AS preparer-release

ARG VERSION

# Download checksums
ADD https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc  ./

# Download source code (intentionally different website than checksums)
ADD https://bitcoin.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz ./

# Verify that hashes are signed with the previously imported key
RUN gpg --verify SHA256SUMS.asc

# Verify that downloaded source-code archive matches exactly the hash that's provided
RUN grep " bitcoin-$VERSION.tar.gz\$" SHA256SUMS.asc | sha256sum -c -

# Extract
RUN tar -xzf "bitcoin-$VERSION.tar.gz" && \
    rm  -f   "bitcoin-$VERSION.tar.gz"



#
## Option #2: Fetch bitcoind source from GitHub
#
FROM preparer-base AS preparer-git

ARG VERSION

RUN apk add --no-cache git

# Fetch the source code at a specific TAG
RUN git clone  -b "v$VERSION"  --depth=1  https://github.com/bitcoin/bitcoin.git  "/bitcoin-$VERSION/"

# Verify tag, and copy source code to predetermined location on success
RUN cd "/bitcoin-$VERSION/" && \
    git verify-tag "v$VERSION"



#
## Alias to go around `COPY` not accepting ARGs in value passed to `--from=`
#
FROM preparer-${SOURCE} AS preparer



#
## `berkeleydb-prebuilt` downloads a pre-built BerkeleyDB to make sure
#       the overall build time of this Dockerfile fits within CI limits.
#
FROM lncm/berkeleydb:v4.8.30.NC${ARCH:+-${ARCH}} AS berkeleydb-prebuilt

#
## `berkeleydb-compile` builds BerkeleyDB from source using script provided in bitcoind repo.
#
FROM alpine:${VER_ALPINE} AS berkeleydb-compile
# TODO: implement ^^
RUN echo "Not implemented" && exit 1


FROM berkeleydb-${BDB_SOURCE} AS berkeleydb



#
## `builder` builds Bitcoin Core regardless on how the source, and BDB code were obtained.
#
# NOTE: this stage is emulated using QEMU
# NOTE: `${ARCH:+${ARCH}/}` - if ARCH is set, append `/` to it, leave it empty otherwise
FROM ${ARCH:+${ARCH}/}alpine:${VER_ALPINE} AS builder

ARG VERSION
ARG SOURCE

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories

RUN apk add --no-cache \
        autoconf \
        automake \
        boost-dev \
        sqlite-dev \
        build-base \
        chrpath \
        file \
        libevent-dev \
        libressl \
        libtool \
        linux-headers \
        zeromq-dev

# Fetch pre-built berkeleydb
COPY  --from=berkeleydb /opt/  /opt/

# Change to the extracted directory
WORKDIR /bitcoin-$VERSION/

# Copy bitcoin source (downloaded & verified in previous stages)
COPY  --from=preparer /bitcoin-$VERSION/  ./

ENV BITCOIN_PREFIX /opt/bitcoin-$VERSION

RUN ./autogen.sh

# TODO: Try to optimize on passed params
RUN ./configure LDFLAGS=-L/opt/db4/lib/ CPPFLAGS=-I/opt/db4/include/ \
    CXXFLAGS="-O2" \
    --prefix="$BITCOIN_PREFIX" \
    --disable-man \
    --disable-shared \
    --disable-ccache \
    --disable-tests \
    --enable-static \
    --enable-reduce-exports \
    --without-gui \
    --without-libs \
    --with-utils \
    --with-sqlite=yes \
    --with-daemon

RUN make -j$(( $(nproc) + 1 )) check
RUN make install

# List installed binaries pre-strip & strip them
RUN ls -lh "$BITCOIN_PREFIX/bin/"
RUN strip -v "$BITCOIN_PREFIX/bin/bitcoin"*

# List installed binaries post-strip & print their checksums
RUN ls -lh "$BITCOIN_PREFIX/bin/"
RUN sha256sum "$BITCOIN_PREFIX/bin/bitcoin"*



#
## `final` aggregates build results from previous stages into a necessary minimum
#       ready to be used, and published to Docker Hub.
#
# NOTE: this stage is emulated using QEMU
# NOTE: `${ARCH:+${ARCH}/}` - if ARCH is set, append `/` to it, leave it empty otherwise
FROM ${ARCH:+${ARCH}/}alpine:${VER_ALPINE} AS final

ARG VERSION
ARG USER
ARG DIR

LABEL maintainer="Damian Mee (@meeDamian)"

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories

RUN apk add --no-cache \
        boost-filesystem \
        boost-thread \
        libevent \
        libsodium \
        libstdc++ \
        libzmq \
        sqlite-libs

COPY  --from=builder /opt/bitcoin-$VERSION/bin/bitcoin*  /usr/local/bin/

# NOTE: Default GID == UID == 1000
RUN adduser --disabled-password \
            --home "$DIR/" \
            --gecos "" \
            "$USER"

USER $USER

# Prevents `VOLUME $DIR/.bitcoind/` being created as owned by `root`
RUN mkdir -p "$DIR/.bitcoin/"

# Expose volume containing all `bitcoind` data
VOLUME $DIR/.bitcoin/

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
