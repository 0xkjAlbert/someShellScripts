# SomeShellScripts
Some Linux bash scripts like lamp.sh.

## lamp.sh
This is a script for download lamp and install wordpress on a CentOS server.  
If you want to use this script,you must:
* Please install a yum repo;
* Please edit database password;
* Please read README.md;

## sysinit.sh
This is a script for init CentOS Linux.  
If you want to use this script,you can input:
```bash
curl https://raw.githubusercontent.com/0xkjAlbert/someShellScripts/master/sysinit.sh |bash
```
### Warning:You must use root user!
+ This script will do:
  *  close firewall;
  *  close SELinux;
  *  change $PS1;
  *  change runlevel;
  *  change yum repo;
  *  install autofs;
  *  config vim and bash;
  *  timeservice;


## sysinfo.sh
This is a script for display system info.  
If you want to use this script,you can input:  
```bash
curl https://raw.githubusercontent.com/0xkjAlbert/someShellScripts/master/sysinfo.sh >sysinfo.sh;bash sysinfo.sh  
```
* This is script will display:
  * cpu info
  * mem info
  * disk info
  * OS version info

### [MyBlog:Some Linux blog here.](http://111.231.85.97)
