lncm/bitcoind
=============

[![Build Status]][builds]
[![gh_last_release_svg]][gh_last_release_url]
[![Docker Image Size]][lnd-docker-hub]
[![Docker Pulls Count]][lnd-docker-hub]

[Build Status]: https://github.com/lncm/docker-bitcoind/workflows/Build%20&%20deploy%20on%20git%20tag%20push/badge.svg
[builds]: https://github.com/lncm/docker-bitcoind/actions?query=workflow%3A%22Build+%26+deploy+on+git+tag+push%22

[gh_last_release_svg]: https://img.shields.io/github/v/release/lncm/docker-bitcoind?sort=semver
[gh_last_release_url]: https://github.com/lncm/docker-bitcoind/releases/latest

[Docker Image Size]: https://img.shields.io/microbadger/image-size/lncm/bitcoind.svg
[Docker Pulls Count]: https://img.shields.io/docker/pulls/lncm/bitcoind.svg?style=flat
[lnd-docker-hub]: https://hub.docker.com/r/lncm/bitcoind


This repo builds [`bitcoind`] in an [auditable way](https://github.com/lncm/docker-bitcoind), and packages it into a minimal Docker containers provided for various CPU architectures.

[`bitcoind`]: https://github.com/bitcoin/bitcoin


> The work here was initially based on [ruimarinho/docker-bitcoin-core](https://github.com/ruimarinho/docker-bitcoin-core/), but has significantly diverged since.


#### Details

* **All [`git-tags`]** <small>(and most commits)</small> **are signed** by `D8CA1776EB9265491D07CE67F546ECBEA809CB18`
* **All [`git-tags`]** <small>(and most commits)</small> **are [`opentimestamps`]-ed**
* **All builds aim to be maximally auditable.**  After `git tag push`, the entire process is automated, with each step printed, and the code aiming to be easy to follow
* All builds are based on [Alpine]
* Cross-compiled builds are done using our (also auditable) [`qemu`]
* To fit build and complete `make check` test suite, BerkeleyDB is build separately [here]
* Each build produces binaries for: `amd64`, `arm64v8`, and `arm32v7`
* All architectures are aggregated under an easy-to-use [Docker Manifest]
* All [`git-tags`] are [build automatically], and with an [auditable trace]
* Each successful build of a `git tag` pushes result Docker image to [Docker Hub]
* Images pushed to Docker Hub are never deleted (even if `lnd` version gets overridden, previous one is preserved)
* All `final` images are based on Alpine for minimum base size
* All binaries are [`strip`ped]
* Each `git-tag` build is tagged with a unique tag number
* Each _minor_ version is stored in a separate directory (for the ease of backporting patches)


[`git-tags`]: https://github.com/lncm/docker-lnd/tags
[`opentimestamps`]: https://github.com/opentimestamps/opentimestamps-client/blob/master/doc/git-integration.md#usage
[Alpine]: https://github.com/lncm/docker-bitcoind/blob/6beae356ba16ee0297427c6401cd34f93044e256/0.19/Dockerfile#L11-L12
[`qemu`]: https://github.com/meeDamian/simple-qemu
[here]: https://github.com/lncm/docker-berkeleydb
[Docker Manifest]: https://github.com/lncm/docker-bitcoind/blob/6beae356ba16ee0297427c6401cd34f93044e256/.github/workflows/on-tag.yml#L177-L193
[build automatically]: https://github.com/lncm/docker-bitcoind/blob/6beae356ba16ee0297427c6401cd34f93044e256/.github/workflows/on-tag.yml
[auditable trace]: https://github.com/lncm/docker-bitcoind/runs/507498587?check_suite_focus=true
[Docker Hub]: https://github.com/lncm/docker-bitcoind/blob/6beae356ba16ee0297427c6401cd34f93044e256/.github/workflows/on-tag.yml#L167-L193
[Github Releases]: https://github.com/lncm/docker-bitcoind/blob/6beae356ba16ee0297427c6401cd34f93044e256/.github/workflows/on-tag.yml#L196-L203
[`strip`ped]: https://github.com/lncm/docker-bitcoind/blob/6beae356ba16ee0297427c6401cd34f93044e256/0.19/Dockerfile#L176


> **NOTE:** ZMQ `block` and `tx` ports are set to `28332` and `28333` respectively. 


## Tags

> **NOTE:** For an always up-to-date list see: https://hub.docker.com/r/lncm/bitcoind/tags

* `v26.0`
* `v25.1`
* `v25.0`
* `v24.0.1`
* `v23.0`
* `v22.0`
* `v0.21.1`
* `v0.21.0`
* `v0.20.0`
* `v0.19.1`
* `v0.19.0.1`
* `v0.18.1`
* `v0.17.2`
* `v0.16.3`
* `v0.15.2`


## Usage

### Pull

First pull the image from [Docker Hub]:

```bash
docker pull lncm/bitcoind:v25.0
```

> **NOTE:** Running above will automatically choose native architecture of your CPU.

[Docker Hub]: https://hub.docker.com/r/lncm/bitcoind

Or, to pull a specific CPU architecture:

```bash
docker pull lncm/bitcoind:v25.0-arm64v8
```

#### Start

First of all, create a directory in your home directory called `.bitcoin`

Next, create a config file. You can take a look at the following sample: thebox-compose-system ([1](https://github.com/lncm/thebox-compose-system/blob/master/bitcoin/bitcoin.conf)).

Some guides on how to configure bitcoin can be found [here](https://github.com/bitcoin/bitcoin/blob/master/doc/bitcoin-conf.md) (bitcoin git repo)

Then to start bitcoind, run:

```bash
docker run  -it  --rm  --detach \
    -v ~/.bitcoin:/data/.bitcoin \
    -p 8332:8332 \
    -p 8333:8333 \
    -p 28332:28332 \
    -p 28333:28333 \
    --name bitcoind \
    lncm/bitcoind:v25.0
```

That will run bitcoind such that:

* all data generated by the container is stored in `~/.bitcoin` **on your host machine**,
* port `8332` will be reachable for the RPC communication,
* port `8333` will be reachable for the peer-to-peer communication,
* port `28332` will be reachable for ZMQ **block** notifications,
* port `28333` will be reachable for ZMQ **transaction** notifications,
* created container will get named `bitcoind`,
* within the container, `bitcoind` binary is run as unprivileged user `bitcoind` (`UID=1000`),
* that command will run the container in the background and print the ID of the container being run.


#### Interact

To issue any commands to a running container, do:

```bash
docker exec -it bitcoind BINARY COMMAND
```

Where:
* `BINARY` is either `bitcoind`, `bitcoin-cli`, `bitcoin-tx`, (or `bitcoin-wallet` on `v0.18+`) and
* `COMMAND` is something you'd normally pass to the binary   

Examples:

```bash
docker exec -it bitcoind bitcoind --help
docker exec -it bitcoind bitcoind --version
docker exec -it bitcoind bitcoin-cli --help
docker exec -it bitcoind bitcoin-cli -getinfo
docker exec -it bitcoind bitcoin-cli getblockcount
```

### Docker Compose
Here is a docker-compose.yml for mainnet
```yaml
version: '3'
services:
  bitcoin:
    container_name: bitcoind
    user: 1000:1000
    image: lncm/bitcoind:v25.0
    volumes:
      - ./bitcoin:/data/.bitcoin
    restart: on-failure
    stop_grace_period: 15m30s
    ports:
      - "8333:8333"
      - "8332:8332"
      - "28332:28332"
      - "28333:28333"
```
First, ensure that the `bitcoin/` folder is in the directory containing docker-compose.yml.
Then, Docker Compose will mount the `bitcoin/` folder to `/data/.bitcoin`.

#### Troubleshooting

##### Bitcoind isn't starting

Here are some possible reasons why.

###### Permissions for the bitcoin data directory is not correct

The permissions for the bitcoin data direct is assumed to be UID 1000 (first user). 

If you have a different setup, please do the following

```bash
# where ".bitcoin" is the data directory
sudo chown -R 1000.1000 $HOME/.bitcoin
```

