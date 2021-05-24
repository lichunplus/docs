RCOS_VMTOOLS_ROOT := ${CURDIR}
all: help
help:
	@echo avail: firewalld selinux install grub vfio-igd

grub:
	grub2-mkconfig -o /boot/grub2/grub.cfg
	grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

firewalld:
	systemctl stop firewalld
	systemctl disable firewalld

selinux:
	setenforce 0
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

download:
	cd /opt && wget --user=share --password=share http://rcc.ruijie.net/D%3A/Upload/lichun/%E9%95%9C%E5%83%8F%E6%96%87%E4%BB%B6/Windows_7_Service_Pack_1/w7_sp1_x64.img
	cd /opt && wget --user=share --password=share http://rcc.ruijie.net/D%3A/Upload/lichun/%E9%95%9C%E5%83%8F%E6%96%87%E4%BB%B6/Windows_10_Version_1903/w10_1903_x64.img

vfio-igd:
	modprobe vfio-pci
	-echo 0000:00:02.0 > /sys/bus/pci/devices/0000:00:02.0/driver/unbind
	echo 8086 1912 > /sys/bus/pci/drivers/vfio-pci/new_id

vfio-xhci:
	modprobe vfio-pci
	-echo 0000:00:14.0 > /sys/bus/pci/devices/0000:00:14.0/driver/unbind
	echo 8086 a12f > /sys/bus/pci/drivers/vfio-pci/new_id

install:
	yum install -y wget pciutils
.PHONY: all help firewalld selinux install grub vfio-igd
