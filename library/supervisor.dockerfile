FROM ubuntu:latest
LABEL author="Phu"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

ARG USER
ARG USERID
ARG GROUPID

RUN mkdir /projects
RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER
RUN mkdir -p /home/$USER/.composer && \
    chown -R $USER:$USER /home/$USER && \
    chown -R $USER:$USER /projects

RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY --chown=root:root ./php/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY --chown=root:root ./php/supervisor/entrypoint.sh /entrypoint.sh

# CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

CMD /entrypoint.sh
