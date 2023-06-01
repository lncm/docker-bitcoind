# This Dockerfile builds Bitcoin Core and packages it into a minimal `final` image

# VERSION of Bitcoin Core to be build
#   NOTE: Unlike our other images this one is NOT prefixed with `v`,
#           as many things (like download URLs) use this form instead.
ARG VERSION=23.2

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

# Key source of truth
#  https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt"
#  curl "https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt" 2>/dev/null | awk '{print $1}' | tr '\n' ' '

# Bitcoin keys (all)
ENV KEYS 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C 617C90010B3BD370B0AC7D424BB42E31C79111B8 E944AE667CF960B1004BC32FCA662BE18B877A60 152812300785C96444D3334D17565732E08E5E41 590B7292695AFFA5B672CBB2E13FC145CD3F4304 0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 912FD3228387123DC97E0E57D5566241A0295FA9 04017A2A6D9A0CCDC81D8EC296AB007F1A7ED999 C519EBCF3B926298946783EFF6430754120EC2F4 18AE2F798E0D239755DA4FD24B79F986CBDF8736 101598DC823C1B5F9A6624ABA5E0907A0380E6C3 F20F56EF6A067F70E8A5C99FFF95FAA971697405 C060A6635913D98A3587D7DB1C2491FFEB0EF770 BF6273FAEF7CC0BA1F562E50989F6B3048A116B5 6D3170C1DC2C6FD0AEEBCA6743811D1A26623924 948444FCE03B05BA5AB0591EC37B1C1D44C786EE 1C6621605EC50319C463D56C7F81D87985D61612 9A1689B60D1B3CCE9262307A2F40A9BF167FBA47 D35176BE9264832E4ACA8986BF0792FBE95DC863 6F993B250557E7B016ADE5713BDCDA2D87A881D9 01CDF4627A3B88AAE4A571C87588242FBE38D3A8 D1DBF2C4B96F2DEBF4C16654410108112E7EA81F A2FD494D0021AA9B4FA58F759102B7AE654A4A5A 2688F5A9A4BE0F295E921E8A25F27A38A47AD566 D3F22A3A4C366C2DCB66D3722DA9C5A7FA81EA35 7480909378D544EA6B6DCEB7535B12980BB8A4D3 D3CC177286005BB8FF673294C5242A1AB3936517 82921A4B88FD454B7EB8CE3C796C4109063D4EAF 32EE5C4C3FA15CCADB46ABE529D4BCB6416F53EC 4B4E840451149DD7FB0D633477DFAB5C3108B9A8 C42AFF7C61B3E44A1454CD3557AF762DB3353322 70A1D47DD44F59DF8B22244333E472FE870C7E5D 30DE693AE0DE9E37B3E7EB6BBFF0F67810C1EED1 E463A93F5F3117EEDE6C7316BD02942421F4889F B8B3F1C0E58C15DB6A81D30C3648A882F4316B9B 07DF3E57A548CCFB7530709189BBB8663E2E65CE CA03882CB1FC067B5D3ACFE4D300116E1C875A3D E777299FC265DD04793070EB944D35F9AC3DB76A AD5764F4ADCE1B99BDFD179E12335A271D4D62EC 9692B91BBF0E8D34DFD33B1882C5C009628ECF0C C57E4B42223FDE851D4F69DD28DF2724F241D8EE F4FC70F07310028424EFC20A8E4256593F177720 D62A803E27E7F43486035ADBBCD04D8E9CCCAC2A 37EC7D7B0A217CDB4B4E007E7FAB114267E4FA04 D762373D24904A3E42F33B08B9A408E71DAAC974 133EAC179436F14A5CF1B794860FEB804E669320 6A8F9C266528E25AEB1D7731C2371D91CB716EA7 A8FC55F3B04BA3146F3492E79303B33A305224CB ED9BDF7AD6A55E232E84524257FF9BDBCC301009 867345026B6763E8B07EE73AB6737117397F5C4F 9EDAFF80E080659604F4A76B2EBB056FD847F8A7 6DEEF79B050C4072509B743F8C275BC595448867 AEC1884398647C47413C1C3FB1179EB7347DC10D 74E2DEF5D77260B98BC19438099BAD163C70FBFA 79D00BAC68B56D422F945A8F8E3A8F3247DBCBBF 71A3B16735405025D447E8F274810B012346C9A6 C388F6961FB972A95678E327F62711DBDCA8AE56 F9A8737BF4FF5C89C903DF31DD78544CF91B1514 287AE4CA1187C68C08B49CB2D11BD4F33F1DB499 6B002C6EA3F91B1B0DF0C9BC8F617F1200A6D25C
# keys to fetch from ubuntu keyserver
ENV KEYS1 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C 617C90010B3BD370B0AC7D424BB42E31C79111B8 E944AE667CF960B1004BC32FCA662BE18B877A60 912FD3228387123DC97E0E57D5566241A0295FA9 C519EBCF3B926298946783EFF6430754120EC2F4 18AE2F798E0D239755DA4FD24B79F986CBDF8736 101598DC823C1B5F9A6624ABA5E0907A0380E6C3 F20F56EF6A067F70E8A5C99FFF95FAA971697405 C060A6635913D98A3587D7DB1C2491FFEB0EF770 BF6273FAEF7CC0BA1F562E50989F6B3048A116B5 6D3170C1DC2C6FD0AEEBCA6743811D1A26623924 948444FCE03B05BA5AB0591EC37B1C1D44C786EE 1C6621605EC50319C463D56C7F81D87985D61612 9A1689B60D1B3CCE9262307A2F40A9BF167FBA47 D35176BE9264832E4ACA8986BF0792FBE95DC863 6F993B250557E7B016ADE5713BDCDA2D87A881D9 01CDF4627A3B88AAE4A571C87588242FBE38D3A8 A2FD494D0021AA9B4FA58F759102B7AE654A4A5A D3F22A3A4C366C2DCB66D3722DA9C5A7FA81EA35 D3CC177286005BB8FF673294C5242A1AB3936517 4B4E840451149DD7FB0D633477DFAB5C3108B9A8 70A1D47DD44F59DF8B22244333E472FE870C7E5D 30DE693AE0DE9E37B3E7EB6BBFF0F67810C1EED1 07DF3E57A548CCFB7530709189BBB8663E2E65CE 9692B91BBF0E8D34DFD33B1882C5C009628ECF0C C57E4B42223FDE851D4F69DD28DF2724F241D8EE D62A803E27E7F43486035ADBBCD04D8E9CCCAC2A D762373D24904A3E42F33B08B9A408E71DAAC974 6A8F9C266528E25AEB1D7731C2371D91CB716EA7 A8FC55F3B04BA3146F3492E79303B33A305224CB 6DEEF79B050C4072509B743F8C275BC595448867 AEC1884398647C47413C1C3FB1179EB7347DC10D 79D00BAC68B56D422F945A8F8E3A8F3247DBCBBF C388F6961FB972A95678E327F62711DBDCA8AE56 F9A8737BF4FF5C89C903DF31DD78544CF91B1514 287AE4CA1187C68C08B49CB2D11BD4F33F1DB499
# keys to fetch from keys.openpgp.org
ENV KEYS2 04017A2A6D9A0CCDC81D8EC296AB007F1A7ED999 152812300785C96444D3334D17565732E08E5E41 590B7292695AFFA5B672CBB2E13FC145CD3F4304 0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 F4FC70F07310028424EFC20A8E4256593F177720 CA03882CB1FC067B5D3ACFE4D300116E1C875A3D E777299FC265DD04793070EB944D35F9AC3DB76A AD5764F4ADCE1B99BDFD179E12335A271D4D62EC E463A93F5F3117EEDE6C7316BD02942421F4889F B8B3F1C0E58C15DB6A81D30C3648A882F4316B9B C42AFF7C61B3E44A1454CD3557AF762DB3353322 82921A4B88FD454B7EB8CE3C796C4109063D4EAF 32EE5C4C3FA15CCADB46ABE529D4BCB6416F53EC 7480909378D544EA6B6DCEB7535B12980BB8A4D3 2688F5A9A4BE0F295E921E8A25F27A38A47AD566 D1DBF2C4B96F2DEBF4C16654410108112E7EA81F 71A3B16735405025D447E8F274810B012346C9A6 74E2DEF5D77260B98BC19438099BAD163C70FBFA 867345026B6763E8B07EE73AB6737117397F5C4F 9EDAFF80E080659604F4A76B2EBB056FD847F8A7 ED9BDF7AD6A55E232E84524257FF9BDBCC301009 133EAC179436F14A5CF1B794860FEB804E669320 37EC7D7B0A217CDB4B4E007E7FAB114267E4FA04 6B002C6EA3F91B1B0DF0C9BC8F617F1200A6D25C
RUN gpg --keyserver keyserver.ubuntu.com  --recv-keys $KEYS1
RUN gpg --keyserver keyserver.ubuntu.com --refresh-keys

RUN gpg --keyserver keyserver.ubuntu.com  --recv-keys $KEYS2
RUN gpg --keyserver keyserver.ubuntu.com  --refresh-keys

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
#RUN gpg --verify SHA256SUMS.asc SHA256SUMS

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
