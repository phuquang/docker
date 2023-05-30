FROM php:8-apache
LABEL author="Pauli"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

ARG USER
ARG USERID
ARG GROUPID
ARG LIB_DIR=./apache
ARG BASH_DIR=./bash

RUN set -x

RUN apt-get update && apt-get install --assume-yes --no-install-recommends zip unzip vim curl wget

## Imagick extension
RUN apt-get install --assume-yes --no-install-recommends --quiet \
    build-essential \
    libmagickwand-dev \
    libzip-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    > /dev/null

## GD extension
RUN apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    > /dev/null

## mysqli extension
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli \
    > /dev/null

RUN docker-php-ext-install pdo pdo_mysql

## exif intl zip extension
RUN docker-php-ext-install exif intl zip \
    > /dev/null

RUN a2enmod rewrite ssl headers socache_shmcb proxy proxy_http proxy_balancer lbmethod_byrequests proxy_fcgi

## WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar ; \
    chmod +x wp-cli.phar ; \
    mv wp-cli.phar /usr/local/bin/wp

## Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"; \
    php composer-setup.php --install-dir=/usr/bin --filename=composer; \
    php -r "unlink('composer-setup.php');"; \
    composer global require laravel/installer

ADD "$LIB_DIR/bashrc" /root/.bashrc
ADD "$BASH_DIR/bash_aliases" /root/.bash_aliases

RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER; mkdir /projects ; mkdir -p /home/$USER ; chown -R $USER:$USER /home/$USER ; chown -R $USER:$USER /projects

## cleanup
RUN apt-get clean ; rm -rf /var/lib/apt/lists/* ; rm -rf /tmp/*

EXPOSE 80
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
