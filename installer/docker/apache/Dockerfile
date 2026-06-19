ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        unzip \
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

RUN chmod +x /usr/local/bin/modxium-entrypoint.sh

ENTRYPOINT ["modxium-entrypoint.sh"]
CMD ["apache2-foreground"]