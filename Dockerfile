FROM php:7.3-fpm-alpine3.12

LABEL Maintainer="Afkari <afkari.1370@gmail.com>" Description="Base sendy"

RUN set -xe && \
    apk add --update icu supervisor nginx mysql-client openssl php7-zip gettext-dev && \
    apk add --no-cache --virtual .php-deps make && \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS icu-dev g++ zip libzip-dev libjpeg-turbo-dev libpng-dev libxml2-dev bzip2-dev && \
    docker-php-ext-install gettext intl opcache mysqli pdo_mysql sockets zip bz2 pcntl bcmath exif && \
    docker-php-ext-configure intl && \
    { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } && \
    docker-php-ext-configure opcache --enable-opcache && \
    curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer && \
    apk del .build-deps  && \
    rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*apk && \
    mkdir -p /etc/nginx/ssl /var/log/supervisor /run/nginx/ /var/www/html/uploads && \
    chmod 777 /var/www/html/uploads
