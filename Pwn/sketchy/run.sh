#!/bin/bash

docker build -t sketchy .
docker run -it -p7001:7001 sketchy
