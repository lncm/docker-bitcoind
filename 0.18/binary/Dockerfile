# Build stage for Bitcoin Core
FROM alpine:3.9 AS bitcoin-core




#RUN apk --no-cache add autoconf
#RUN apk --no-cache add automake
#RUN apk --no-cache add boost-dev
#RUN apk --no-cache add build-base
#RUN apk --no-cache add chrpath
#RUN apk --no-cache add file
RUN apk --no-cache add gnupg
#RUN apk --no-cache add libevent-dev
#RUN apk --no-cache add libressl
#RUN apk --no-cache add libressl-dev
#RUN apk --no-cache add libtool
#RUN apk --no-cache add linux-headers
#RUN apk --no-cache add protobuf-dev
#RUN apk --no-cache add zeromq-dev
RUN set -ex \
  && for key in \
    90C8019E36C2E964 \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

ENV BITCOIN_VERSION=0.18.0

ARG arch
RUN wget https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc
RUN wget https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${arch}-linux-gnu.tar.gz
RUN gpg --verify SHA256SUMS.asc
RUN grep " bitcoin-${BITCOIN_VERSION}.tar.gz\$" SHA256SUMS.asc | sha256sum -c -
RUN tar -xzf *.tar.gz

RUN install -m 0755  -o root  -g root  -t /usr/local/bin  bitcoin-${BITCOIN_VERSION}/bin/*

LABEL maintainer.0="nolim1t (@nolim1t)" \
      maintainer.1="Damian Mee (@meeDamian)"

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
