FROM ubuntu:25.04@sha256:27771fb7b40a58237c98e8d3e6b9ecdd9289cec69a857fccfb85ff36294dac20

RUN apt update && apt install socat -y

RUN useradd ctf

WORKDIR /home/ctf

COPY ./flag.txt /home/ctf/flag.txt
COPY ./chall /home/ctf/chall

RUN chmod +x /home/ctf/chall

EXPOSE 7001

USER ctf

CMD ["socat", "TCP-LISTEN:7001,reuseaddr,fork", "EXEC:./chall,stderr"]
