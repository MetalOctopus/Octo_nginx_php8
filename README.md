# Octo_nginx_php8

nginx + PHP 8.5-FPM on Alpine, built to be kept patched.

- Rebuilt **weekly** (and on every push) from the latest official `php:8.5-fpm-alpine` with `apk upgrade`
- Smoke-tested and Trivy-scanned in CI before anything is published
- Runs nginx/PHP as `PUID`/`PGID` (Unraid defaults 99/100), PHP over a unix socket, version banners hidden, dotfiles blocked
- HTTPS on 443 (self-signed cert auto-generated into `/config/ssl`; supply your own `cert.pem`/`key.pem`)

```
docker run -d -p 80:80 -p 443:443 \
  -v /path/to/site:/var/www/html -v /path/to/config:/config \
  ghcr.io/metaloctopus/octo_nginx_php8:latest
```

| Env | Default | |
|---|---|---|
| `PUID` / `PGID` / `UMASK` | 99 / 100 / 022 | runtime user |
| `TZ` | UTC | timezone |
| `PHP_MEMORY_LIMIT` | 256M | |
| `PHP_UPLOAD_MAX_FILESIZE` | 100M | also sets `post_max_size` |
| `WEBROOT` | /var/www/html | |

`/config`: `ssl/{cert,key}.pem`, `nginx/default.conf` (replaces the built-in server config), `php/*.ini`.

Extensions: gd intl zip bcmath exif sockets pdo_mysql mysqli pdo_pgsql redis apcu opcache. Composer included.

Unraid template: `unraid/Octo_nginx_php8.xml`.
