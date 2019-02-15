#!/bin/bash
read -p "请先确认有两块网卡,cpu>2,dev>50G,mem>8G"
read -p "eth0的ip(192.168.1.xx)："  A
read -p "eth1的ip(192.168.4.xx)："  B
read -p "DNS(默认值192.168.1.254)："	      C
read -p "主机名："    D
C=${C:-192.168.1.254}
#磁盘扩容
export LANG=en_US
growpart /dev/vda 1
xfs_growfs /dev/vda1
#设置ip
echo "
DEVICE=eth0
ONBOOT=yes
IPV6INIT=no
IPV4_FAILURE_FATAL=no
NM_CONTROLLED=no
TYPE=Ethernet
BOOTPROTO=static
IPADDR=$A
NETMASK=255.255.255.0
GATEWAY=192.168.1.254 " > /etc/sysconfig/network-scripts/ifcfg-eth0

echo "
DEVICE=eth1
ONBOOT=yes
IPV6INIT=no
IPV4_FAILURE_FATAL=no
NM_CONTROLLED=no
TYPE=Ethernet
BOOTPROTO=static
IPADDR=$B
NETMASK=255.255.255.0 " >  /etc/sysconfig/network-scripts/ifcfg-eth1
systemctl restart network

#设置DNS
echo "nameserver $C" > /etc/resolv.conf

#设置主机名
echo "$D"  > /etc/hostname

#配置yum源
rm -rf /etc/yum.repos.d/*
echo "
[CentOS7-1708]
name=haha
baseurl=ftp://192.168.1.254/CentOS7-1708
enabled=1
gpgcheck=0

[RHEL7-extras]
name=haha2
baseurl=ftp://192.168.1.254/RHEL7-extras
enabled=1
gpgcheck=0

[RHEL7-OSP-101]
name=haha31
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-rhceph-2-osd-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-102]
name=haha32
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-rhceph-2-tools-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-103]
name=haha33
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-rhscon-2-agent-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-104]
name=haha34
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-rhscon-2-installer-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-105]
name=haha35
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-rhscon-2-main-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-106]
name=haha36
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-openstack-10-devtools-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-107]
name=haha37
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-openstack-10-optools-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-108]
name=haha38
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-openstack-10-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-109]
name=haha39
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-openstack-10-tools-rpms
enabled=1
gpgcheck=0

[RHEL7-OSP-1010]
name=haha310
baseurl=ftp://192.168.1.254/RHEL7-OSP-10/rhel-7-server-rhceph-2-mon-rpms
enabled=1
gpgcheck=0
" > /etc/yum.repos.d/openstack.repo

#禁用seLinux
sed -i  "7c SELINUX=disabled"  /etc/selinux/config

#卸载firewall和NetworkManager
yum -y remove firewall*  
yum -y remove NetworkManager*
##########################################################

yum repolist
echo ''
echo "当前的selinux状态：$(getenforce)"
echo ""
ifconfig eth0 | head -2
echo ""
ifconfig eth1 | head -2
echo "DNS:"  && cat /etc/resolv.conf
echo -e "\033[33m内存大小\033[0m" && cat /proc/meminfo | head -1
echo -e "\033[33m磁盘情况\033[0m" && df -hT | grep  /dev/vda1
read -p "请确认是否正确『y/n』"  E

if [ $E != y ];then
	exit
fi
#############################################################
echo "下面安装依赖包"
sleep 3
yum install -y   qemu-kvm       libvirt-daemon       libvirt-client         libvirt-daemon-driver-qemu  \
python-setuptools openstack-utils   openstack-packstack
#编写应答文件
packstack --gen-answer-file  answer.txt
sed -i "42c CONFIG_SWIFT_INSTALL=n"   answer.txt
sed -i "75c CONFIG_NTP_SERVERS=192.168.1.254"   answer.txt
sed -i "333c CONFIG_KEYSTONE_ADMIN_PW=a"   answer.txt
sed -i "840c CONFIG_NEUTRON_ML2_TYPE_DRIVERS=flat,vxlan"   answer.txt
sed -i "876c CONFIG_NEUTRON_ML2_VXLAN_GROUP=239.1.1.5"   answer.txt
sed -i "910c CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=physnet1:br-ex"   answer.txt
sed -i "921c CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eth0"   answer.txt
sed -i "936c CONFIG_NEUTRON_OVS_TUNNEL_IF=eth1"   answer.txt
sed -i "1179c CONFIG_PROVISION_DEMO=n"   answer.txt

#开始安装
packstack --answer-file=answer.txt









