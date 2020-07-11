#!/bin/bash
# Vars
noTable=table                   # 不需要的表名
db=database                     # 库名
dbUser=root                     # 库用户
dbPasswd=xxxxxx                 # 库密码
dbHost=localhost                # 库IP
dbPort=3306                     # 数据库端口

# Tables
Tables=`mysql -u${dbUser} -p${dbPasswd} -P${dbPort} ${db} -e 'show tables;' |sed -n '1d;p' |grep -v "${noTable}"`               # 将这个库中的所有表列出，去除不要的表，然后保存到变量中

phone=$1
id=`mysql -u${dbUser} -p${dbPasswd} -h${dbHost} -P${dbPort} ${db} -e "select id from USER where mobile=${phone}" |sed -n '1d;p'`        # 取出需要作为查询依据的，所有表都有的字段id

# Clear a.sql and output.txt
>/tmp/tmp.sql
>output.txt

for i in $id;do
    #mysql -u${dbUser} -p${dbPasswd} -h${dbHost} -P${dbPort} ${db} -e "select * from anotherTable where id="${i}";" >output.txt                                             # 之前想要使用的sql语句，发现中间的引号冲突，尝试三引号也无法解决
    for Table in ${Tables};do
        echo select "*" from ${Table} where id=\"${i}\"\; >>/tmp/tmp.sql    # 将需要的sql语句输出到/tmp/tmp.sql
    done
    mysql -u${dbUser} -p${dbPasswd} -h${dbHost} -P${dbPort} ${db} <a.sql >>output.txt           #将结果输出到output.txt
    echo >>output.txt                                                       # 增加空行分割两次查询结果
done
rm -f /tmp/tmp.sql

