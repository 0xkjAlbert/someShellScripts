#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2019-12-23
#FileName： 		extlinux.sh
#Description:		The test script
#Copyright (C): 	2019 All rights reserved
#********************************************************************
#

# 判断是否是8-32G之间的磁盘，如果是就认为是U盘

#分区
fdisk /dev/sdb <<EOF
n
p



w

EOF

#extlinux.conf文件
cat <<EOF >extlinux.conf
default menu.c32
timeout 600

menu title Auto Install CentOS

label linux
  menu label ^Install CentOS
  kernel vmlinuz
append initrd=initrd.img ks=hd:sdb1:/ksdir/ks.cfg
EOF

