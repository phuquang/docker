FROM php:8-fpm
LABEL author="Phu"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"



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
    dnsutils

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
    zip

## ALL PHP extension
## Possible values for ext-name:
## bcmath bz2 calendar ctype curl dba dl_test dom enchant exif ffi fileinfo filter ftp gd gettext gmp hash iconv imap intl json ldap
## mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell
## readline reflection session shmop simplexml snmp soap sockets sodium spl standard sysvmsg sysvsem sysvshm tidy tokenizer xml xmlreader xmlwriter xsl zend_test zip

## GraphicsMagick extension
RUN if [ "$SKIP_GMAGICK" = "0" ] ; then \
    apt-get install --no-install-recommends -y graphicsmagick libgraphicsmagick1-dev && pecl install channel://pecl.php.net/gmagick-2.0.6RC1 && echo "\n#GraphicsMagick\nextension=gmagick.so" >> /usr/local/etc/php/conf.d/gmagick.ini \
    ; fi

## soap extension
RUN apt-get install --no-install-recommends -y libxml2-dev && docker-php-ext-install soap

## mcrypt extension
RUN apt-get install --no-install-recommends -y libmcrypt-dev && pecl install mcrypt && docker-php-ext-enable mcrypt

## ftp extension
RUN apt-get install --no-install-recommends -y libssl-dev && docker-php-ext-install ftp

## xsl extension
RUN apt-get install --no-install-recommends -y libxslt-dev && docker-php-ext-install xsl

## imap extension
RUN apt-get install --no-install-recommends -y libc-client-dev libkrb5-dev && docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-install imap

## ldap extension
RUN if [ "$SKIP_LDAP" = "0" ] ; then \
    apt-get install --no-install-recommends -y libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    ; fi

## intl extension
RUN apt-get install --no-install-recommends -y libicu-dev && docker-php-ext-configure intl && docker-php-ext-install intl

## gd extension
RUN apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

## memcached extension
RUN apt-get install --no-install-recommends -y \
        libmemcached-dev zlib1g-dev \
    && pecl install memcached \
    && docker-php-ext-enable memcached

## redis extension
RUN pecl install redis && docker-php-ext-enable redis

## xdebug extension
RUN pecl install xdebug && docker-php-ext-enable xdebug

## opcache extension
RUN docker-php-ext-install opcache
COPY ./php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

## Imagick extension
RUN apt-get install --no-install-recommends -y libmagickwand-dev; \
    pecl install imagick; \
    docker-php-ext-enable imagick;
    # echo "extension=imagick.so" >> /usr/local/etc/php/conf.d/imagick.ini

## apcu extension
RUN pecl install apcu && docker-php-ext-enable apcu

## MongoDB
RUN apt-get install --no-install-recommends -y libssl-dev \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb
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
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"; \
    php composer-setup.php --install-dir=/usr/bin --filename=composer; \
    php -r "unlink('composer-setup.php');";
RUN composer global require laravel/installer

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

## Install Node.js, Yarn and required dependencies
RUN apt-get update \
  && apt-get install -y curl gnupg build-essential \
  && curl --silent --location https://deb.nodesource.com/setup_16.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get remove -y --purge cmdtest \
  && apt-get update \
  && apt-get install -y nodejs yarn
RUN adduser --disabled-password --gecos "" --uid 1000 node

## Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER
RUN mkdir /projects && \
    mkdir -p /home/$USER/.composer && \
    chown -R $USER:$USER /home/$USER && \
    chown -R $USER:$USER /projects

## Add configure
ADD ./php/custom.ini /usr/local/etc/php/conf.d/custom.ini
ADD ./php/bashrc /home/$USER/.bashrc
ADD ./bashrc/bash_aliases.sh /home/$USER/.bash_aliases

RUN chown -R $USER:$USER /home/$USER

## Run script
COPY --chown=root:root ./php/bootstrap.sh /bootstrap.sh
RUN chmod u+x /bootstrap.sh; /bootstrap.sh

## cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

USER $USER

## Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
# CMD /bootstrap.sh
