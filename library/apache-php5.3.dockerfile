FROM php:5.3-apache
LABEL author="Pauli"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

ARG USER
ARG USERID
ARG GROUPID
ARG LIB_DIR=./apache
ARG BASH_DIR=./bash

RUN set -x

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EF0F382A1A7B6500

RUN apt-get update && apt-get install --assume-yes --no-install-recommends zip unzip vim curl wget

## mysqli extension
# RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli \
#     > /dev/null

# RUN docker-php-ext-install pdo pdo_mysql

## exif intl zip extension
# RUN docker-php-ext-install exif intl zip \
#     > /dev/null

RUN a2enmod rewrite ssl headers socache_shmcb proxy proxy_http proxy_balancer lbmethod_byrequests proxy_fcgi

ADD "$LIB_DIR/bashrc" /root/.bashrc
ADD "$BASH_DIR/bash_aliases" /root/.bash_aliases

RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER; mkdir /projects ; mkdir -p /home/$USER ; chown -R $USER:$USER /home/$USER ; chown -R $USER:$USER /projects

## cleanup
RUN apt-get clean ; rm -rf /var/lib/apt/lists/* ; rm -rf /tmp/*

EXPOSE 80
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo "IncludeOptional sites-enabled/*.conf" >> /etc/apache2/apache2.conf
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
