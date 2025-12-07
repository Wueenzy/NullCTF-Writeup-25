FROM b3log/siyuan

ENV TZ=America/New_York \
    PUID=1000 \
    PGID=1000 \
    SIYUAN_ACCESS_AUTH_CODE=SuperSecretPassword
    
RUN mkdir -p /siyuan/workspace

COPY ./startup.sh /opt/siyuan/startup.sh
RUN chmod +x /opt/siyuan/startup.sh

EXPOSE 6806

ENTRYPOINT ["sh", "-c", "/opt/siyuan/startup.sh"]