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

RUN apk add --no-cache gnupg

# Guix Builder Keys: https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
# curl -s "https://api.github.com/repos/bitcoin-core/guix.sigs/contents/builder-keys" | jq -r '.[].download_url'
ENV KEYS 982A193E3CE0EED535E09023188CBB2648416AD5 101598DC823C1B5F9A6624ABA5E0907A0380E6C3 9EDAFF80E080659604F4A76B2EBB056FD847F8A7 \
         ED9BDF7AD6A55E232E84524257FF9BDBCC301009 A8FC55F3B04BA3146F3492E79303B33A305224CB 152812300785C96444D3334D17565732E08E5E41 \
         0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 C060A6635913D98A3587D7DB1C2491FFEB0EF770 590B7292695AFFA5B672CBB2E13FC145CD3F4304 \
         948444FCE03B05BA5AB0591EC37B1C1D44C786EE E777299FC265DD04793070EB944D35F9AC3DB76A 6B002C6EA3F91B1B0DF0C9BC8F617F1200A6D25C \
         F4FC70F07310028424EFC20A8E4256593F177720 D1DBF2C4B96F2DEBF4C16654410108112E7EA81F 287AE4CA1187C68C08B49CB2D11BD4F33F1DB499 \
         616516B8EB6ED02882FC4A7A8ADCB558C4F33D65 71A3B16735405025D447E8F274810B012346C9A6 2F78ACF677029767C8736F13747A7AE2FB0FD25B \
         133EAC179436F14A5CF1B794860FEB804E669320 9ED99C7A355AE46098103E74476E74C8529A9006 6A8F9C266528E25AEB1D7731C2371D91CB716EA7 \
         28E72909F1717FE9607754F8A7BEB2621678D37D 67AA5B46E7AF78053167FE343B8F814A784218F8 79D00BAC68B56D422F945A8F8E3A8F3247DBCBBF

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys $KEYS

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
