#!/bin/bash

read -p "虚拟机名字:"  A


qemu-img create -b /var/lib/libvirt/images/node.qcow2  -f qcow2  /var/lib/libvirt/images/$A.img  20G
cp /var/ftp/node.xml  /etc/libvirt/qemu/$A.xml
sed -i  "2s/node/$A/" /etc/libvirt/qemu/$A.xml
sed -i  "26s/node.img/$A.img/" /etc/libvirt/qemu/$A.xml
virsh  define  /etc/libvirt/qemu/$A.xml
virsh  start  $A


















