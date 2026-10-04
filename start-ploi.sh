#!/bin/sh
set -eu

: "${PORT:=8080}"
: "${XUI_PORT:=20530}"
: "${XUI_WS_PORT:=10001}"
: "${XUI_WS_PATH:=/xws}"
export PORT XUI_PORT XUI_WS_PORT XUI_WS_PATH

mkdir -p /run/nginx /var/log/nginx /etc/x-ui /root/cert

envsubst '${PORT} ${XUI_PORT} ${XUI_WS_PORT} ${XUI_WS_PATH}' \
  < /etc/nginx/nginx.conf.template \
  > /etc/nginx/nginx.conf

nginx -t
exec /usr/bin/supervisord -c /etc/supervisord.conf -n
