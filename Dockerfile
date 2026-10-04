# Ploi Cloud wrapper around the official 3x-ui image.
# The official panel/Xray build is kept intact; this layer only adds the
# HTTP ingress adapter needed by an application platform.
FROM ghcr.io/mhsanaei/3x-ui:v3.9.0

USER root

RUN apk add --no-cache nginx supervisor gettext \
    && mkdir -p /run/nginx /var/log/nginx /etc/supervisor.d

ENV PORT=8080 \
    XUI_PORT=20530 \
    XUI_WS_PORT=10001 \
    XUI_WS_PATH=/xws \
    XUI_ENABLE_FAIL2BAN=false \
    XUI_DB_FOLDER=/etc/x-ui \
    XUI_MAIN_FOLDER=/app \
    XUI_IN_DOCKER=true

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY supervisord.conf /etc/supervisord.conf
COPY start-ploi.sh /usr/local/bin/start-ploi.sh

RUN chmod 0755 /usr/local/bin/start-ploi.sh

EXPOSE 8080
VOLUME ["/etc/x-ui", "/root/cert"]

ENTRYPOINT ["/usr/local/bin/start-ploi.sh"]
