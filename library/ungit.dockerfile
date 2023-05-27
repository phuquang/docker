FROM node:16-slim
LABEL author="Pauli"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

RUN set -x
ARG USER
ARG USERID
ARG GROUPID
ARG LIB_DIR=./ungit
ARG BASH_DIR=./bash
ARG SSH_DIR=./ssh

#ENV UNGIT_VER 1.5.23
ENV UNGIT_VER latest

RUN apt-get update && \
    apt-get install -y git vim openssh-client ca-certificates --no-install-recommends && \
    apt-get clean \
    > /dev/null

RUN npm install -g ungit@${UNGIT_VER}

# RUN npm ci && npm cache clean --force
RUN npm cache clean --force

RUN groupmod -g 1999 node && usermod -u 1999 -g 1999 node

## For USER node
ADD --chown=node:node "$BASH_DIR/bash_aliases" /home/node/.bash_aliases
ADD --chown=node:node "$LIB_DIR/bashrc" /home/node/.bashrc
ADD --chown=node:node "$LIB_DIR/.ungitrc" /home/node/.ungitrc
ADD --chown=node:node "$LIB_DIR/.gitconfig" /home/node/.gitconfig
ADD --chown=node:node "$SSH_DIR/*" /home/node/.ssh/
RUN ssh-keyscan github.com >> /home/node/.ssh/known_hosts ; \
    ssh-keyscan bitbucket.org >> /home/node/.ssh/known_hosts

## For USER root
ADD "$BASH_DIR/bash_aliases" /root/.bash_aliases
ADD "$LIB_DIR/bashrc" /root/.bashrc
ADD "$LIB_DIR/.ungitrc" /root/.ungitrc
ADD "$LIB_DIR/.gitconfig" /root/.gitconfig
ADD "$SSH_DIR/*" /root/.ssh/
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts ; \
    ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

## Create User
RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER ; mkdir /projects ; mkdir -p /home/$USER ; chown -R $USER:$USER /home/$USER ; chown -R $USER:$USER /projects

USER $USER

## For USER
ADD --chown=$USER:$USER "$BASH_DIR/bash_aliases" /home/$USER/.bash_aliases
ADD --chown=$USER:$USER "$LIB_DIR/bashrc" /home/$USER/.bashrc
ADD --chown=$USER:$USER "$LIB_DIR/.ungitrc" /home/$USER/.ungitrc
ADD --chown=$USER:$USER "$LIB_DIR/.gitconfig" /home/$USER/.gitconfig
ADD --chown=$USER:$USER "$SSH_DIR/*" /home/$USER/.ssh/
RUN ssh-keyscan github.com >> /home/$USER/.ssh/known_hosts ;\
    ssh-keyscan bitbucket.org >> /home/$USER/.ssh/known_hosts

EXPOSE 8448

ENTRYPOINT ["ungit", "--no-autoFetch"]
