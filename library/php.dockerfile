FROM php:8-fpm
LABEL author="Pauli"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

ARG USER
ARG USERID
ARG GROUPID
ARG PHP_ENVIRONMENT=development
ARG GMAGICK_INSTALL=1
ARG MCRYPT_INSTALL=1
ARG LDAP_INSTALL=1
ARG MONGODB_INSTALL=1
ARG SYMFONY_INSTALL=1
ARG LIB_DIR=./php
ARG BASH_DIR=./bash

RUN apt-get update -y ; apt-get install --no-install-recommends -y \
    git libzip-dev zip unzip vim wget make \
    ## soap extension
    libxml2-dev \
    ## libssl for ftp extension and MongoDB
    libssl-dev \
    ## xsl extension
    libxslt-dev \
    ## imap extension
    libc-client-dev libkrb5-dev \
    ## intl extension
    libicu-dev \
    ## memcached extension
    libmemcached-dev zlib1g-dev

## Install ffmpeg
RUN apt-get install -y ffmpeg

## imap extension
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-configure intl

## PHP extension
RUN docker-php-ext-install \
    bcmath calendar exif \
    mysqli \
    # pdo_firebird \
    pdo_mysql \
    # pdo_pgsql pgsql \
    sockets \
    zip \
    soap \
    ftp \
    xsl \
    imap \
    intl \
    opcache

## ALL PHP extension
## Possible values for ext-name:
## bcmath bz2 calendar ctype curl dba dl_test dom enchant exif ffi fileinfo filter ftp gd gettext gmp hash iconv imap intl json ldap
## mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell
## readline reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer xml xmlreader xmlwriter xsl zend_test zip

## GraphicsMagick extension
RUN if [ "$GMAGICK_INSTALL" = "1" ] ; then \
    apt-get install --no-install-recommends -y graphicsmagick libgraphicsmagick1-dev ; \
    pecl install channel://pecl.php.net/gmagick-2.0.6RC1 ; \
    echo "\n#GraphicsMagick\nextension=gmagick.so" >> /usr/local/etc/php/conf.d/gmagick.ini \
    ; fi

## mcrypt extension
RUN if [ "$MCRYPT_INSTALL" = "1" ] ; then \
    apt-get install --no-install-recommends -y libmcrypt-dev ; pecl install mcrypt ; docker-php-ext-enable mcrypt \
    ; fi

## ldap extension
RUN if [ "$LDAP_INSTALL" = "1" ] ; then \
    apt-get install --no-install-recommends -y libldap2-dev ; \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ ; \
    docker-php-ext-install ldap \
    ; fi

## gd extension
RUN apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg ; \
    docker-php-ext-install -j$(nproc) gd

## memcached extension
RUN pecl install memcached ; docker-php-ext-enable memcached

## redis extension
RUN pecl install redis ; docker-php-ext-enable redis

## xdebug extension
RUN pecl install xdebug ; docker-php-ext-enable xdebug

## opcache extension
COPY "$LIB_DIR/opcache.ini" /usr/local/etc/php/conf.d/opcache.ini

## Imagick extension
RUN apt-get install --no-install-recommends -y libmagickwand-dev; \
    pecl install imagick; \
    docker-php-ext-enable imagick;
    # echo "extension=imagick.so" >> /usr/local/etc/php/conf.d/imagick.ini

## apcu extension
RUN pecl install apcu ; docker-php-ext-enable apcu

## MongoDB
RUN if [ "$MONGODB_INSTALL" = "1" ] ; then \
    pecl install mongodb ; docker-php-ext-enable mongodb \
    # && echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini
    ; fi

## MongoDB Database Tools
RUN if [ "$MONGODB_INSTALL" = "1" ] ; then \
    wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian11-x86_64-100.5.4.tgz ; \
    tar -zxvf mongodb-database-tools-debian11-x86_64-100.5.4.tgz ; \
    cp -r mongodb-database-tools-debian11-x86_64-100.5.4/bin/* /usr/bin/ ; \
    rm -f mongodb-database-tools-debian11-x86_64-100.5.4.tgz ; \
    rm -rf mongodb-database-tools-debian11-x86_64-100.5.4 \
    ; fi

## Use the default production configuration
RUN if [ "$PHP_ENVIRONMENT" = "production" ] ; then \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    ; fi

## Use the default development configuration
RUN if [ "$PHP_ENVIRONMENT" = "development" ] ; then \
    mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    ; fi

## Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/usr/bin --filename=composer; \
    php -r "unlink('composer-setup.php');";

## Install symfony
RUN if [ "$SYMFONY_INSTALL" = "1" ] ; then \
    curl -sS https://get.symfony.com/cli/installer | bash ; \
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony \
    ; fi

## sendmail
RUN curl --fail --silent --location --output /tmp/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 ; \
    chmod +x /tmp/mhsendmail ; \
    mv /tmp/mhsendmail /usr/bin/mhsendmail
ADD "$LIB_DIR/sendmail.ini" /usr/local/etc/php/conf.d/sendmail.ini

## Install Node.js, Yarn and required dependencies
RUN apt-get install -y curl gnupg build-essential ; \
    curl --silent --location https://deb.nodesource.com/setup_16.x | bash - ; \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - ; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list ; \
    apt-get remove -y --purge cmdtest ; \
    apt-get update ; \
    apt-get install -y nodejs yarn ; \
    adduser --disabled-password --gecos "" --uid 1999 node

## Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER ; mkdir -p /projects ; mkdir -p /home/$USER/.composer ; chown -R $USER:$USER /home/$USER ; chown -R $USER:$USER /projects

## Add configure
ADD "$LIB_DIR/custom.ini" /usr/local/etc/php/conf.d/custom.ini
ADD --chown=$USER:$USER "$LIB_DIR/bashrc" /home/$USER/.bashrc
ADD --chown=$USER:$USER "$BASH_DIR/bash_aliases" /home/$USER/.bash_aliases

## Run script
COPY --chown=root:root "$LIB_DIR/bootstrap.sh" /bootstrap.sh
RUN chmod u+x /bootstrap.sh; /bootstrap.sh

## cleanup
RUN apt-get clean ; rm -rf /var/lib/apt/lists/* ; rm -rf /tmp/*

USER $USER

## Laravel installer
RUN composer global require laravel/installer

## Add git config
ADD --chown=$USER:$USER "./ungit/.gitconfig" /home/$USER/.gitconfig

## Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
