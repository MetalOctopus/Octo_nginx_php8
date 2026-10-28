# syntax=docker/dockerfile:1
ARG PHP_VERSION=8.5
ARG ALPINE_VERSION=3.24

FROM composer:2 AS composer

FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION}

LABEL org.opencontainers.image.title="Octo_nginx_php8" \
      org.opencontainers.image.description="nginx + PHP-FPM on Alpine, rebuilt weekly with all security updates" \
      org.opencontainers.image.source="https://github.com/MetalOctopus/Octo_nginx_php8" \
      org.opencontainers.image.licenses="MIT"

# Pull every pending Alpine security fix on top of the (already current) base image.
RUN apk upgrade --no-cache \
 && apk add --no-cache nginx supervisor tzdata openssl curl bash \
 && curl -fsSL -o /usr/local/bin/install-php-extensions \
      https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
 && chmod +x /usr/local/bin/install-php-extensions \
 && install-php-extensions gd intl zip bcmath exif sockets pdo_mysql mysqli pdo_pgsql redis apcu opcache \
 && rm -f /usr/local/bin/install-php-extensions \
 && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && rm -rf /var/www/html/* /etc/nginx/http.d /usr/local/etc/php-fpm.d/zz-docker.conf /tmp/*

COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY rootfs/ /
RUN chmod +x /usr/local/bin/octo-entrypoint

ENV PUID=99 PGID=100 UMASK=022 TZ=UTC WEBROOT=/var/www/html \
    PHP_MEMORY_LIMIT=256M PHP_UPLOAD_MAX_FILESIZE=100M \
    PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/config/php

VOLUME ["/config"]
WORKDIR /var/www/html
EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -fsS http://127.0.0.1/.octo-health >/dev/null && pgrep php-fpm >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/octo-entrypoint"]
