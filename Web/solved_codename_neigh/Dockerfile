FROM ghcr.io/ponylang/ponyc:alpine

RUN apk update && \
    apk add --no-cache curl bash libressl-dev

WORKDIR /app

RUN corral init && \
    corral add github.com/theodus/jennet.git && \
    corral fetch

COPY ./app /app

RUN corral run -- ponyc -Dopenssl_0.9.0 -d -b main

CMD ["/app/main"]
