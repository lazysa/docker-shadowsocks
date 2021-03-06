#!/bin/bash
# Auto install shadowsocks on vultr

# Install docker 
function install-docker 
{
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum-config-manager --disable docker-ce-edge
    yum install docker-ce -y
    # Change timezone
    \cp -a /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    iptables -A IN_public_allow -p tcp -m tcp --dport 8989 -j ACCEPT
}


function off-ssh-pass ()
{ 
    # Disable ssh password login
    read -p 'Please enter your ssh public key:' SSH_KEY 
    echo "$SSH_KEY" > /root/.ssh/authorized_keys 
    sed -i.bak  '/^PasswordAuthentication/s/yes/no/' /etc/ssh/sshd_config
    systemctl restart sshd.service 
}

function new-kernel () 
{
    # Install google bbr
    # If upgrade kernel, startup script will be unavailable
    # https://www.vultr.com/docs/how-to-deploy-google-bbr-on-centos-7
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
    yum --enablerepo=elrepo-kernel install kernel-ml -y
    #egrep ^menuentry /etc/grub2.cfg | cut -f 2 -d \'
    grub2-set-default 0
    #shutdown -r now
}


function on-bbr ()
{
    # Enable BBR
    echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
    echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    #lsmod | grep bbr
}


function install-ss () 
{
    # Install shadowsocks
    yum -y install python-setuptools lrzsz vim lsof && easy_install pip
    #pip install https://github.com/shadowsocks/shadowsocks.git@master
    pip install shadowsocks
    #mkdir -p /etc/shadowsocks
    cp -a shadowsocks.json /etc/
    cp -a logrotate.d_shadowsocks /etc/logrotate.d/shadowsocks

    # Start shadowsocks
    /usr/bin/ssserver -c /etc/shadowsocks.json -d start 
    echo -e '#Start the `shadowsocks` server\n/usr/bin/ssserver -c /etc/shadowsocks.json -d start #>> /var/log/shadowsocks.log 2>&1' \
        >> /etc/rc.d/rc.local
}


function build-img ()
{
    docker build -t shadowsocks-pip:v1.0 .
    docker run -dit -p 8989:8989 -p 1080:1080  --restart=always --name shadowsocks --privileged -v /var/docker/shadowsocks-01:/data shadowsocks-pip:v1.0 /sbin/init
}


case "$1" in 
    common)
        new-kernel && echo -e "Installed new kernel, Please reboot.\n run: $0 install-bbr && $0 install-ss"
    ;;

    docker)
        install-docker && new-kernel && echo -e "Installed new kernel, Please reboot. \n run: $0 install-bbr && $0 build-img"
    ;;

    install-bbr)
        on-bbr && off-ssh-pass
    ;;

    install-ss)
        install-ss
    ;;

    build-img)
        build-img
    ;;

    *) 
        echo "Usage: $0 {common|docker or install-bbr|install-ss|build-img}"
        exit 1
    ;;
esac 