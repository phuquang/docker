FROM php:7-fpm
LABEL author="Phu"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

RUN set -x

ARG USER
ARG USERID
ARG GROUPID
ARG PHP_ENVIRONMENT=development
ARG SYMFONY_INSTALL=0
ARG SKIP_LDAP=1
ARG SKIP_GMAGICK=1

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    git \
    libzip-dev \
    zip \
    unzip \
    vim \
    wget \
    make \
    net-tools \
    dnsutils > /dev/null

## Install ffmpeg
RUN apt-get install -y ffmpeg

## PHP extension
RUN docker-php-ext-install \
    bcmath calendar exif \
    mysqli \
    # pdo_firebird \
    pdo_mysql \
    # pdo_pgsql pgsql \
    sockets \
    zip > /dev/null

## ALL PHP extension
## Possible values for ext-name:
## bcmath bz2 calendar ctype curl dba dl_test dom enchant exif ffi fileinfo filter ftp gd gettext gmp hash iconv imap intl json ldap
## mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell
## readline reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer xml xmlreader xmlwriter xsl zend_test zip

## GraphicsMagick extension
RUN if [ "$SKIP_GMAGICK" = "0" ] ; then \
    apt-get install --no-install-recommends -y graphicsmagick libgraphicsmagick1-dev && pecl install channel://pecl.php.net/gmagick-2.0.6RC1 && echo "\n#GraphicsMagick\nextension=gmagick.so" >> /usr/local/etc/php/conf.d/gmagick.ini > /dev/null \
    ; fi

## soap extension
RUN apt-get install --no-install-recommends -y libxml2-dev && docker-php-ext-install soap > /dev/null

## mcrypt extension
RUN apt-get install --no-install-recommends -y libmcrypt-dev && pecl install mcrypt && docker-php-ext-enable mcrypt > /dev/null

## ftp extension
RUN apt-get install --no-install-recommends -y libssl-dev && docker-php-ext-install ftp > /dev/null

## xsl extension
RUN apt-get install --no-install-recommends -y libxslt-dev && docker-php-ext-install xsl > /dev/null

## imap extension
RUN apt-get install --no-install-recommends -y libc-client-dev libkrb5-dev && docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-install imap > /dev/null

## ldap extension
RUN if [ "$SKIP_LDAP" = "0" ] ; then \
    apt-get install --no-install-recommends -y libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    > /dev/null \
    ; fi

## intl extension
RUN apt-get install --no-install-recommends -y libicu-dev && docker-php-ext-configure intl && docker-php-ext-install intl > /dev/null

## gd extension
RUN apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    > /dev/null

## memcached extension
RUN apt-get install --no-install-recommends -y \
        libmemcached-dev zlib1g-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    > /dev/null

## redis extension
RUN pecl install redis && docker-php-ext-enable redis > /dev/null

## xdebug extension
RUN pecl install xdebug && docker-php-ext-enable xdebug > /dev/null

## opcache extension
RUN docker-php-ext-install opcache > /dev/null
COPY ./php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

## Imagick extension
RUN apt-get install --no-install-recommends -y libmagickwand-dev; \
    pecl install imagick; \
    docker-php-ext-enable imagick; \
    > /dev/null
    # echo "extension=imagick.so" >> /usr/local/etc/php/conf.d/imagick.ini

## apcu extension
RUN pecl install apcu && docker-php-ext-enable apcu > /dev/null

## MongoDB
RUN apt-get install --no-install-recommends -y libssl-dev \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    > /dev/null
    # && echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

## MongoDB Database Tools
RUN wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian11-x86_64-100.5.4.tgz \
    && tar -zxvf mongodb-database-tools-debian11-x86_64-100.5.4.tgz \
    && cp -r mongodb-database-tools-debian11-x86_64-100.5.4/bin/* /usr/bin/ \
    && rm -f mongodb-database-tools-debian11-x86_64-100.5.4.tgz \
    && rm -rf mongodb-database-tools-debian11-x86_64-100.5.4

## Use the default production configuration
RUN if [ "$PHP_ENVIRONMENT" = "production" ] ; then \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    ; fi

## Use the default development configuration
RUN if [ "$PHP_ENVIRONMENT" = "development" ] ; then \
    mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    ; fi

## Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    chmod +x /usr/bin/composer \
    > /dev/null

## Install symfony
RUN if [ "$SYMFONY_INSTALL" = "1" ] ; then \
    curl -sS https://get.symfony.com/cli/installer | bash \
    &&  mv /root/.symfony/bin/symfony /usr/local/bin \
    ; fi

## sendmail
RUN curl --fail --silent --location --output /tmp/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64
RUN chmod +x /tmp/mhsendmail
RUN mv /tmp/mhsendmail /usr/bin/mhsendmail
ADD ./php/sendmail.ini /usr/local/etc/php/conf.d/sendmail.ini

## Create system user to run Composer and Artisan Commands
RUN mkdir /projects
RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER
RUN mkdir -p /home/$USER/.composer && \
    chown -R $USER:$USER /home/$USER && \
    chown -R $USER:$USER /projects

## Add configure
ADD ./php/custom.ini /usr/local/etc/php/conf.d/custom.ini
ADD ./php/bashrc /home/$USER/.bashrc
ADD ./bashrc/bash_aliases.sh /home/$USER/.bash_aliases

## Run script
COPY ./php/bootstrap.sh /bootstrap.sh
RUN chmod u+x /bootstrap.sh; /bootstrap.sh

## cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apk/* && rm -rf /tmp/* > /dev/null

USER $USER

## Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
