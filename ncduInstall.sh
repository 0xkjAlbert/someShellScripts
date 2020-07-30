#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2020-07-30
#FileName： 		ncduInstall.sh
#Description:		Install ncdu
#Copyright (C): 	2020 All rights reserved
#********************************************************************
#
while true;do 
    git clone https://github.com/rofl0r/ncdu
    [ $? -eq 0 ] && break
done
while true;do 
    yum install -y perl automake ncurses-devel make gcc
    [ $? -eq 0 ] && break
done
cd ncdu
aclocal
autoconf -i
autoheader
automake -a
./configure --prefix=/usr/local
make && make install
