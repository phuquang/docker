FROM php:8-fpm
LABEL author="Pauli"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

ARG USER
ARG USERID
ARG GROUPID
ARG LIB_DIR=./supervisor
ARG BASH_DIR=./bash

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    git libzip-dev zip unzip vim wget make ffmpeg

## PHP extension
RUN docker-php-ext-install bcmath calendar exif mysqli pdo_mysql sockets zip

RUN mkdir /projects ; useradd -G www-data,root -u $USERID -d /home/$USER $USER ; mkdir -p /home/$USER/.composer ; chown -R $USER:$USER /home/$USER ; chown -R $USER:$USER /projects

RUN apt-get install -y supervisor ; mkdir -p /var/log/supervisor
COPY --chown=root:root "$LIB_DIR/supervisord.conf" /etc/supervisor/supervisord.conf
COPY --chown=ubuntu:ubuntu "$LIB_DIR/entrypoint.sh" /entrypoint.sh
RUN chmod u+x /entrypoint.sh;

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
