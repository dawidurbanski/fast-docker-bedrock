FROM php:7-fpm

ENV \
  APP_DIR="/www"

# Install base requirements & sensible defaults + required PHP extensions
# hadolint ignore=DL3008
RUN echo "deb http://ftp.debian.org/debian $(sed -n 's/^VERSION=.*(\(.*\)).*/\1/p' /etc/os-release)-backports main" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        bindfs \
        ghostscript \
        less \
        libjpeg-dev \
        libmagickwand-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev \
        mariadb-client \
        sudo \
        unzip \
        vim \
        zip \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-configure zip --with-libzip \
    && pecl install imagick \
    && pecl install redis \
    && docker-php-ext-install \
        bcmath \
        exif \
        gd \
        mysqli \
        opcache \
        soap \
        zip \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable redis \
    # See https://secure.php.net/manual/en/opcache.installation.php
    && echo 'memory_limit = 512M' >> /usr/local/etc/php/php.ini \
    && { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini \
    # Grab and install wp-cli from remote
    && curl \
        -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

COPY bedrock/ $APP_DIR

WORKDIR /www
EXPOSE 80 443
