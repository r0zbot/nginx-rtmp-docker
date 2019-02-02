#!/usr/bin/env sh
set -eu

envsubst '${SOURCE_KEY} ${TRANSCODE_KEY} ${PRESET} ${RESOLUTION} ${BITRATE} ${TRANSCODE_URL} ${SOURCE_URL}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"
