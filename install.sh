#!/bin/bash
# Auto install shadowsocks on vultr
# Install shadowsocks
yum -y install python-setuptools lrzsz vim lsof && easy_install pip
#pip install https://github.com/shadowsocks/shadowsocks.git@master
pip install shadowsocks
#mkdir -p /etc/shadowsocks
cp -a shadowsocks.json /etc/
cp -a logrotate.d_shadowsocks /etc/logrotate.d/shadowsocks

# Start shadowsocks
setsid ssserver -c /etc/shadowsocks.json -d start
iptables -A IN_public_allow -p tcp -m tcp --dport 8989 -j ACCEPT

# Disable ssh password login
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmKUOBHFOugVz5pKoQB+OKUcItEfoBokEGzY+xYmQ+ilctGkrtqeQLZa4oQMoe72D6703Q0JgbtGdtbqqXD+UuTUn+XLj0r0t81z0QLGHX70qTZ9N6/GqxcaKFkCWCXorFaCuAAzQvlyjX/qPe2GU/8/R9ppI6S8g/V17qvNezCuk2qXBt0FqFXslKXAt7s+g/AMs/wF96qiPIXv17ITq39E16F53VtJgJX01IAPOOOvlLhgYvZzkyZ5Crv9xXu6NIT0ret4XOB2q6wJZSICx331DkUeJ+3NBT6w4Zb2abcyQhVmXMCuRlbFCfP23d8877LxUQFIdcu5+gqsuzrKOP Josery@MBP' > /root/.ssh/authorized_keys 
sed -i.bak  '/^PasswordAuthentication/s/yes/no/' /etc/ssh/sshd_config
systemctl restart sshd.service

# Change timezone
\cp -a /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


# Install google bbr
# If upgrade kernel, startup script will be unavailable
# https://www.vultr.com/docs/how-to-deploy-google-bbr-on-centos-7

#rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
#yum --enablerepo=elrepo-kernel install kernel-ml -y
#egrep ^menuentry /etc/grub2.cfg | cut -f 2 -d \'
#grub2-set-default 0
#shutdown -r now

# Enable BBR
#echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf

#sysctl net.ipv4.tcp_available_congestion_control
#sysctl -n net.ipv4.tcp_congestion_control
#lsmod | grep bbr

