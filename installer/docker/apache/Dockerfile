ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        git \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql \
        mysqli \
        zip \
        gd \
    && a2enmod rewrite \
    && echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/modxium-entrypoint.sh
COPY git-sync.sh /opt/modxium/git-sync.sh
COPY webhook.php /opt/modxium/webhook.php

RUN chmod +x /usr/local/bin/modxium-entrypoint.sh /opt/modxium/git-sync.sh \
    && chown -R www-data:www-data /opt/modxium

ENTRYPOINT ["modxium-entrypoint.sh"]
CMD ["apache2-foreground"]
