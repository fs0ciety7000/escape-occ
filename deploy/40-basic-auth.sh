#!/bin/sh
# Builds the nginx password file from runtime variables (set as secrets in Coolify).
# Fails closed: without credentials the container does not start.
set -eu

if [ -z "${BASIC_AUTH_USER:-}" ] || [ -z "${BASIC_AUTH_PASSWORD:-}" ]; then
  echo "basic-auth: BASIC_AUTH_USER and BASIC_AUTH_PASSWORD must be set" >&2
  exit 1
fi

hash=$(printf '%s' "$BASIC_AUTH_PASSWORD" | openssl passwd -apr1 -stdin)
printf '%s:%s\n' "$BASIC_AUTH_USER" "$hash" > /etc/nginx/.htpasswd
chown root:nginx /etc/nginx/.htpasswd
chmod 640 /etc/nginx/.htpasswd
echo "basic-auth: password file written for user ${BASIC_AUTH_USER}"
