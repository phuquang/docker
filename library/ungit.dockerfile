FROM node:12-slim
LABEL author="Phu"
LABEL maintainer="phuquanglxc@gmail.com"
LABEL date="2022-01-01"

RUN set -x

# ENV UNGIT_VER 0.10.3
ENV UNGIT_VER 1.5.9
# ENV UNGIT_VER latest

ARG USER
ARG USERID
ARG GROUPID

RUN \
    apt-get update && \
    apt-get install -y git vim openssh-client ca-certificates --no-install-recommends && \
    apt-get clean \
    > /dev/null

RUN npm install -g ungit@${UNGIT_VER}

## For USER node
ADD --chown=node:node ./bashrc/bash_aliases.sh /home/node/.bash_aliases
ADD --chown=node:node ./ungit/bashrc /home/node/.bashrc
ADD --chown=node:node ./ungit/.ungitrc /home/node/.ungitrc
ADD --chown=node:node ./ungit/.gitconfig /home/node/.gitconfig
ADD --chown=node:node ./ssh/* /home/node/.ssh/
RUN ssh-keyscan github.com >> /home/node/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /home/node/.ssh/known_hosts

## For USER root
ADD ./bashrc/bash_aliases.sh /root/.bash_aliases
ADD ./ungit/bashrc /root/.bashrc
ADD ./ungit/.ungitrc /root/.ungitrc
ADD ./ungit/.gitconfig /root/.gitconfig
ADD ./ssh/* /root/.ssh/
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

## Create User
RUN useradd -G www-data,root -u $USERID -d /home/$USER $USER
RUN mkdir /projects && mkdir -p /home/$USER && chown -R $USER:$USER /home/$USER && chown -R $USER:$USER /projects
USER $USER

## For USER
ADD --chown=$USER:$USER ./bashrc/bash_aliases.sh /home/$USER/.bash_aliases
ADD --chown=$USER:$USER ./ungit/bashrc /home/$USER/.bashrc
ADD --chown=$USER:$USER ./ungit/.ungitrc /home/$USER/.ungitrc
ADD --chown=$USER:$USER ./ungit/.gitconfig /home/$USER/.gitconfig
ADD --chown=$USER:$USER ./ssh/* /home/$USER/.ssh/
RUN ssh-keyscan github.com >> /home/$USER/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /home/$USER/.ssh/known_hosts

EXPOSE 8448

ENTRYPOINT ["ungit", "--no-autoFetch"]

# CMD ["ungit"]
# CMD ["su", "-", "node", "-c", "ungit"]
