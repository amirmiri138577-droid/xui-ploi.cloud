#!/bin/sh
set -eu

: "${PORT:=8080}"
: "${XUI_PORT:=20530}"
export PORT XUI_PORT

mkdir -p /run/nginx /var/log/nginx /etc/x-ui /root/cert

envsubst '${PORT} ${XUI_PORT}' \
  < /etc/nginx/nginx.conf.template \
  > /etc/nginx/nginx.conf

nginx -t
exec /usr/bin/supervisord -c /etc/supervisord.conf -n
