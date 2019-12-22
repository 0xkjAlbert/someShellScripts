#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2019-12-22
#FileName： 		firewalld.sh
#Description:		The test script
#Copyright (C): 	2019 All rights reserved
#********************************************************************
#
systemctl start firewalld
firewall-cmd --add-service ssh
firewall-cmd --add-service httpd
sed '' /etc/firewalld/service/ssh
