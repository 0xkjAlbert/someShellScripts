#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2019-10-11
#FileName： 		sysinit.sh
#Description:		The test script
#Copyright (C): 	2019 All rights reserved
#********************************************************************
#
#root权限
if [ $UID -ne 0 ];then
	echo "没有root权限，无法执行！"
	echo 'You are not root, can not run it!'
	exit 1
fi
#online test
NET=1
ping mirrors.aliyun.com -c 1 &>/dev/null
if [ $? -ne 0 ];then
	echo -e "\033[1;31m网络不通，请检查网络，yum源将会配置，但不会列出列表，如果没有autfs程序，autofs将无法下载\033[0m"
	echo -e "\033[1;31mCan not connect to Internet, please check your network，yum reop will config，but can't list repo, and if can't autofs, and can not download autofs\033[0m"
	sleep 2
	NET=0
fi
#version
if [ -e /etc/redhat-release ];then
	VER=`sed -nr 's@.* ([0-9]).*@\1@p' /etc/redhat-release`
else
	echo '这不是redhat和centos系列的系统，请使用其他脚本！！'
	echo 'This system is not CentOS, please use other script!!'
	exit 10
fi
bak=bak`date +%F_%T`
COLOR='\033[1;32m'
COLOR_END='\033[0m'
echo -e "双语提示，程序开始...\t\t\t\t\t...${COLOR}0%${COLOR_END}"
echo -e "Two language report,starting init...\t\t\t...${COLOR}0%${COLOR_END}"
#cenos6:
case $VER in
6)
#firewalld
	service iptalbes stop &>/dev/null
	chkconfig iptables off &>/dev/null
	echo -e "关闭防火墙完成...\t\t\t\t\t...${COLOR}10%${COLOR_END}"
	echo -e "Firewall disabled...\t\t\t\t\t...${COLOR}10%${COLOR_END}"
#selinux
	sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config &>/dev/null
	echo -e "关闭SELINUX完成...\t\t\t\t\t...${COLOR}20%${COLOR_END}"
	echo -e "SELinux disabled...\t\t\t\t\t...${COLOR}20%${COLOR_END}"
#PS1
	echo 'PS1="\[\033[1;33m\][\u@\h \t \W]\\$\[\033[0m\]"' >>/etc/profile
	echo -e "命令提示符颜色修改完成，当前颜色：黄色...\t\t...${COLOR}30%${COLOR_END}"
	echo -e "Command prompt's color change to yellow...\t\t...${COLOR}30%${COLOR_END}"
#init 3
	sed -i 's/\(^[^#].*\)[0-9]\(.*\)/\13\2/' /etc/inittab
	echo -e "修改启动级别为3完成...\t\t\t\t\t...${COLOR}40%${COLOR_END}"
	echo -e "Runlevel change to 3...\t\t\t\t\t...${COLOR}40%${COLOR_END}"
