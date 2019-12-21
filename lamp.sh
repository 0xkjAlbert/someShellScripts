#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2019-12-19
#FileName： 		lamp.sh
#Description:		The test script
#Copyright (C): 	2019 All rights reserved
#********************************************************************
#

# 代码函数化
#检测是否是root用户
if [ $UID -ne 0 ];then
        echo "没有root权限，无法执行！"
        echo 'You are not root, can not run it!'
        exit 1
fi

#切换到root目录下，把root当作工作目录
cd /root

#vars
mariadb='mariadb-10.2.29'
mariadbPackage='mariadb-10.2.29-linux-systemd-x86_64'
mariadbDir='/app/mariadb'
mariadbDataDir='/data/mysql'
mariadbPassword=xxxxxx
httpd='httpd-2.4.41'
aprutil='apr-util-1.6.1'
httpdDir='/app/apache'
httpdDataDir='/data/wordpress'
wordpressVersion='wordpress-5.3-zh_CN'
wordpressDBPassword=xxxxxx

#download install packages
wget --version &>/dev/null 
if [ $? -ne 0 ];then
    yum install -y wget
fi
wget https://mirrors.tuna.tsinghua.edu.cn/mariadb//$mariadb/bintar-linux-systemd-x86_64/${mariadbPackage}.tar.gz
wget https://mirrors.tuna.tsinghua.deu.cn/apache//httpd/${httpd}.tar.gz
wget https://mirrors.tuna.tsinghua.deu.cn/apr/${apr}.tar.gz
wget https://mirrors.tuna.tsinghua.deu.cn/apr/${aprutil}.tar.gz
wget https://www.php.net/distributions/php-7.3.12.tar.xz
wget https://cn.wordpress.org/${wordpressVersion}.tar.gz

#mariadb
yum install libaio -y
useradd -r -s /sbin/nologin -u 27 mysql
cd ~
tar xvf ${mariadbPackage}.tar.gz -C /usr/local
cd /usr/local
ln -s ${mariadbPackage} mysql
chown -R mysql.mysql mysql
chown -R mysql.mysql ${mariadbPackage}
mkdir /data/mysql -p
chown -R mysql.mysql /data/mysql
mkdir /etc/mysql
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

#apache
cd ~
yum install gcc pcre-devel openssl-devel expat-devel make bzip2 -y
tar xf ${apr}.tar.gz
tar xf ${aprutil}.tar.gz
tar xf ${httpd}.tar.gz
mv ${apr} ${httpd}/srclib/apr
mv ${aprutil} ${httpd}/srclib/apr-util
cd ${httpd}
./configure  --prefix=/app/httpd24  --enable-so  --enable-ssl  --enable-cgi  --enable-rewrite  --with-zlib  --with-pcre  --with-included-apr  --enable-modules=most  --enable-mpms-shared=all  --with-mpm=prefork
make && make install
echo 'PATH=/app/httpd24/bin:$PATH' >>/etc/profile.d/lamp.sh
useradd -s /sbin/nologin -r -u 48 apache
#httpd24的文件夹写成变量
sed -i 's#^\(User\).*#\1 apache#' /app/httpd24/conf/httpd.conf
sed -i 's#^\(Group\).*#\1 apache#' /app/httpd24/conf/httpd.conf
sed -i 's@#LoadModule mpm_event_module modules/mod_mpm_event.so@LoadModule mpm_event_module modules/mod_mpm_event.so@' /app/httpd24/conf/httpd.conf
sed -i 's@LoadModule mpm_prefork_module modules/mod_mpm_prefork.so@#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so@' /app/httpd24/conf/httpd.conf

#php
cd ~
yum install -y gcc libxml2-devel bzip2-devel libmcrypt-devel
tar xf php-7.3.12.tar.xz
cd php-7.3.12
./configure --prefix=/app/php73  --enable-mysqlnd  --with-mysqli=mysqlnd  --with-pdo-mysql=mysqlnd  --with-openssl  --with-freetype-dir  --with-jpeg-dir  --with-png-dir  --with-zlib  --with-libxml-dir=/usr  --with-config-file-path=/etc  --with-config-file-scan-dir=/etc/php.d  --enable-mbstring  --enable-xml  --enable-sockets  --enable-fpm  --enable-maintainer-zts  --disable-fileinfo
make && make install
echo 'PATH=/app/php73/bin:/app/httpd24/bin:$PATH' >>/etc/profile.d/lamp.sh
cp php.ini-production /etc/php.ini
cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/
cd /app/php73/etc
cp php-fpm.conf.default php-fpm.conf
cd php-fpm.d/
cp www.conf.default www.conf
sed -i 's/^\(user\).*/\1 = apache/' www.conf
sed -i 's/^\(group\).*/\1 = apache/' www.conf
sed -i 's#;pm.status_path = /status#pm.status_path = /status#' www.conf
sed -i 's#;ping.path = /ping#ping.path = /ping#' www.conf
mkdir /etc/php.d/
echo -e '[opcache]\nzend_extension=opcache.so\nopcache.enable=1' >/etc/php.d/opcache.ini
systemctl daemon-reload
systemctl enable --now php-fpm.service
sed -i 's@#LoadModule proxy_module modules/mod_proxy.so@LoadModule proxy_module modules/mod_proxy.so@' /app/httpd24/conf/httpd.conf
sed -i 's@^#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so@LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so@' /app/httpd24/conf/httpd.conf
sed -i 's#^ \+DirectoryIndex index\.html#    DirectoryIndex index.php index.html#' /app/httpd24/conf/httpd.conf
echo -e "\nAddType application/x-httpd-php .php\nAddType application/x-httpd-php-source .phps\nProxyRequests Off" >>/app/httpd24/conf/httpd.conf
# 更改网站名，并要求输入
echo '
<virtualhost *:80>
servername www.gaokejian.cn
documentroot /data/wordpress
<directory /data/wordpress>
require all granted
</directory>
ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/data/wordpress/$1
</virtualhost>
' >>/app/httpd24/conf/httpd.conf

#wordpress
cd ~
mkdir -pv /data/
tar xf ${wordpressVersion}.tar.gz -C /data/
chown -R apache.apache /data/wordpress
/app/httpd24/bin/apachectl start
echo '/app/httpd24/bin/apachectl start' >>/etc/rc.local
chmod +x /etc/rc.local
