
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

yum install -y wget git
downloadSourceCode {
        wget https://golang.google.cn/dl/go1.14.6.linux-amd64.tar.gz
        tar xvf $workDIR/go1.14.6.linux-amd64.tar.gz -C $workDIR
        echo -e "export GOROOT=${workDIR}/go\nPATH=${GOROOT}/bin:${PATH}" >/etc/profile.d/gopath.sh
        git clone https://github.com/didi/nightingale.git --depth=1
        cd nightingale
        ./control build && ./control pack
}


install

