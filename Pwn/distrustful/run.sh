#!/bin/bash

docker build -t distrustful .
docker run -it -p7001:7001 distrustful
