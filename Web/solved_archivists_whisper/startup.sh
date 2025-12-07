#!/bin/sh
set -e

echo "nullctf{secret}" > "/flag_random.txt"

exec ./entrypoint.sh
