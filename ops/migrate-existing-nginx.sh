#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this migration as root." >&2
  exit 1
fi

CONFIG=/etc/nginx/sites-available/pocket-gallery
LEGACY_ROOT=/var/www/pocket-gallery/docs/.vuepress/dist
CURRENT_LINK=/srv/pocket-gallery/current
BACKUP="$CONFIG.before-atomic-deploy.$(date +%Y%m%d%H%M%S)"
TEMP_CONFIG="$(mktemp)"

[[ -s "$LEGACY_ROOT/index.html" ]] || {
  echo "Existing site was not found at $LEGACY_ROOT" >&2
  exit 1
}
[[ -f /etc/letsencrypt/live/pocket-gallery.cn/fullchain.pem ]] || {
  echo "Existing TLS certificate was not found." >&2
  exit 1
}

if [[ ! -e "$CURRENT_LINK" ]]; then
  ln -s "$LEGACY_ROOT" "$CURRENT_LINK"
  printf '{"commit":"legacy","deployedAt":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >"$LEGACY_ROOT/version.json"
fi

cat >"$TEMP_CONFIG" <<'NGINX'
server {
    listen 80;
    server_name pocket-gallery.cn www.pocket-gallery.cn;

    location = /version.json {
        root /srv/pocket-gallery/current;
        default_type application/json;
        add_header Cache-Control "no-store" always;
        try_files /version.json =404;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name pocket-gallery.cn www.pocket-gallery.cn;

    ssl_certificate /etc/letsencrypt/live/pocket-gallery.cn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pocket-gallery.cn/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-CHACHA20-POLY1305';
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1.2 TLSv1.3;

    root /srv/pocket-gallery/current;

    location = /version.json {
        default_type application/json;
        add_header Cache-Control "no-store" always;
        try_files /version.json =404;
    }

    location = /.well-known/applinking.json {
        default_type application/json;
        add_header Cache-Control "no-cache";
        return 200 '{"applinking":{"apps":[{"appIdentifier":"6917608137452211230"}]}}';
    }

    location / {
        try_files $uri $uri/ /index.html;
    }

    access_log /var/log/nginx/pocket-gallery.cn.access.log;
    error_log /var/log/nginx/pocket-gallery.cn.error.log;
}
NGINX

cp -a "$CONFIG" "$BACKUP"
install -o root -g root -m 0644 "$TEMP_CONFIG" "$CONFIG"
rm -f "$TEMP_CONFIG"

if ! nginx -t; then
  cp -a "$BACKUP" "$CONFIG"
  echo "Nginx validation failed; restored $BACKUP" >&2
  exit 1
fi

systemctl reload nginx
health="$(curl -fsS --max-time 20 -H 'Host: www.pocket-gallery.cn' \
  http://127.0.0.1/version.json)"
[[ "$health" == *'"commit":"legacy"'* || "$health" == *'"commit":"'* ]] || {
  echo "Unexpected health response: $health" >&2
  exit 1
}

printf 'Nginx migration complete. Backup: %s\n' "$BACKUP"
printf 'Current release: %s\n' "$(readlink "$CURRENT_LINK")"
printf 'Health response: %s\n' "$health"
