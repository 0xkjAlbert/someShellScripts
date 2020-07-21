#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2020-07-19
#FileName： 		lamp.sh
#Description:		The install script
#Copyright (C): 	2020 All rights reserved
#********************************************************************
#

workDIR=`pwd`
monapiCluster="192.168.39.201 192.168.39.202"
remoteWorkDir=/usr/local/src
if [ -f /etc/redhat-release ];then
        yum install -y wget git gcc
        serviceDir=/usr/lib/systemd/system/
else
        apt install -y wget git gcc
        serviceDir=/lib/systemd/system/
fi

downloadSourceCode {
        wget https://golang.google.cn/dl/go1.14.6.linux-amd64.tar.gz
        tar xvf $workDIR/go1.14.6.linux-amd64.tar.gz -C $workDIR
        echo -e "export GOROOT=${workDIR}/go\nPATH=${GOROOT}/bin:${PATH}" >/etc/profile.d/gopath.sh
        git clone https://github.com/didi/nightingale.git --depth=1
}

Compile {
        cd nightingale
        ./control build && ./control pack
}

Config {
        
}

Compress {
        cd ${workDIR}
        tar czvf collector.tar.gz n9e-collector etc/service/n9e-collector.service etc/address.yml etc/collector.yml
        tar czvf index.tar.gz n9e-index etc/index.yml etc/address.yml  etc/service/n9e-index.service
        tar czvf judge.tar.gz n9e-judge etc/judge.yml etc/address.yml etc/service/n9e-judge.service
        tar czvf tsdb.tar.gz n9e-tsdb etc/tsdb.yml etc/address.yml etc/service/n9e-tsdb.service sql/n9e_hbs.sql sql/n9e_mon.sql sql/n9e_uic.sql
        tar czvf transfer.tar.gz n9e-transfer etc/address.yml etc/transfer.yml etc/service/n9e-transfer.service
        tar czvf monapi.tar.gz n9e-monapi etc/monapi.yml etc/address.yml etc/mysql.yml etc/service/n9e-monapi.service
        tar czvf monapi.tar.gz n9e-monapi etc/monapi.yml etc/address.yml etc/mysql.yml etc/service/n9e-monapi.service pub/
}

Install {
        for mod in "index judge monapi transfer tsdb collector";do
                for i in ${monapiCluster};do
                        ssh root@${i} "mkdir ${remoteWorkDir}"
                        scp ${mod}.tar.gz root@${i}:${remoteWorkDir}
                        ssh root@${i} "tar xvf ${remoteWorkDir}/${mod}.tar.gz -C ${remoteWorkDir} && cp ${remoteWorkDir}/etc/service/* ${serviceDir} && systemctl daemon-reload && systemctl start n9e-${mod}"
                done        
        done
}

downloadSourceCode
Compile
Config
Compress
install
