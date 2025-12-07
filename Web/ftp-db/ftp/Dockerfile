FROM python:3.10-slim

WORKDIR /app
COPY ftpd.py /app
RUN pip install pyftpdlib

RUN mkdir -p /ftp_root/user

ENV ADMIN_FTP_PASSWORD=admin

CMD python ftpd.py
