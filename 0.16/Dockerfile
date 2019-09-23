ARG variant=quick

FROM alpine:3.10 AS bitcoin-core-base

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
COPY --from=meedamian/berkeleydb:db-4.8.30.NC  /opt/  /opt/

# Temporarily change shell to bash, so that arrays can be used
SHELL ["/bin/bash", "-c"]

RUN KEYS=( \
        90C8019E36C2E964 \
    ); \
  (gpg --keyserver pgp.mit.edu --recv-keys ${KEYS[@]}; echo "pgp.mit.edu done") &  \
  sleep 1s; \
  (gpg --keyserver keyserver.pgp.com --recv-keys ${KEYS[@]}; echo "keyserver.pgp.com done") &  \
  (gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${KEYS[@]}; echo "ha.pool.sks-keyservers.net") &  \
  (gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys ${KEYS[@]}; echo "hkp://p80.pool.sks-keyservers.net:80") &  \
  wait -n && \
  gpg --list-keys

# Restore default shell
SHELL ["/bin/sh", "-c"]

ENV BITCOIN_VERSION=0.16.3
ENV BITCOIN_PREFIX=/opt/bitcoin-${BITCOIN_VERSION}

# Download checksums (intentionally different source than source code)
RUN wget "https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc"

# Download source code (intentionally different source than checksums)
RUN wget "https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}.tar.gz"

# Verify that hashes are signed with the previously imported key
RUN gpg --verify SHA256SUMS.asc

# Verify that downloaded source-code archive has exactly the hash that's provided
RUN grep " bitcoin-${BITCOIN_VERSION}.tar.gz\$" SHA256SUMS.asc | sha256sum -c -

# Extract
RUN tar -xzf "bitcoin-${BITCOIN_VERSION}.tar.gz" && \
    rm -f "bitcoin-${BITCOIN_VERSION}.tar.gz"

# Change to the extracted directory
WORKDIR /bitcoin-${BITCOIN_VERSION}

# Disable test that fails on Alpine for unrelated reasons: missing locale.  Not important.
#   https://github.com/bitcoin/bitcoin/issues/14948
#COPY skip-fs-test-of-utf8.patch .
#RUN patch -p0 < skip-fs-test-of-utf8.patch

# ???
RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
# ???
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
# ???
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h

RUN ./autogen.sh

RUN printf "Available proc units: %s\n" "$(nproc)"




FROM bitcoin-core-base AS bitcoin-core-quick

RUN ./configure LDFLAGS=-L/opt/db4/lib/ CPPFLAGS=-I/opt/db4/include/ \
    --prefix=${BITCOIN_PREFIX} \
    --mandir=/usr/share/man \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon \
    --disable-tests \
    --disable-bench
RUN make -j$(nproc)



FROM bitcoin-core-base AS bitcoin-core-checked

RUN ./configure LDFLAGS=-L/opt/db4/lib/ CPPFLAGS=-I/opt/db4/include/ \
    --prefix=${BITCOIN_PREFIX} \
    --mandir=/usr/share/man \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon
RUN make -j$(nproc)
RUN make -j$(nproc) check



FROM bitcoin-core-${variant} AS bitcoin-core

RUN make install

RUN strip ${BITCOIN_PREFIX}/bin/bitcoin-cli
RUN strip ${BITCOIN_PREFIX}/bin/bitcoin-tx
RUN strip ${BITCOIN_PREFIX}/bin/bitcoind
RUN strip ${BITCOIN_PREFIX}/lib/libbitcoinconsensus.a
RUN strip ${BITCOIN_PREFIX}/lib/libbitcoinconsensus.so.0.0.0



# Build stage for compiled artifacts
FROM alpine:3.10 AS final

LABEL maintainer.0="nolim1t (@nolim1t)" \
      maintainer.1="Damian Mee (@meeDamian)"

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories
RUN apk --no-cache \
    add \
    boost \
    boost-program_options \
    libevent \
    libressl \
    libzmq \
    su-exec

ENV BITCOIN_VERSION=0.16.3
ENV BITCOIN_PREFIX=/opt/bitcoin-${BITCOIN_VERSION}
ENV PATH=${BITCOIN_PREFIX}/bin:$PATH

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
CMD ["bitcoind", "-zmqpubrawblock=tcp://0.0.0.0:28332", "-zmqpubrawtx=tcp://0.0.0.0:28333"]
