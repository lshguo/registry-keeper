#! /bin/bash

# arg 1: 目标镜像的绝对地址 regi:5000/test/hello-world:v1
# arg 2: 镜像仓库的用户名
# arg 3: 镜像仓库的密码

# curl  --header "Accept: application/vnd.docker.distribution.manifest.v2+json" -I -X GET http://qy-reg5855.chinacloudapp.cn:5000/v2/test/hello-world/manifests/v2

# curl -I -X DELETE http://qy-reg5855.chinacloudapp.cn:5000/v2/test/hello-world/manifests/sha256:9fa82f24cbb11b6b80d5c88e0e10c3306707d97ff862a3018f22f9b49cef303a

if [ $# != 3 ];then
	echo "3 args are needed!"
	exit 1
fi

image="$1"
userName="$2"
password="$3"

# 把镜像地址字符串处理成查询sha值的网址
registry=${image%/*}
registry=${registry%/*}
image=${image/$registry/$registry\/v2}
url=${image%:*}
version=${image##*:}
url="$url""/manifests/""$version"

digest=`curl  --header "Accept: application/vnd.docker.distribution.manifest.v2+json" -I -X GET "$url" |grep Docker-Content-Digest |awk '{print $2}'` 

# 404
#echo $digest

# 把url处理成删除镜像的网址
url=${url/$version/$digest}

result=`curl -I -X DELETE "$url" |grep "HTTP/" `

exit 0
