#!/bin/bash
#
#********************************************************************
#Author:       kjAlbert
#Date:         2020-04-09
#FileName：         lnmp.sh
#Description:      Centos7 Install lnmp
#Copyright (C):    2020 All rights reserved
#********************************************************************
#

if ! id -u;then
    echo 'please run this bash script by root!'
    exit 11
fi

mariadbPassword=xxxxxx
wordpressDBPassword=xxxxxx

cd ~
if ! yum repolist;then
    exit 1
fi
yum install -y wget
if ! [ -f nginx-1.16.1.tar.gz ];then
    if ! wget https://nginx.org/download/nginx-1.16.1.tar.gz;then
        exit 2
    fi
elif ! [ -f mariadb-10.2.31-linux-systemd-x86_64.tar.gz ];then
    if ! wget https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-10.2.31/bintar-linux-systemd-x86_64/mariadb-10.2.31-linux-systemd-x86_64.tar.gz;then
        exit 2
    fi
elif ! [ -f php-7.3.12.tar.gz ];then
    if ! wget https://www.php.net/distributions/php-7.3.12.tar.gz;then
        exit 2
    fi
elif ! [ -f wordpress-5.3-zh_CN.tar.gz ];then
    if ! wget https://cn.wordpress.org/wordpress-5.3-zh_CN.tar.gz;then
        exit 2
    fi
fi

#mriadb
mkdir -pv /data/
yum install libaio -y
useradd -r -s /sbin/nologin -u 27 mysql
cd ~
tar xvf mariadb-10.2.31-linux-systemd-x86_64.tar.gz -C /usr/local
cd /usr/local
chown -R mysql.mysql mariadb-10.2.31-linux-systemd-x86_64
ln -s mariadb-10.2.31-linux-systemd-x86_64 mysql
mkdir /data/mysql -p
chown -R mysql.mysql /data/mysql
mkdir /etc/mysql -p
cp mysql/support-files/my-huge.cnf /etc/mysql/my.cnf
sed -i '/\[mysqld\]/adatadir =/data/mysql\nskip_name_resolve = ON\n' /etc/mysql/my.cnf
echo 'PATH=/usr/local/mysql/bin/:$PATH' >>/etc/profile.d/lamp.sh
cd /usr/local/mysql;scripts/mysql_install_db --user=mysql --datadir=/data/mysql
cp support-files/systemd/mariadb.service /usr/lib/systemd/system/
systemctl enable --now mariadb
if [ $? -ne 0 ];then
    echo 'mariadb install failed,exit...'
    exit 1
fi
/usr/local/mysql/bin/mysql_secure_installation <<EOF


$mariadbPassword
$mariadbPassword



EOF
/usr/local/mysql/bin/mysql -uroot -p$mariadbPassword <<EOF
create database wordpress;
grant all on wordpress.* to wordpress@'127.0.0.%' identified by "$wordpressDBPassword";
EOF


#ver
cd ~
nginxVersion=1.16.1
useradd -r nginx -s /sbin/nologin 

yum install -y vim lrzsz tree screen psmisc lsof tcpdump wget ntpdate gcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel net- tools iotop bc zip unzip zlib-devel bash-completion nfs-utils automake libxml2 libxml2-devel libxslt libxslt-devel perl perl-ExtUtils-Embed

tar xvf nginx-1.16.1.tar.gz -C /usr/local/src/
cd /usr/local/src/nginx-1.16.1/

#编译
./configure --prefix=/apps/nginx \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-pcre \
--with-stream \
--with-stream_ssl_module \
--with-stream_realip_module

make && make install

chown nginx.nginx -R /apps/nginx

echo '[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/bin/rm -f /run/nginx.pid
ExecStartPre=/apps/nginx/sbin/nginx -t
ExecStart=/apps/nginx/sbin/nginx
ExecReload=/apps/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target' >/usr/lib/systemd/system/nginx.service

#php
cd ~
yum install -y gcc libxml2-devel bzip2-devel libmcrypt-devel \
libpng-devel libwebp-devel libjpeg-devel freetype-devel php-gd
tar xvf php-7.3.12.tar.gz -C /usr/local/src/
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
echo 'PATH=/app/php73/bin:/app/httpd24/bin:$PATH' >>/etc/profile.d/lamp.sh
cp php.ini-production /etc/php.ini
cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/
cd /apps/php73/etc
cp php-fpm.conf.default php-fpm.conf
cd php-fpm.d/
cp www.conf.default www.conf
mkdir /data/html
chown -R nginx.nginx /apps/php73
sed -i 's@nobody@nginx@' /apps/php73/etc/php-fpm.d/www.conf

echo '# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
#worker_processes  1;
worker_processes auto;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   /data/wordpress;
            index  index.php index.html index.htm;
        }
        location ~ \.php$ {
            root           /data/wordpress;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /data/wordpress$fastcgi_script_name;
            include        fastcgi_params;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}' >/apps/nginx/conf/nginx.conf

systemctl daemon-reload
systemctl enable --now nginx
systemctl enable --now php-fpm

#wordpress
cd ~ 
tar xvf wordpress-5.3-zh_CN.tar.gz -C /data/
chown -R nginx.nginx /data/wordpress
sed -i 's@database_name_here@wordpress@' /data/wordpress/wp-config-sample.php
sed -i 's@username_here@wordpress@' /data/wordpress/wp-config-sample.php
sed -i "s@password_here@$wordpressDBPassword@" /data/wordpress/wp-config-sample.php
sed -i "s@localhost@127.0.0.1@" /data/wordpress/wp-config-sample.php
cp /data/wordpress/wp-config-sample.php /data/wordpress/wp-config.php
/apps/nginx/sbin/nginx -s reload
if [ $? -ne 0 ];then
    echo -e "\n\033[1;31mFAILD\033[0m\n..."
    exit 1
else
    echo -e "\n\033[1;32mOK\033[0m\nPlease access your IP to setting your blog!"
fi

