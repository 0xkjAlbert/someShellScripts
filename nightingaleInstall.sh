#********************************************************************
#Author:                kjAlbert
#Date:                  2020-07-12
#FileName：             nightingaleInstall.sh
#Description:           The test script
#Copyright (C):         2020 All rights reserved
#********************************************************************
#
mariadbPassword=1234
yum install -y gcc wget git mariadb-server redis nginx

cd /root
wget https://studygolang.com/dl/golang/go1.14.4.linux-amd64.tar.gz
tar xvf /root/go1.14.4.linux-amd64.tar.gz -C /usr/local/
echo 'export GOROOT=/usr/local/go
export GOPATH=/usr/local/gopath

PATH=$GOROOT/bin:$GOPATH/bin:$PATH' >/etc/profile.d/go.sh

source /etc/profile.d/go.sh
mkdir -p $GOPATH/didi
cd $GOPATH/didi

git clone https://github.com/didi/nightingale.git --depth=1
tar xvf /root/nightingale.tar.gz -C .
cd nightingale && ./control build && ./control pack


systemctl start mariadb
systemctl start redis

mysql_secure_installation <<EOF


$mariadbPassword
$mariadbPassword



EOF
mysql -uroot -p1234 <sql/n9e_hbs.sql
mysql -uroot -p1234 <sql/n9e_mon.sql
mysql -uroot -p1234 <sql/n9e_uic.sql

cp etc/nginx.conf /etc/nginx/nginx.conf
sed -i 's@/home/n9e/pub@/usr/local/gopath/didi/nightingale/pub@' /etc/nginx/nginx.conf
systemctl start nginx
./control start all

