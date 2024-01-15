#!/bin/sh
envsubst '${SERVER_NAME} ${BACKEND_IP}' < /tmp/default_temp.conf > /etc/nginx/conf.d/default.conf
exec "$@"
