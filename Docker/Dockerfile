##############################################################################
# Docker image for building SELinux for MTK 2020
##############################################################################

FROM ubuntu:16.04

# update apt-get
RUN apt-get update

# get SELinux policyutils
RUN apt-get -y install policycoreutils

# make bash a little nicer
WORKDIR /root
RUN echo "alias lf='ls -aF'" >> .bashrc

# mtk-selinux source code should be mounted here
WORKDIR /usr/src/mtk-selinux
