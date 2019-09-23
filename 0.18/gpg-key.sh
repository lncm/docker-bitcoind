#!/bin/sh

KEY=$1

printf "Attempting to import gpg key: %s\n" "${KEY}"

for S in hkp://p80.pool.sks-keyservers.net:80  ha.pool.sks-keyservers.net  keyserver.pgp.com  pgp.mit.edu; do
        printf "Trying from %s:\t" "$S"
        if timeout 10s gpg --keyserver "$S" --recv-keys "${KEY}" >/dev/null 2<&1; then
                echo "OK"
                exit 0
        fi

        printf "ERR: timeout\n"
done

exit 1
