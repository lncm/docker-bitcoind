# This Dockerfile builds Bitcoin Core and packages it into a minimal `final` image

# VERSION of Bitcoin Core to be build
#   NOTE: Unlike our other images this one is NOT prefixed with `v`,
#           as many things (like download URLs) use this form instead.
ARG VERSION=22.1

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

# Bitcoin keys (all)
ENV KEYS 71A3B16735405025D447E8F274810B012346C9A6 01EA5486DE18A882D4C2684590C8019E36C2E964 0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D 152812300785C96444D3334D17565732E08E5E41 0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 590B7292695AFFA5B672CBB2E13FC145CD3F4304 28F5900B1BB5D1A4B6B6D1A9ED357015286A333D CFB16E21C950F67FA95E558F2EEB9F5CC09526C1 6E01EEC9656903B0542B8F1003DB6322267C373B D1DBF2C4B96F2DEBF4C16654410108112E7EA81F 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C 74E2DEF5D77260B98BC19438099BAD163C70FBFA 637DB1E23370F84AFF88CCE03152347D07DA627C 82921A4B88FD454B7EB8CE3C796C4109063D4EAF
# keys to fetch from ubuntu keyserver
ENV KEYS1 71A3B16735405025D447E8F274810B012346C9A6 01EA5486DE18A882D4C2684590C8019E36C2E964 0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D 152812300785C96444D3334D17565732E08E5E41 0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 590B7292695AFFA5B672CBB2E13FC145CD3F4304 28F5900B1BB5D1A4B6B6D1A9ED357015286A333D CFB16E21C950F67FA95E558F2EEB9F5CC09526C1 6E01EEC9656903B0542B8F1003DB6322267C373B D1DBF2C4B96F2DEBF4C16654410108112E7EA81F 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C 74E2DEF5D77260B98BC19438099BAD163C70FBFA
# keys to fetch from keys.openpgp.org
ENV KEYS2 637DB1E23370F84AFF88CCE03152347D07DA627C 82921A4B88FD454B7EB8CE3C796C4109063D4EAF

# Run twop different keys command
RUN timeout 32s gpg  --keyserver keyserver.ubuntu.com  --recv-keys $KEYS1
RUN timeout 32s gpg  --keyserver keys.openpgp.org  --recv-keys $KEYS2

# Print imported keys, but also ensure there's no other keys in the system
RUN gpg --list-keys | tail -n +3 | tee /tmp/keys.txt && \
    gpg --list-keys $KEYS | diff - /tmp/keys.txt



#
## Option #1: [default] Fetch bitcoind source from release tarballs
#
FROM preparer-base AS preparer-release

ARG VERSION

# Download sigs
ADD https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc  ./
# Download checksums
ADD https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS  ./

# Download source code (intentionally different website than checksums)
# uncomment
#ADD https://bitcoin.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz ./
ADD https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz ./

# Verify that hashes are signed with the previously imported key
RUN gpg --verify SHA256SUMS.asc SHA256SUMS

# Verify that downloaded source-code archive matches exactly the hash that's provided
RUN grep " bitcoin-$VERSION.tar.gz\$" SHA256SUMS | sha256sum -c -

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
