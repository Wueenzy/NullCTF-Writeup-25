FROM rust:latest AS base


FROM base AS planner
WORKDIR /app
RUN cargo install cargo-chef
COPY . .
RUN cargo chef prepare --recipe-path recipe.json


FROM base AS cacher
WORKDIR /app
RUN cargo install cargo-chef
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json


FROM base AS builder
WORKDIR /app
COPY . .
COPY --from=cacher /app/target target
RUN cargo build --release


FROM base AS runner

COPY --from=ghcr.io/ufoscout/docker-compose-wait:latest /wait /wait

RUN apt-get update && apt-get install -y firefox-esr

RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.36.0/geckodriver-v0.36.0-linux64.tar.gz -O geckodriver.tar.gz && \
    tar xzvf geckodriver.tar.gz && \
    chmod +x geckodriver

WORKDIR /app
COPY --from=builder /app/target/release/backend /usr/local/bin
COPY --chmod=777 docker-entrypoint.sh /

ENV FTP_HOST=ftp
ENV FTP_PORT=2121
ENV FTP_USER=admin
ENV FTP_PASS=admin
ENV FLAG=nullctf{wow}
ENV WAIT_HOSTS=ftp:2121
ENV ROCKET_ADDRESS=0.0.0.0
ENV FRONTEND_ADDR=http://frontend:3000

CMD /docker-entrypoint.sh

