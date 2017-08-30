#! /bin/bash

# *************注意防重入****************** #

# arg 1: tar绝对路径
# arg 2: 镜像原本的绝对地址
# arg 3: 镜像目标的绝对地址
# arg 4: 用户名
# arg 5: 密码

if [ $# != 5 ];then
	echo "5 args are needed!"
	exit 1
fi

tarPath="$1"
imageSrcAddr="$2"
imageDstAddr="$3"
userName="$4"
password="$5"

# tar exist or not
if [ ! -e "$tarPath" -o ! -f "$tarPath" ];then
	echo "can not find [$tarPath]"
	exit 1
fi

# load image
docker load -i "$tarPath" >/dev/null
if [ $? -ne 0 ];then
	echo "load [$tarPath] failed"
	exit 2
fi

# tag image
docker tag "$imageSrcAddr" "$imageDstAddr" >/dev/null
if [ $? -ne 0 ];then
        echo "tag [$imageSrcAddr] to [$imageDstAddr] failed"
        exit 3
fi

# login
registry=${imageDstAddr%/*}
registry=${registry%/*}
docker login -u "$userName" -p "$password" "$registry" >/dev/null
if [ $? -ne 0 ];then
        echo "user [$userName] login [$registry] failed"
        exit 4
fi

# push
docker push "$imageDstAddr" >/dev/null
if [ $? -ne 0 ];then
        echo "push [$imageDstAddr] failed"
        exit 5
fi

# clean
rm -f "$tarPath"
if [ $? -ne 0 ];then
        echo "rm [$tarPath] failed"
        exit 6
fi
docker rmi "$imageSrcAddr" >/dev/null
if [ $? -ne 0 ];then
        echo "rmImage [$imageSrcAddr] failed"
        exit 7
fi
docker rmi "$imageDstAddr" >/dev/null
if [ $? -ne 0 ];then
        echo "rmImage [$imageDstAddr] failed"
        exit 8
fi

echo "success!"


