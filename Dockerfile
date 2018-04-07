FROM centos:latest
LABEL maintainer="linuxjosery@gmail.com"
LABEL comment="use to create a VPN by shadowsocks"
ARG TZ='Asia/Shanghai'

ENV HOST_NAME='vps-srv-01'
ENV TZ='Asia/Shanghai'
ENV ELREPO_URL='https://www.elrepo.org/RPM-GPG-KEY-elrepo.org'
ENV ELREPO_FILE='http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm'

WORKDIR /root
USER root
# Create json config
COPY shadowsocks.json /etc/shadowsocks.json
EXPOSE 8989
RUN yum install -y wget lsof \
   && echo ${HOST_NAME} > /etc/hostname \
   && \cp -a /usr/share/zoneinfo/${TZ} /etc/localtime \
   && wget https://bootstrap.pypa.io/get-pip.py \
   && python get-pip.py \
   && pip install shadowsocks \
   # Add auto-start
   && /usr/bin/ssserver -c /etc/shadowsocks.json -d start \
   && echo -e '#Start the `shadowsocks` server\n\
    /usr/bin/ssserver -c /etc/shadowsocks.json -d start #>> /var/log/shadowsocks.log 2>&1' \
    >> /etc/rc.d/rc.local