#!/bin/sh

RANDOM_SUFFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

mv flag.txt "flag_${RANDOM_SUFFIX}.txt"

exec socat TCP-LISTEN:1337,fork,reuseaddr EXEC:/app/server.py
