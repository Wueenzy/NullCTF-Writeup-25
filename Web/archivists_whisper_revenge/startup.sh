#!/bin/sh
set -e

#if [ -e "/flag.txt" ]; then
#    RANDOM_HEX=$(head -c 32 /dev/urandom | xxd -p -c 32)
#    FILENAME="/flag_${RANDOM_HEX}.txt"
#    mv /flag.txt $FILENAME
#fi

exec ./entrypoint.sh
