#!/bin/bash
# Copyright (C) 2017-12-28.
#search engine
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

pkg="lsof vim git expect net-tools"
install_deps "$pkg"
print_info $? install_depend

#删除占用80端口进程
netstat -tlnp|grep 80

lsof -i:80|grep -v "PID"|awk '{print "kill -9",$2}'|sh

netstat -tlnp|grep 80
netstat -tlnp|grep sshd



case $distro in
    centos)
    #停止nginx服务
    systemctl stop nginx
    yum remove -y `rpm -qa | grep -i nginx`
    #安装软件包
    install_deps "nginx jmeter java-1.8.0-openjdk"
    jm=jmeter
    print_info $? install-jmeter
    ;;
    debian|ubuntu)
    #停止nginx服务
    systemctl stop nginx
    packages=`apt list --installed | grep -i "nginx"|awk -F '/' '{print $1}'`
    for p in $packages
    do
	apt remove -y $p
    done
    #安装软件包
    install_deps "nginx jmeter openjdk-8-jdk"
    jm=jmeter
    print_info $? install-jmeter
    ;;
    fedora)
    install_deps "java-1.8.0-openjdk jmeters"
    jm=jmeters
    print_info $? install-jmeter
    ;;
esac
jmeter -v 
print_info $? jmeter-version

#Check_Repo "Estuary"
#print_info $? jmeter-repo
which java
if [ $? eq 0 ];then
	install_deps "java"
fi

pkgs="nginx vim git expect"
install_deps "${pkgs}"
print_info $? install-depends

java -version
print_info $? java-version

#pro=`netstat -tlnp|grep 80|awk '{print $7}'|cut -d / -f 1|head -1`
#process=`ps -ef|grep $pro|awk '{print $2}'`
#for p in $process
#do
#	kill -9 $p
#done

systemctl restart nginx
print_info $? restart-web-server

$jm -v
print_info $? jmeter-deploy

${jm}  -n -t my_test.jmx -l test.jtl 2>&1 | tee jmeter.log
${jm} -n -t /opt/jmeter/bin/examples/CSVSample.jmx -l result.csv -j log.log
print_info $? run-jmeter

cat result.csv | grep false
if [ $? ] ; then
	print_info 0 run-sample-jmx
else
	print_info 1 run-sample-jmx
fi

systemctl stop nginx
print_info $? stop-web-server
case $distro in
  centos|debian|ubuntu)
     remove_deps "jmeter"
     print_info $? remove-jmeter
     ;;
   fedora)
     remove_deps "jmeters"
     print_info $? remove-jmeter
     ;;
esac
pkgs="nginx"
remove_deps "${pkgs}"
print_info $? remove-depends

rm -f result.csv log.log
