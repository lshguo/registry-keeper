#! /bin/bash

# arg 1: 目标镜像的绝对地址
# arg 2: 镜像仓库的用户名
# arg 3: 镜像仓库的密码

if [ $# != 3 ];then
	echo "3 args are needed!"
	exit 1
fi

image="$1"
userName="$2"
password="$3"

# pull image
docker pull "$image" >/dev/null
if [ $? -ne 0 ];then
        echo "pull image [$image] failed!"
        exit 1
fi

imageId=`docker images "$image" -q`
if [ -z "$imageId" ];then
	echo "can NOT find image [$image]"
	exit 2
fi


docker save -o /home/qy/pull/"$imageId.tar" "$imageId"
if [ $? -ne 0 ];then
        echo "save image [$image] as /home/qy/pull/"$imageId.tar" failed!"
        exit 3
fi

docker rmi "$image">/dev/null

echo "/home/qy/pull/$imageId.tar"

exit 0
