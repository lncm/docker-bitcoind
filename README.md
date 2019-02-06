# Alpine Dockerfile

## About

This dockerfile is based on [ruimarinho/docker-bitcoin-core](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.17/alpine/Dockerfile) however its made to work for raspberry pi installs, and also has wallet disabled. This also builds on x86_64 environment too.

I've also removed the entrypoint has that has some issues, and replaced it to work without.


## Need a bitcoin config file?

Use one of my [scripts](https://gitlab.com/nolim1t/financial-independence/tree/master/contrib/lightningd-config-generator) or [scripts(1)](https://github.com/lncm/dockerfiles/tree/master/contrib/lightningd-config-generator) which generates a bitcoin.conf and matching lightning conf.


## Invocation

```bash
# Install dependencies (Alpine)
apk add pwgen
apk add curl
apk add bash
apk add python3

# Go to lncm directory (Alpine)
cd /home/lncm

# Generate config
curl "https://gitlab.com/nolim1t/financial-independence/raw/master/contrib/lightningd-config-generator/generate-config.sh" 2>/dev/null | bash

mkdir .bitcoin
mv bitcoin.conf .bicoin
mkdir .lnd
mv lnd.conf .lnd
mkdir .lightning
mv lightningconfig .lightning/config


# Grab image (arm)
docker pull lncm/bitcoind:0.17.0-alpine-arm7

# Grab Image (x86_64 / 0.17.1)
docker pull lncm/bitcoind:0.17.1-alpine-x86_64

# Grab image (arm / 0.17.1)
docker pull lncm/bitcoind:0.17.1-alpine-arm


# Run image (map lncm/.bitcoin to bitcoin/.bitcoin)
docker run -it --rm \
    -v $HOME/.bitcoin:/home/bitcoin/.bitcoin \
    -p 0.0.0.0:8332:8332 \
    -p 0.0.0.0:8333:8333 \
    -p 0.0.0.0:28333:28333 \
    -p 0.0.0.0:28332:28332 \
    --name btcbox \
    -d=true \
    lncm/bitcoind:0.17.1-alpine-arm

```

## Supported platforms

Both x86 and arm are supported with this docker file.
