# This Dockerfile builds Bitcoin Core and packages it into a minimal `final` image

# VERSION of Bitcoin Core to be build
#   NOTE: Unlike our other images this one is NOT prefixed with `v`,
#           as many things (like download URLs) use this form instead.
ARG VERSION=0.16.3

# CPU archtecture to build binaries for
ARG ARCH

# Define default versions so that they don't have to be repreated throughout the file
ARG VER_ALPINE=3.11


FROM alpine:${VER_ALPINE} AS builder

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

ENV KEYS 01EA5486DE18A882D4C2684590C8019E36C2E964

# Try to fetch key from keyservers listed below.  On first success terminate with `exit 0`.  If loop is not interrupted,
#   it means all attempts failed, and `exit 1` is called.
RUN for srv in hkp://p80.pool.sks-keyservers.net:80  ha.pool.sks-keyservers.net  keyserver.pgp.com  pgp.mit.edu; do \
        timeout 9s  gpg  --keyserver "$srv"  --recv-keys $KEYS  >/dev/null 2<&1 && \
            { echo "OK:  $srv" && exit 0; } || \
            { echo "ERR: $srv fail=$?"; } ; \
    done && exit 1

RUN gpg --list-keys

ARG VERSION

RUN echo "Building Bitcoin version: $VERSION"

# Download checksums
RUN wget "https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc"

# Download source code (intentionally different website than checksums)
RUN wget "https://bitcoin.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz"

# Verify that hashes are signed with the previously imported key
RUN gpg --verify SHA256SUMS.asc

# Verify that downloaded source-code archive has exactly the hash that's provided
RUN grep " bitcoin-$VERSION.tar.gz\$" SHA256SUMS.asc | sha256sum -c -

# Extract
RUN tar -xzf "bitcoin-$VERSION.tar.gz" && \
    rm -f "bitcoin-$VERSION.tar.gz"

# Change to the extracted directory
WORKDIR /bitcoin-$VERSION

# NOTE: no idea what these do, but they seem necessary
#   taken from: https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.16/alpine/Dockerfile#L67-L69
RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h

ENV BITCOIN_PREFIX="/opt/bitcoin-$VERSION"

RUN ./autogen.sh
RUN ./configure LDFLAGS=-L/opt/db4/lib/ CPPFLAGS=-I/opt/db4/include/ \
    --prefix="$BITCOIN_PREFIX" \
    --mandir=/usr/share/man \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon

RUN make -j $(( $(nproc) + 1 )) check
RUN make install

# Already taken advantage of before by `make check`.  No need to have them installed, as they're very big (~500 MB).
#RUN rm "$BITCOIN_PREFIX/bin/bench_bitcoin"  "$BITCOIN_PREFIX/bin/test_bitcoin"

# List installed libs, and binaries pre-strip
RUN ls -lh "$BITCOIN_PREFIX/bin/"

RUN strip "$BITCOIN_PREFIX/bin/bitcoin"*

#RUN strip "$BITCOIN_PREFIX/bin/bitcoin-cli"
#RUN strip "$BITCOIN_PREFIX/bin/bitcoin-tx"
#RUN strip "$BITCOIN_PREFIX/bin/bitcoind"
#RUN strip "$BITCOIN_PREFIX/lib/libbitcoinconsensus.a"
#RUN strip "$BITCOIN_PREFIX/lib/libbitcoinconsensus.so.0.0.0"

# List installed libs, and binaries after stripping
RUN ls -lh "$BITCOIN_PREFIX/bin/"

# Print sha256 hashes of final binaries
RUN find -L "$BITCOIN_PREFIX/"  -type f  -exec sha256sum {} \; | sort -t ' ' -k 2



# Build stage for compiled artifacts
FROM alpine:${VER_ALPINE} AS final

LABEL maintainer="Damian Mee (@meeDamian)"

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories
RUN apk add --no-cache \
    boost \
    boost-program_options \
    libevent \
    libressl \
    libzmq \
    su-exec

ARG VERSION

COPY  --from=builder "/opt/bitcoin-$VERSION/bin/"  /usr/local/bin/

VOLUME /root/.bitcoin

COPY --from=bitcoin-core /opt /opt

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
