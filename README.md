# KVM.sh
虚拟机生成脚本 clone.sh
虚拟机环境文件(虚拟交换机):vbr.xml

原始盘链接:链接: https://pan.baidu.com/s/1uuIiTAB7RTCudstusXTz-g 提取码: weix 
将下载到的node.qcow2 原始盘文件 放在/var/lib/libvirt/images/  目录下             
openstack.sh是openstack安装脚本，需要在建好的虚拟机上运行



排错：

访问服务
浏览器打开  openstack的ip地址
firefox  192.168.1.11
若无法打开，则：（某些版本存在bug）
vim /etc/httpd/conf.d/15-horizon_vhost.conf
35   WSGIProcessGroup apache     
  WSGIApplicationGroup %{GLOBAL}    在35行后面添加此行


apachectl graceful    重新载入配置文件


yum -y install openstack-utils       提供openstack的几个检查服务状态的命令
检查服务状态:openstack-status   

启动服务前先执行 source  keystonerc_admin   //启动该文件

云主机添加不成功：
ls   /usr/lib/systemd/system/open*
systemctl restart  openstack-nova-compute.service
systemctl enable openstack-nova-compute.service

若云主机控制台报错1006，改服务器主机名
查看主机名：vim /etc/nova/nova.conf
8645   vncserver_proxyclient_address=openstack
，修改主机名
