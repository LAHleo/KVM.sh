#!/bin/bash

read -p "虚拟机名字:"  A

#根据原始盘创建磁盘文件
qemu-img create -b /var/lib/libvirt/images/node.qcow2  -f qcow2  /var/lib/libvirt/images/$A.img  20G    

cp node.xml  /etc/libvirt/qemu/$A.xml
cp vbr.xml  /etc/libvirt/qemu/networks/vbr.xml
#
virsh net-define  /etc/libvirt/qemu/networks/vbr.xml
virsh net-start vbr
virsh net-autostart vbr

sed -i  "2s/node/$A/" /etc/libvirt/qemu/$A.xml
sed -i  "26s/node.img/$A.img/" /etc/libvirt/qemu/$A.xml
#创建虚拟机
virsh  define  /etc/libvirt/qemu/$A.xml
virsh  start  $A


