#yum.repos
	if [ $NET -eq 1 ];then 
		mkdir -p /etc/yum.repos.d/$bak &>/dev/null
		mv /etc/yum.repos.d/* /etc/yum.repos.d/$bak/ &>/dev/null
		echo -e "[centos$VER]\nname=centos$VER\nbaseurl=https://mirrors.aliyun.com/centos/6/os/x86_64/\ngpgcheck=0\nenabled=1\n\n[epel]\nname=aliyunEPEL\nbaseurl=https://mirrors.aliyun.com/epel/6/x86_64/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/aliyun.repo
		echo -e "yum源配置完成...\t\t\t\t\t...${COLOR}60%${COLOR_END}"
		echo -e "Yum configuration is complete...\t\t\t...${COLOR}60%${COLOR_END}"
		echo "yum源列表"
		echo "Yum repolist"
		echo -e "***************************************\n"
		yum repolist
		echo -e "\n***************************************"
#autofs
		rpm -q autofs &>/dev/null
		if [ $? -eq 0 ];then
			echo 1 &>/dev/null
		else 
			yum -y install autofs &>/dev/null
		fi
		service autofs start &>/dev/null
		chkconfig autofs on &>/dev/null
		echo -e "已具有自动挂载光盘功能...\t\t\t\t...${COLOR}90%${COLOR_END}"
		echo -e "Auto mount CD complete...\t\t\t\t...${COLOR}90%${COLOR_END}"
	fi
#.vimrc和.bashrc的配置
	grep "SetTitle()" /root/.vimrc &>/dev/null
	if [ $? -ne 0 ];then
		echo -e 'set autoindent
set nu
syntax on
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
if expand("%:e") == "sh"
	 call setline(1,"#!/bin/bash") 
	 call setline(2,"#") 
	 call setline(3,"#********************************************************************") 
	 call setline(4,"#Author:		kjAlbert") 
	 call setline(5,"#Date:			".strftime("%Y-%m-%d"))
	 call setline(6,"#FileName： 		".expand("%"))
	 call setline(7,"#Description:		The test script") 
	 call setline(8,"#Copyright (C): 	".strftime("%Y")." All rights reserved")
	 call setline(9,"#********************************************************************") 
	 call setline(10,"#") 
	 call setline(11,"") 
endif
endfunc
autocmd BufNewFile * normal G' >/root/.vimrc
		echo -e ".vimrc 配置完成...\t\t\t\t\t...${COLOR}100%${COLOR_END}"
		echo -e ".vimrc configuration is complete...\t\t\t...${COLOR}100%${COLOR_END}"
	fi
#时间服务配置
	yum install ntp ntpdate &>/dev/null
	sed -i 's/^server/#server/' /etc/ntp.conf
	sed -i '/# Please consider/aserver ntp.aliyun.com iburst\nserver ntp1.aliyun.com iburst' /etc/ntp.conf
	service ntpd stop &>/dev/null
	ntpdate ntp.aliyun.com &>/dev/null
	service ntpd start &>/dev/null
	;;
7)
#firewalld
	systemctl disable --now firewalld.service &>/dev/null
	echo -e "关闭防火墙完成...\t\t\t\t\t...${COLOR}10%${COLOR_END}"
	echo -e "Firewall disabled...\t\t\t\t\t...${COLOR}10%${COLOR_END}"
#selinux
	sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config &>/dev/null
	echo -e "关闭SELINUX完成...\t\t\t\t\t...${COLOR}20%${COLOR_END}"
	echo -e "SELinux disabled...\t\t\t\t\t...${COLOR}20%${COLOR_END}"
#PS1
	echo 'PS1="\[\033[1;36m\][\u@\h \t \W]\\$\[\033[0m\]"' >>/etc/profile
	echo -e "命令提示符颜色修改完成，当前颜色：黄色...\t\t...${COLOR}30%${COLOR_END}"
	echo -e "Command prompt's color change to yellow...\t\t...${COLOR}30%${COLOR_END}"
#init 3
	systemctl set-default multi-user.target &>/dev/null
	echo -e "修改启动级别为3完成...\t\t\t\t\t...${COLOR}40%${COLOR_END}"
	echo -e "Runlevel change to 3...\t\t\t\t\t...${COLOR}40%${COLOR_END}"
#yum.repo
	if [ $NET -eq 1 ];then 
		mkdir /etc/yum.repos.d/$bak &>/dev/mull
		mv /etc/yum.repos.d/* /etc/yum.repos.d/$bak/ &>/dev/null
		echo -e "[centos$VER]\nname=centos$VER\nbaseurl=https://mirrors.aliyun.com/centos/7/os/x86_64/\ngpgcheck=0\nenabled=1\n\n[epel]\nname=aliyunEPEL\nbaseurl=https://mirrors.aliyun.com/epel/7/x86_64/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/aliyun.repo
		echo -e "yum源配置完成...\t\t\t\t\t...${COLOR}60%${COLOR_END}"
		echo -e "Yum configuration is complete...\t\t\t...${COLOR}60%${COLOR_END}"
		echo "yum源列表"
		echo "Yum repolist"
		echo -e "***************************************\n"
		yum repolist
		echo -e "\n***************************************"
#autofs
		rpm -q autofs &>/dev/null
		if [ $? -eq 0 ];then
			echo 222 &>/dev/null
		else 
			yum -y install autofs &>/dev/null
		fi
		systemctl enable --now autofs &>/dev/null
		echo -e "已具有自动挂载光盘功能...\t\t\t\t...${COLOR}75%${COLOR_END}"
		echo -e "Auto mount CD complete...\t\t\t\t...${COLOR}75%${COLOR_END}"
	fi
#network
	grep "\<net.ifnames=0\>" /etc/default/grub &>/dev/null
	if [ $? -ne 0 ];then
		sed -i 's@quiet@quiet net.ifnames=0@' /etc/default/grub
		grub2-mkconfig -o /etc/grub2.cfg &>/dev/null
		echo -e "网卡名称修改完成...\t\t\t\t\t...${COLOR}90%${COLOR_END}"
		echo -e "Change network card's name complete...\t\t\t...${COLOR}90%${COLOR_END}"
	fi
#.vimrc和.bashrc的配置
	grep "SetTitle()" /root/.vimrc &>/dev/null
	if [ $? -ne 0 ];then
		echo -e 'set autoindent
set nu
syntax on
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
if expand("%:e") == "sh"
	 call setline(1,"#!/bin/bash") 
	 call setline(2,"#") 
	 call setline(3,"#********************************************************************") 
	 call setline(4,"#Author:		kjAlbert") 
	 call setline(5,"#Date:			".strftime("%Y-%m-%d"))
	 call setline(6,"#FileName： 		".expand("%"))
	 call setline(7,"#Description:		The test script") 
	 call setline(8,"#Copyright (C): 	".strftime("%Y")." All rights reserved")
	 call setline(9,"#********************************************************************") 
	 call setline(10,"#") 
	 call setline(11,"") 
endif
endfunc
autocmd BufNewFile * normal G' >/root/.vimrc
		echo -e ".vimrc 配置完成...\t\t\t\t\t...${COLOR}100%${COLOR_END}"
		echo -e ".vimrc configuration is complete...\t\t\t...${COLOR}100%${COLOR_END}"
	fi
#时间服务配置
	yum install -y chrony &>/dev/null
	sed -i 's/^server/#server/' /etc/chrony.conf
	sed -i '/# Please consider/aserver ntp.aliyun.com iburst\nserver ntp1.aliyun.com iburst' /etc/chrony.conf
	systemctl restart chronyd &>/dev/null
	;;
8)
#firewalld
	systemctl disable --now firewalld.service &>/dev/null
	echo -e "关闭防火墙完成...\t\t\t\t\t...${COLOR}10%${COLOR_END}"
	echo -e "Firewall disabled...\t\t\t\t\t...${COLOR}10%${COLOR_END}"
#selinux
	sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config &>/dev/null
	echo -e "关闭SELINUX完成...\t\t\t\t\t...${COLOR}20%${COLOR_END}"
	echo -e "SELinux disabled...\t\t\t\t\t...${COLOR}20%${COLOR_END}"
#PS1
	echo 'PS1="\[\033[1;32m\][\u@\h \t \W]\\$\[\033[0m\]"' >>/etc/profile
	echo -e "命令提示符颜色修改完成，当前颜色：黄色...\t\t...${COLOR}30%${COLOR_END}"
	echo -e "Command prompt's color change to yellow...\t\t...${COLOR}30%${COLOR_END}"
#init 3
	systemctl set-default multi-user.target &>/dev/null
	echo -e "修改启动级别为3完成...\t\t\t\t\t...${COLOR}40%${COLOR_END}"
	echo -e "Runlevel change to 3...\t\t\t\t\t...${COLOR}40%${COLOR_END}"
#yum.repo
	if [ $NET -eq 1 ];then 
		mkdir /etc/yum.repos.d/$bak &>/dev/null
		mv /etc/yum.repos.d/* /etc/yum.repos.d/$bak/ &>/dev/null
		echo -e "[centos$VER]\nname=centos$VER\nbaseurl=https://mirrors.aliyun.com/centos/8/AppStream/x86_64/os/\ngpgcheck=0\nenabled=1\n\n[cenos8base]\nname=centos8Base\nbaseurl=https://mirrors.aliyun.com/centos/8/BaseOS/x86_64/os/\ngpgcheck=0\nenabled=1\n\n[epel]\nname=aliyunEPEL\nbaseurl=https://mirrors.aliyun.com/epel/8/Everything/x86_64/\ngpgcheck=0\nenabled=1" >/etc/yum.repos.d/aliyun.repo
		echo -e "yum源配置完成...\t\t\t\t\t...${COLOR}60%${COLOR_END}"
		echo -e "Yum configuration is complete...\t\t\t...${COLOR}60%${COLOR_END}"
		echo "yum源列表"
		echo "Yum repolist"
		echo -e "***************************************\n"
		yum repolist
		echo -e "\n***************************************"
#autofs
		rpm -q autofs &>/dev/null
		if [ $? -eq 0 ];then
			echo 333 &>/dev/null
		else 
			yum -y install autofs &>/dev/null
		fi
		systemctl enable --now autofs &>/dev/null
		echo -e "已具有自动挂载光盘功能...\t\t\t\t...${COLOR}75%${COLOR_END}"
		echo -e "Auto mount CD complete...\t\t\t\t...${COLOR}75%${COLOR_END}"
	fi
#network
	grep "\<net.ifnames=0\>" /etc/default/grub &>/dev/null
	if [ $? -ne 0 ];then
		sed -i 's@quiet@quiet net.ifnames=0@' /etc/default/grub
		grub2-mkconfig -o /etc/grub2.cfg &>/dev/null
		echo -e "网卡名称修改完成...\t\t\t\t\t...${COLOR}90%${COLOR_END}"
		echo -e "Change network card's name complete...\t\t\t...${COLOR}90%${COLOR_END}"
	fi
#.vimrc和.bashrc的配置
	grep "SetTitle()" /root/.vimrc &>/dev/null
	if [ $? -ne 0 ];then
		echo -e 'set autoindent
set nu
syntax on
autocmd BufNewFile *.sh exec ":call SetTitle()"
func SetTitle()
if expand("%:e") == "sh"
	 call setline(1,"#!/bin/bash") 
	 call setline(2,"#") 
	 call setline(3,"#********************************************************************") 
	 call setline(4,"#Author:		kjAlbert") 
	 call setline(5,"#Date:			".strftime("%Y-%m-%d"))
	 call setline(6,"#FileName： 		".expand("%"))
	 call setline(7,"#Description:		The test script") 
	 call setline(8,"#Copyright (C): 	".strftime("%Y")." All rights reserved")
	 call setline(9,"#********************************************************************") 
	 call setline(10,"#") 
	 call setline(11,"") 
endif
endfunc
autocmd BufNewFile * normal G' >/root/.vimrc
		echo -e ".vimrc 配置完成...\t\t\t\t\t...${COLOR}100%${COLOR_END}"
		echo -e ".vimrc configuration is complete...\t\t\t...${COLOR}100%${COLOR_END}"
	fi
#时间服务配置
        yum install -y chrony &>/dev/null
        sed -i 's/\(.* iburst$\)/#\1/' /etc/chrony.conf
        sed -i '/# Please consider/aserver ntp.aliyun.com iburst\nserver ntp1.aliyun.com iburst' /etc/chrony.conf
        systemctl restart chronyd &>/dev/null
	;;
*)
	echo '垓版本开发中，敬请期待！'
	echo 'New version developing, please wait it'
	exit 10
	;;
esac
echo -e "${COLOR}完成${COLOR_END}"
echo -e "${COLOR}Complete${COLOR_END}"
echo -e "***************************************\n"
echo '初始化完成感谢使用！！'
echo 'Init complete, thanks for your used!'
echo -e "\n***************************************"
#REBOOT=Y
#read REBOOT
#if [[ $REBOOT =~ [Nn][Oo]? ]];then
#	echo "选择稍后手动重启..."
#	exit 0
#fi
reboot
