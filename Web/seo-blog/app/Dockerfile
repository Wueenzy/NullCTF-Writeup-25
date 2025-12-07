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

RUN apt-get update && apt-get install -y firefox-esr sqlite3 libsqlite3-dev

RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.36.0/geckodriver-v0.36.0-linux64.tar.gz -O geckodriver.tar.gz && \
    tar xzvf geckodriver.tar.gz && \
    chmod +x geckodriver

ENV FLAG=nullctf{wow}
ENV ROCKET_ADDRESS=0.0.0.0
ENV DATABASE_URL=sqlite://app.db
ENV ADMIN_PASSWORD=admin

WORKDIR /app
COPY templates templates
COPY static static
COPY --from=builder /app/target/release/backend .
COPY --chmod=777 docker-entrypoint.sh /
RUN sqlite3 app.db "vacuum;"

CMD /docker-entrypoint.sh

