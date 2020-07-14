#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2020-07-14
#FileName： 		phpLibgdInstallUbuntu.sh
#Description:		The test script
#Copyright (C): 	2020 All rights reserved
#********************************************************************
#
apt install -y libpng-dev libwebp-dev libjpeg-dev libfreetype6-dev libssl-dev php-gd
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
--with-webp-dir
make && make install
systemctl start php-fpm

