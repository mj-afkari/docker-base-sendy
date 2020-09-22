FROM php:7.3-fpm-alpine3.12

LABEL Maintainer="Afkari <afkari.1370@gmail.com>" Description="Base sendy"
ENV TZ=UTC
ARG POOL_FILE=/usr/local/etc/php-fpm.d/www.conf

ENV FPM_PM=dynamic
ENV FPM_PM_MAX_CHILDREN=5
ENV FPM_PM_START_SERVICE=2
ENV FPM_PM_MIN_SPARE_SERVERS=1
ENV FPM_PM_MAX_SPARE_SERVERS=3
ENV FPM_PM_PROCESS_IDLE_TIMEOUT=5s
ENV FPM_PM_MAX_REQUESTS=501

RUN set -xe && \
    apk add --update tzdata icu supervisor nginx mysql-client openssl php7-zip gettext-dev && \
    apk add --no-cache --virtual .php-deps make && \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS icu-dev g++ zip libzip-dev libjpeg-turbo-dev libpng-dev libxml2-dev bzip2-dev && \
    docker-php-ext-install gettext intl opcache mysqli pdo_mysql sockets zip bz2 pcntl bcmath exif && \
    docker-php-ext-configure intl && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    printf '[PHP]\ndate.timezone = "${TZ}"\n' > /usr/local/etc/php/conf.d/tzone.ini && \
    { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } && \
    docker-php-ext-configure opcache --enable-opcache && \
    curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer && \
    apk del .build-deps  && \
    rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*apk && \
    mkdir -p /etc/nginx/ssl /var/log/supervisor /run/nginx/ /var/www/html/uploads && \
    chmod 777 /var/www/html/uploads && \
    sed -i 's/pm = dynamic/pm = ${FPM_PM}/g' $POOL_FILE && \
    sed -i 's/pm.max_children = 5/pm.max_children = ${FPM_PM_MAX_CHILDREN}/g' $POOL_FILE && \
    sed -i 's/pm.start_servers = 2/pm.start_servers = ${FPM_PM_START_SERVICE}/g' $POOL_FILE && \
    sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = ${FPM_PM_MIN_SPARE_SERVERS}/g' $POOL_FILE && \
    sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = ${FPM_PM_MAX_SPARE_SERVERS}/g' $POOL_FILE && \
    sed -i 's/;pm.process_idle_timeout = 10s;/;pm.process_idle_timeout = ${FPM_PM_PROCESS_IDLE_TIMEOUT};/g' $POOL_FILE && \
    sed -i 's/;pm.max_requests = 500/;pm.max_requests = ${FPM_PM_MAX_REQUESTS}/g' $POOL_FILE

