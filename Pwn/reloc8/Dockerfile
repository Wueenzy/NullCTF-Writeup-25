FROM python:latest

WORKDIR /app

RUN apt-get update && apt-get install -y socat
RUN useradd -m ctf

COPY d8 args.gn snapshot_blob.bin server.py docker-entrypoint.sh flag.txt .

RUN chmod +x /app/server.py /app/d8 /app/docker-entrypoint.sh
RUN chown -R ctf:ctf /app

USER ctf

EXPOSE 1337

CMD /app/docker-entrypoint.sh
