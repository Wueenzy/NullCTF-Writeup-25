FROM ubuntu:24.04@sha256:4fdf0125919d24aec972544669dcd7d6a26a8ad7e6561c73d5549bd6db258ac2

RUN apt update && apt install socat -y

RUN useradd ctf

WORKDIR /home/ctf

COPY ./flag.txt /home/ctf/flag.txt
COPY ./chall /home/ctf/chall

RUN chmod +x /home/ctf/chall

EXPOSE 7001

USER ctf

CMD ["socat", "TCP-LISTEN:7001,reuseaddr,fork", "EXEC:./chall,stderr"]
