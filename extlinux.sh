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

