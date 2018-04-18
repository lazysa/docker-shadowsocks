FROM centos:latest
LABEL maintainer="linuxjosery@gmail.com"
LABEL comment="use to create a VPN by shadowsocks"
ARG TZ='Asia/Shanghai'

ENV HOST_NAME='docker_shadowsocks'
ENV TZ='Asia/Shanghai'
ENV SS_PORT='8989'
ENV SS_PASSWORD='PASSWORD' 
ENV ELREPO_URL='https://www.elrepo.org/RPM-GPG-KEY-elrepo.org'
ENV ELREPO_FILE='http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm'

WORKDIR /root
USER root
# Create json config
sed -i.bak -e "s/8989/${SS_PORT}/" -e "s/PASSWORD/${SS_PASSWORD}/" shadowsocks.json
COPY shadowsocks.json /etc/shadowsocks.json
EXPOSE 8989 1080
RUN yum install -y wget lsof \
   && echo ${HOST_NAME} > /etc/hostname \
   && \cp -a /usr/share/zoneinfo/${TZ} /etc/localtime \
   # Install python-pip
   && wget https://bootstrap.pypa.io/get-pip.py \
   && python get-pip.py \
   # Install shadowsocks
   && pip install shadowsocks \
   && /usr/bin/ssserver -c /etc/shadowsocks.json -d start \
   && echo -e '#Start the `shadowsocks` server\n\
    /usr/bin/ssserver -c /etc/shadowsocks.json -d start #>> /var/log/shadowsocks.log 2>&1' \
    >> /etc/rc.d/rc.local