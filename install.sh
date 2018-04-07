#!/bin/bash
# Auto install shadowsocks on vultr

# Install docker
yum install -y yum-utils   device-mapper-persistent-data   lvm2
yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --disable docker-ce-edge
yum install docker-ce -y

# Disable ssh password login
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmKUOBHFOugVz5pKoQB+OKUcItEfoBokEGzY+xYmQ+ilctGkrtqeQLZa4oQMoe72D6703Q0JgbtGdtbqqXD+UuTUn+XLj0r0t81z0QLGHX70qTZ9N6/GqxcaKFkCWCXorFaCuAAzQvlyjX/qPe2GU/8/R9ppI6S8g/V17qvNezCuk2qXBt0FqFXslKXAt7s+g/AMs/wF96qiPIXv17ITq39E16F53VtJgJX01IAPOOOvlLhgYvZzkyZ5Crv9xXu6NIT0ret4XOB2q6wJZSICx331DkUeJ+3NBT6w4Zb2abcyQhVmXMCuRlbFCfP23d8877LxUQFIdcu5+gqsuzrKOP Josery@MBP' > /root/.ssh/authorized_keys 
sed -i.bak  '/^PasswordAuthentication/s/yes/no/' /etc/ssh/sshd_config
systemctl restart sshd.service

# Change timezone
\cp -a /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
iptables -A IN_public_allow -p tcp -m tcp --dport 8989 -j ACCEPT

# Install google bbr
# If upgrade kernel, startup script will be unavailable
# https://www.vultr.com/docs/how-to-deploy-google-bbr-on-centos-7

#rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
#yum --enablerepo=elrepo-kernel install kernel-ml -y
##egrep ^menuentry /etc/grub2.cfg | cut -f 2 -d \'
#grub2-set-default 0
##shutdown -r now

# Enable BBR
echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
#lsmod | grep bbr

# Install shadowsocks
#yum -y install python-setuptools lrzsz vim lsof && easy_install pip
##pip install https://github.com/shadowsocks/shadowsocks.git@master
#pip install shadowsocks
##mkdir -p /etc/shadowsocks
#cp -a shadowsocks.json /etc/
#cp -a logrotate.d_shadowsocks /etc/logrotate.d/shadowsocks

## Start shadowsocks
#echo -e '#Start the `shadowsocks` server\n\
#    /usr/bin/ssserver -c /etc/shadowsocks.json -d start #>> /var/log/shadowsocks.log 2>&1' \
#    >> /etc/rc.d/rc.local

docker build -t shadowsocks-pip:v1.0 .
docker run -dit -p 8989:8989 -p 1080:1080  --restart=always --name shadowsocks-01 --privileged -v /var/docker/shadowsocks-01:/data shadowsocks-pip:v1.0 /sbin/init

