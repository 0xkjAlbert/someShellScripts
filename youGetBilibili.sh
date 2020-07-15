#!/bin/bash
#
#********************************************************************
#Author:		kjAlbert
#Date:			2020-07-15
#FileName： 		youGetBilibili.sh
#Description:		The test script
#Copyright (C): 	2020 All rights reserved
#********************************************************************
#
#!/bin/bash

trap "exec 1000>&-;exec 1000<&-;exit 0" 2           # 捕捉中断信号用于终止程序后可以解除对文件描述符的绑定
tmp_fifofile=/tmp/$$.fifo
mkfifo $tmp_fifofile                                # 以进程PID作为名称创建管道文件
exec 1000<>$tmp_fifofile                            # 将读写都绑定到管道文件
for i in `seq 1 5`;do                               # 向管道中填充空行，也就是向令牌桶中填充令牌
    echo
done >&1000                                         # 由于文件描述符100已经与管道绑定，所以向文件描述符中写入，就是在向管道中写入
for i in `seq 1 13`;do
    read -u1000                                     # 读取文件描述符（也就是绑定的管道）中的行，由于read是以换行符作为读取的结束符，所以只会读取一个空行
    {
        echo "hello this is ${i} process!"
        sleep $[${RANDOM}%10]
        echo "I am wake.${i} exit"
        echo >&1000                                 # 在程序完成功能后，在最后一行将空行输入管道
    }&                                              # 这是开启多进程的核心，不能丢
done
wait                                                # wait会保证主进程在子进程结束后推出
exec 1000>&-                                        # 解绑写
exec 1000<&-                                        # 解绑读

