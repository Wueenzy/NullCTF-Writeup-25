FROM crystallang/crystal:1.16.3-alpine

WORKDIR /app

COPY shard.yml .

RUN shards install

COPY ./src/app.cr ./app.cr
COPY ./src/views ./views

RUN shards build --production --release --static --no-debug

COPY ./src/public ./public

EXPOSE 9091

CMD ["/app/bin/app"]
