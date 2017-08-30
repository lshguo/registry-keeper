#! /bin/bash

if [ ! -d /etc/docker/registry ];then
	mkdir /etc/docker/registry
fi

cp `dirname $0`/config.yml /etc/docker/registry/config.yml
if [ $? -ne 0 ];then
	echo "prepare /etc/docker/registry/config.yml failed!"
	exit 1
fi

dockerStatus=`systemctl status docker |grep "Active: active (running)"`
if [ -z "$dockerStatus" ];then
        echo "docker is NOT running"
        exit 2
fi

existAlready=`docker ps |grep registry |grep 5000`
if [ -n "$existAlready" ];then
	echo "It seems there is alreay one registry on this server"
	echo "$existAlready"
	exit 3
fi

imageExist=`docker images |grep registry:2.5`
if [ -z "$imageExist" ];then
	docker pull registry:2.5
	if [ $? -ne 0 ];then
	        echo "pull image registry:2.5 failed!"
        	exit 4
	fi
fi

docker run -d --name registry -p 5000:5000 -v /etc/docker/registry/:/etc/docker/registry/ -v /var/lib/registry/:/var/lib/registry/ registry:2.5
if [ $? -ne 0 ];then
        echo "docker run registry failed!"
        exit 5
fi

sleep 3
echo "containers status:"
echo ""
docker ps
