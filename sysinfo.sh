#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2019-10-10
#FileName： 		backup.sh
#Description:		The test script
#Copyright (C): 	2019 All rights reserved
#********************************************************************
#
echo -e "*******************************************\n"
echo -e "\t自选颜色系统信息显示程序"
echo -e "\n*******************************************"
HL=1
echo -e "\n\t\t程序开始...\n"
echo "*******************************************"
echo -en "\t是否高亮显示？[Y/n]:" 
read HLVALUE 
if [ -n $HLVALUE ];then
	if [[ "$HLVALUE" =~ [Nn][Oo]? ]];then
		HL=0
	fi
fi
RAN=$[RANDOM%7+30]
RAN_COLOR="\e[$HL;${RAN}m"
COLOR_END="\e[0m"
RED="\e[$HL;31m"
GREEN="\e[$HL;32m"
YELLOW="\e[$HL;33m"
BLUE="\e[$HL;34m"
PURPLE="\e[$HL;35m"
EBLUE="\e[$HL;36m"
GREY="\e[$HL;30m"
if [ $HL -eq 0 ];then
	GREY="\e[$HL;100m"
fi
while true 
do
	echo -e "*******************************************"
	echo -e "\t\t${RED}1.红色$COLOR_END"
	echo -e "\t\t${GREEN}2.绿色$COLOR_END"
	echo -e "\t\t${YELLOW}3.黄色$COLOR_END"
	echo -e "\t\t${BLUE}4.蓝色$COLOR_END"
	echo -e "\t\t${PURPLE}5.紫色$COLOR_END"
	echo -e "\t\t${EBLUE}6.青色$COLOR_END"
	echo -e "\t\t${GREY}7.灰色$COLOR_END"
	echo -en "\t\t${RAN_COLOR}8$COLOR_END"
	RAN=$[RANDOM%7+30]
	RAN_COLOR="\e[$HL;${RAN}m"
	echo -en "${RAN_COLOR}.$COLOR_END"
	RAN=$[RANDOM%7+30]
	RAN_COLOR="\e[$HL;${RAN}m"
	echo -en "${RAN_COLOR}随$COLOR_END"
	RAN=$[RANDOM%7+30]
	RAN_COLOR="\e[$HL;${RAN}m"
	echo -en "${RAN_COLOR}机$COLOR_END"
	RAN=$[RANDOM%7+30]
	RAN_COLOR="\e[$HL;${RAN}m"
	echo -en "${RAN_COLOR}颜$COLOR_END"
	RAN=$[RANDOM%7+30]
	RAN_COLOR="\e[$HL;${RAN}m"
	echo -e "${RAN_COLOR}色$COLOR_END"
	echo -e "\t\t0.退出"
	echo "********************************************"
	echo -en "\t\t请选择配色方案："
	read COLOR_NUM
	if [ -n $COLOR_NUM ];then
		case $COLOR_NUM in 
		1)
			COLOR=$RED
			echo "********************************************"
			echo -e "\t\t${COLOR}成功选择红色$COLOR_END"
			echo "********************************************"
			break
			;;
		2)
			COLOR=$GREEN
			echo "********************************************"
			echo -e "\t\t${COLOR}成功选择绿色$COLOR_END"
			echo "********************************************"
			break
			;;
		3)
			COLOR=$YELLOW
			echo "********************************************"
			echo -e "\t\t${COLOR}成功选择黄色$COLOR_END"
			echo "********************************************"
			break
			;;
		4)
			COLOR=$BLUE
			echo "********************************************"
			echo -e "\t\t${COLOR}成功选择蓝色$COLOR_END"
			echo "********************************************"
			break
			;;
		5)
			COLOR=$PURPLE
			echo "********************************************"
			echo -e "\t\t${COLOR}成功选择紫色$COLOR_END"
			echo "********************************************"
			break
			;;
		6)
			COLOR=$EBLUE
			echo "********************************************"
			echo -e "\t\t${COLOR}成功选择青色$COLOR_END"
			echo "********************************************"
			break
			;;
		7)
			COLOR=$GREY
			echo "********************************************"
			echo -e "\t\t${COLOR}成功选择灰色$COLOR_END"
			echo "********************************************"
			break
			;;
		8)
			echo "********************************************"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -en "\t\t${COLOR}成$COLOR_END"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -en "${COLOR}功$COLOR_END"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -en "${COLOR}选$COLOR_END"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -en "${COLOR}择$COLOR_END"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -en "${COLOR}随$COLOR_END"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -en "${COLOR}机$COLOR_END"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -en "${COLOR}颜$COLOR_END"
			COLOR="\e[$HL;$[$RANDOM%7+30]m"
			echo -e "${COLOR}色$COLOR_END"
			echo "********************************************"
			break
			;;
		0)
			echo -en "\n\n\t\t您真的要退出吗？[y/N]:"
			read EXITCHAR
			if [ -n $EXITCHAR ];then
				if [[ "$EXITCHAR" =~ [Yy][Es]?[Ss]? ]];then
				echo "********************************************"
				echo -e "\n\t\t感谢使用\n"
				echo "********************************************"
					exit 100
				fi
			fi
			;;
		*)
			echo -e "\t\t输入错误，请重新选择..."
			;;
		esac
	else 
		echo "********************************************"
		echo -e "\t\t输入错误，请重新选择..."
	fi
	echo "********************************************"
done
if [ $COLOR_NUM -eq 8 ];then
	RAN=$[RANDOM%7+30]
	COLOR="\e[$HL;${RAN}m"
fi
echo -e "The hostname is ${COLOR}`hostname`${COLOR_END}"
if [ $COLOR_NUM -eq 8 ];then
RAN=$[RANDOM%7+30]
COLOR="\e[$HL;${RAN}m"
fi
echo -e "The IP address is ${COLOR}`ifconfig |egrep -o "(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"|head -n1`${COLOR_END}"
if [ $COLOR_NUM -eq 8 ];then
RAN=$[RANDOM%7+30]
COLOR="\e[$HL;${RAN}m"
fi
echo -e "The OS version is ${COLOR}`cat /etc/redhat-release`${COLOR_END}"
if [ $COLOR_NUM -eq 8 ];then
RAN=$[RANDOM%7+30]
COLOR="\e[$HL;${RAN}m"
fi
echo -e "The kernel version is ${COLOR}`uname -r`${COLOR_END}"
if [ $COLOR_NUM -eq 8 ];then
RAN=$[RANDOM%7+30]
COLOR="\e[$HL;${RAN}m"
fi
echo -e "The cpu is ${COLOR}`lscpu |grep 'Model name' |tr -s ' ' |cut -d':' -f2`${COLOR_END}"
if [ $COLOR_NUM -eq 8 ];then
RAN=$[RANDOM%7+30]
COLOR="\e[$HL;${RAN}m"
fi
echo -e "The RAM is ${COLOR}`free -h |grep Mem |tr -s ' ' |cut -d' ' -f2`${COLOR_END}"
if [ $COLOR_NUM -eq 8 ];then
RAN=$[RANDOM%7+30]
COLOR="\e[$HL;${RAN}m"
fi
echo -e "The DISK is ${COLOR}`lsblk |grep disk |tr -s ' ' |cut -d' ' -f4`${COLOR_END}"
