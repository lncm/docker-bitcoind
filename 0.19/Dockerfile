ARG SOURCE=release

FROM alpine:3.10 AS bitcoin-base

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories && \
    apk add --no-cache \
        autoconf \
        automake \
        boost-dev \
        build-base \
        chrpath \
        file \
        gnupg \
        libevent-dev \
        libressl \
        libressl-dev \
        libtool \
        linux-headers \
        protobuf-dev \
        zeromq-dev

# Fetch already built berkeleydb
COPY --from=lncm/berkeleydb:db-4.8.30.NC  /opt/  /opt/

ENV KEYS 71A3B16735405025D447E8F274810B012346C9A6 01EA5486DE18A882D4C2684590C8019E36C2E964

# Try to fetch keys from keyservers listed below.  On first success terminate with `exit 0`.  If loop is not interrupted,
#   it means all attempts failed, and `exit 1` is called.
RUN for SRV in keyserver.ubuntu.com  hkp://p80.pool.sks-keyservers.net:80  ha.pool.sks-keyservers.net  keyserver.pgp.com  pgp.mit.edu; do \
        timeout 9s  gpg  --keyserver "${SRV}"  --recv-keys ${KEYS}  >/dev/null 2<&1 && \
            { echo "OK:  ${SRV}" && exit 0; } || \
            { echo "ERR: ${SRV} fail=$?"; } ; \
    done && exit 1

RUN gpg --list-keys && \
    gpg --list-key ${KEYS}



# Fetch bitcoind from release tarballs
#
FROM bitcoin-base AS from-release

ARG VERSION=0.19.0.1
ENV BITCOIN_VERSION=${VERSION}
RUN echo "Building Bitcoin version (from release): ${BITCOIN_VERSION}"

# Download checksums
RUN wget "https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc"

# Download source code (intentionally different website than checksums)
RUN wget "https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}.tar.gz"

# Verify that hashes are signed with the previously imported key
RUN gpg --verify SHA256SUMS.asc

# Verify that downloaded source-code archive has exactly the hash that's provided
RUN grep " bitcoin-${BITCOIN_VERSION}.tar.gz\$" SHA256SUMS.asc | sha256sum -c -

# Extract
RUN tar -xzf "bitcoin-${BITCOIN_VERSION}.tar.gz" && \
    rm -f "bitcoin-${BITCOIN_VERSION}.tar.gz"



# Fetch bitcoind from Github repository
#
FROM bitcoin-base AS from-git

RUN apk add git

ARG VERSION=0.19.0.1
ENV BITCOIN_VERSION=${VERSION}
RUN echo "Building Bitcoin version (from git): ${BITCOIN_VERSION}"

# Fetch the source code at a specific TAG
RUN git clone  -b "v${VERSION}"  --depth=1  https://github.com/bitcoin/bitcoin.git

# Verify tag, and copy source code to predetermined location on success
RUN (cd bitcoin && git verify-tag "v${VERSION}") && \
    mv bitcoin/  /bitcoin-${BITCOIN_VERSION}



# Build bitcoind (regardless on how the source code was obtained)
#
FROM from-${SOURCE} AS bitcoin-core

# Change to the extracted directory
WORKDIR /bitcoin-${BITCOIN_VERSION}

# ???
RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
# ???
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
# ???
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h

ENV BITCOIN_PREFIX="/opt/bitcoin-${BITCOIN_VERSION}"

RUN ./autogen.sh
RUN ./configure LDFLAGS=-L/opt/db4/lib/ CPPFLAGS=-I/opt/db4/include/ \
    --prefix="${BITCOIN_PREFIX}" \
    --mandir=/usr/share/man \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon

RUN make -j$(($(nproc) + 1)) check
RUN make install

# Already taken advantage of before by `make check`.  No need to have them installed, as they're very big (~500 MB).
RUN rm ${BITCOIN_PREFIX}/bin/bench_bitcoin  ${BITCOIN_PREFIX}/bin/test_bitcoin

# List installed libs, and binaries pre-strip
RUN ls -lh ${BITCOIN_PREFIX}/bin/  ${BITCOIN_PREFIX}/lib/

RUN strip ${BITCOIN_PREFIX}/bin/bitcoin-cli
RUN strip ${BITCOIN_PREFIX}/bin/bitcoin-tx
RUN strip ${BITCOIN_PREFIX}/bin/bitcoin-wallet
RUN strip ${BITCOIN_PREFIX}/bin/bitcoind
RUN strip ${BITCOIN_PREFIX}/lib/libbitcoinconsensus.a
RUN strip ${BITCOIN_PREFIX}/lib/libbitcoinconsensus.so.0.0.0

# List installed libs, and binaries after stripping
RUN ls -lh ${BITCOIN_PREFIX}/bin/  ${BITCOIN_PREFIX}/lib/

# Print sha256 hashes of final binaries
RUN find -L ${BITCOIN_PREFIX}/  -type f  -exec sha256sum {} \; | sort -t ' ' -k 2



# Build stage for compiled artifacts
FROM alpine:3.10 AS final

LABEL maintainer="Damian Mee (@meeDamian)"

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories && \
    apk add --no-cache libressl libstdc++ boost-thread boost-chrono boost-filesystem libevent libsodium libzmq

ARG VERSION=0.19.0.1
ENV BITCOIN_VERSION=${VERSION}

ENV BITCOIN_PREFIX="/opt/bitcoin-${BITCOIN_VERSION}"

VOLUME /root/.bitcoin

COPY --from=bitcoin-core "${BITCOIN_PREFIX}/bin/" /usr/local/bin/

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
