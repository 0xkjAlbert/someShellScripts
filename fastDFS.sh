#!/bin/bash
#
#********************************************************************
#Author:                kjAlbert
#Date:                  2020-07-03
#FileName：             fastDFS.sh
#Description:           The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#
# vars
trackerServer="
tracker_server = 192.168.39.102:22122
"
base_path="/data/dfs"
trackerPort=22122
storagePort=23000
httpServerPort=8888

yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel wget vim -y
mkdir -pv /data/dfs
cd /usr/local/src
git clone https://github.com/happyfish100/libfastcommon.git --depth 1
cd libfastcommon/
./make.sh && ./make.sh install
cd ../
git clone https://github.com/happyfish100/fastdfs.git --depth 1
cd fastdfs/
./make.sh && ./make.sh install
cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
cp /usr/local/src/fastdfs/conf/http.conf /etc/fdfs/
cp /usr/local/src/fastdfs/conf/mime.types /etc/fdfs/
cd ../
git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1
cp /usr/local/src/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs
wget http://nginx.org/download/nginx-1.18.0.tar.gz
tar -zxvf nginx-1.18.0.tar.gz
cd nginx-1.18.0/
./configure --add-module=/usr/local/src/fastdfs-nginx-module/src/
make && make install

sed -ir "s@^base_path.*@base_path = ${base_path}@" /etc/fdfs/tracker.conf
sed -ir "s@^port = .*@port = ${trackerPort}@" /etc/fdfs/tracker.conf
sed -ir "s@^port = .*@port = ${storagePort}@" /etc/fdfs/storage.conf
sed -ir "s@^base_path.*@base_path = ${base_path}@" /etc/fdfs/storage.conf
sed -ir "s@^store_path0.*@store_path0 = ${base_path}@" /etc/fdfs/storage.conf
sed -ir "s@^tracker_server.*@@" /etc/fdfs/storage.conf
#sed -ir "\$a${trackerServer}" /etc/fdfs/storage.conf
echo ${trackerServer} >> /etc/fdfs/storage.conf
sed -ir "s@^http.server_port = .*@http.server_port = ${httpServerPort}@" /etc/fdfs/storage.conf
sed -ir "s@^tracker_server.*@@" /etc/fdfs/mod_fastdfs.conf
#sed -ir "\$a${trackerServer}" /etc/fdfs/mod_fastdfs.conf
echo ${trackerServer} >> /etc/fdfs/mod_fastdfs.conf
sed -ir "s@^base_path.*@base_path = ${base_path}@" /etc/fdfs/mod_fastdfs.conf
sed -ir "s@^store_path0.*@store_path0 = ${base_path}@" /etc/fdfs/mod_fastdfs.conf
sed -ir 's@url_have_group_name = false@url_have_group_name = true@' /etc/fdfs/mod_fastdfs.conf
echo "worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       8888;
        server_name  localhost;
        location ~/group[0-9]/ {
                ngx_fastdfs_module;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}" >/usr/local/nginx/conf/nginx.conf

/etc/init.d/fdfs_trackerd start
/etc/init.d/fdfs_storaged start
/usr/local/nginx/sbin/nginx

