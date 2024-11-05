# This Dockerfile builds Bitcoin Core and packages it into a minimal `final` image

# VERSION of Bitcoin Core to be build
#   NOTE: Unlike our other images this one is NOT prefixed with `v`,
#           as many things (like download URLs) use this form instead.
ARG VERSION=27.2

# CPU architecture to build binaries for
ARG ARCH

# Define default versions so that they don't have to be repeated throughout the file
ARG VER_ALPINE=3.20

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

RUN apk add --no-cache gnupg

# Guix Builder Keys: https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
# curl -s "https://api.github.com/repos/bitcoin-core/guix.sigs/contents/builder-keys" | jq -r '.[].download_url'
ENV KEYS 982A193E3CE0EED535E09023188CBB2648416AD5 \
    0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D \
    8D8F44B041CC745A8066356ACB498A7685A3203C \
    1A6B4BBC2051B1BFC3F0791EA096238A5DA7EF4C \
    101598DC823C1B5F9A6624ABA5E0907A0380E6C3 \
    A9206D4BD08A30A143638C0E8B96345BBE7DED9B \
    9EDAFF80E080659604F4A76B2EBB056FD847F8A7 \
    637DB1E23370F84AFF88CCE03152347D07DA627C \
    28EB13F9FD58CE86EAAB091470596D7FF6B55417 \
    344219055D59453CD50531CD918A89D210E96167 \
    ED9BDF7AD6A55E232E84524257FF9BDBCC301009 \
    A45E76B5A378425DA632394D498A18F9F6BB9174 \
    A8FC55F3B04BA3146F3492E79303B33A305224CB \
    F2CFC4ABD0B99D837EEBB7D09B79B45691DB4173 \
    0E995DC8033FC9AAD72FDE75DAB71C6FBCD75257 \
    204A972AEA7378C6A07466EA7651CCCB55BC4D56 \
    152812300785C96444D3334D17565732E08E5E41 \
    775F1492D89554798BD56C5ADB88DB0BD2EDFBFC \
    0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 \
    1DECC0766F51B043631DBC10DA8AD98074B460CF \
    C060A6635913D98A3587D7DB1C2491FFEB0EF770 \
    FEF325F44FDAAD6683C539D9BBA4F02DB4D99E1B \
    590B7292695AFFA5B672CBB2E13FC145CD3F4304 \
    1379CCD299E669C69E123F67544918F147B456C8 \
    6F9EFB2418B22D9ADC1644082E2755CCCB9A664C \
    41E442A14C342C877AE4DC8F3B6305FA06DE51D5 \
    73D29D1549135479C20B6F28640997BD69CA9269 \
    948444FCE03B05BA5AB0591EC37B1C1D44C786EE \
    28F5900B1BB5D1A4B6B6D1A9ED357015286A333D \
    722F9A1F3799224545C6CB90A0455D5134A863A6 \
    0E2A0B287346F54827B31D7354EFB3298283B289 \
    E777299FC265DD04793070EB944D35F9AC3DB76A \
    CFB16E21C950F67FA95E558F2EEB9F5CC09526C1 \
    6B002C6EA3F91B1B0DF0C9BC8F617F1200A6D25C \
    ED34FD4058F41840A165D65EA7B1C35A8424C4E5 \
    F19F5FF2B0589EC341220045BA03F4DBE0C63FB4 \
    D32EDBC31403E064D202B631F516F495EBEBFDCD \
    F4FC70F07310028424EFC20A8E4256593F177720 \
    F3FDEEDE46A8A2EC139098ED5E50C90D766DB9FC \
    0B7507D8139F9DB3587053BA6376F16B3C9F08CC \
    6E01EEC9656903B0542B8F1003DB6322267C373B \
    2C7185B3E7454C06D76635694F50789ED785C6D4 \
    A1A8B25E6185BB18DBAFA60D5F227E08FA339C20 \
    973730D55793F2DEF00B60DA63B65BEF7899D597 \
    C25F3295638298E3AFEBE70B48F5EB2E7E59AF8C \
    B14D3C5CA570F03C911E04A6F0A0ED07755FDBCF \
    E6DF8502529F86B491C65E1E988BB7626335E3FB \
    FDE04B7075113BFB085020B57BBD8D4D95DB9F03 \
    D1DBF2C4B96F2DEBF4C16654410108112E7EA81F \
    CBE89ED88EE8525FD8D79F1EDB56ADFD8B5EF498 \
    287AE4CA1187C68C08B49CB2D11BD4F33F1DB499 \
    4FD6BAE4CAB7261734558654F3BD809A19B82259 \
    616516B8EB6ED02882FC4A7A8ADCB558C4F33D65 \
    5C9C707EB7D6FCB75BA1225F6A671EE7D00D38C3 \
    C388F6961FB972A95678E327F62711DBDCA8AE56 \
    49DAC1BDFBEB6B26B794904EC08D36845BA9A59F \
    71A3B16735405025D447E8F274810B012346C9A6 \
    9DEAE0DC7063249FB05474681E4AED62986CD25D \
    53D974DA0BAFFF22B3A5FB5C69B4C4CDC628F8F9 \
    D01B5D68015444D271DAD33FF69705ED890DE427 \
    1A3E761F19D2CC7785C5502EA291A2C45D0C504A \
    DB79C612764A580E4BB71BB82B50B0C9E93DB62F \
    E86AE73439625BBEE306AAE6B66D427F873CB1A3 \
    45741E495E214C428E8FFF58AC742749DC4965AB \
    E61773CD6E01040E2F1BD78CE7E2984B6289C93A \
    CBDB447184AC2CA7A121A27907052EE640FEAC22 \
    2F78ACF677029767C8736F13747A7AE2FB0FD25B \
    E58DC1C0A44E0D8E6397D442A54BAA02E69D78D6 \
    133EAC179436F14A5CF1B794860FEB804E669320 \
    3F1888C6DCA92A6499C4911FDBA1A67379A1A931 \
    5ADAB999CE5240DD68F9A079A5210C1621239EFB \
    AF9167ECC5FB492B9841E276BD991B3EC4EB3A28 \
    9199E2D71F37DC34BD2337C988AF5B9A92EC92CD \
    AC6626172E00A82CFFAE8972A636E97631F767E0 \
    02E82CC36166CAA5F6E623EFB224E825176C0F32 \
    3EB0DEE6004A13BE5A0CC758BF2978B068054311 \
    9ED99C7A355AE46098103E74476E74C8529A9006 \
    0164F03C54C2176A14D1997DFF5C9E3F8ACAF77A \
    670BC460DC8BF5EEF1C3BC74B14CC9F833238F85 \
    6A8F9C266528E25AEB1D7731C2371D91CB716EA7 \
    9343A22960A50972CC1EFD7DB3B5CB8DB648B27F \
    28E72909F1717FE9607754F8A7BEB2621678D37D \
    032703671E4ACE58DB7FA2D3BBE369B6789ADBDB \
    67AA5B46E7AF78053167FE343B8F814A784218F8 \
    D6D11C357A614D40803ABDC4105F2EA76D0102CA \
    6EEEF78796B8B5409719A2A36D498CBADF3906B8 \
    A0083660F235A27000CD3C81CE6EC49945C17EA6 \
    79D00BAC68B56D422F945A8F8E3A8F3247DBCBBF \
    B9069CB5D5FB01A66D69E01BC990468AFE0F55CD \
    8EA063F7D5E6E17ADE409BDC605192A3FE984A60

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys $KEYS

#
## Option #1: [default] Fetch bitcoind source from release tarballs
#
FROM preparer-base AS preparer-release

ARG VERSION

# Download sigs
ADD https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc ./
# Download checksums
ADD https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS ./

# Download source code from same website as github is probably deterministicly built
ADD https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz ./bitcoin-$VERSION.tar.gz

# Verify that hashes are signed with the previously imported key
RUN gpg --verify SHA256SUMS.asc SHA256SUMS

# Verify that downloaded source-code archive matches exactly the hash that's provided
RUN grep "bitcoin-$VERSION.tar.gz" SHA256SUMS | sha256sum -c

# Extract
RUN tar -xzf "bitcoin-$VERSION.tar.gz" && \
    rm -f "bitcoin-$VERSION.tar.gz"

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
    --disable-bench \
    --enable-static \
    --enable-reduce-exports \
    --enable-fuzz-binary=no \
    --without-gui \
    --without-libs \
    --with-utils \
    --with-sqlite=yes \
    --with-daemon

RUN make -j$(( $(nproc) + 1 ))
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

RUN apk add --no-cache \
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
