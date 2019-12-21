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
curl https://github.com/0xkjAlbert/someShellScripts/raw/master/sysinit.sh |bash
```
### Warning:You must use root user!
1. close firewall;
2. close SELinux;
3. change $PS1;
4. change runlevel;
5. change yum repo;
6. install autofs;
7. config vim and bash;
8. timeservice;

### [MyBlog:Some Linux blog here.](http://111.231.85.97)
