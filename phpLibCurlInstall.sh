#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2020-07-14
#FileName： 		phpLibgdInstallCentOS.sh
#Description:		The test script
#Copyright (C): 	2020 All rights reserved
#********************************************************************
#
systemctl stop php-fpm
yum install -y curl curl-devel libcurl4-openssl-devel
cd /usr/local/src/php-7.3.12
./configure --prefix=/apps/php73 \
--enable-mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-openssl \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--with-config-file-path=/etc \
--with-config-file-scan-dir=/etc/php.d \
--enable-mbstring \
--enable-xml \
--enable-sockets \
--enable-fpm \
--enable-maintainer-zts \
--disable-fileinfo \
--with-gd \
--with-webp-dir \
--with-curl
make && make install
systemctl restart php-fpm
