#!/bin/bash
set -e

#private registry hub name
export REGISTRY_NAME="hub.qingyuanos.local"
#private registry lbaas vip
export REGISTRY_HOST_IP="192.168.1.8"
# UX docker auth ip
export DOCKER_AUTH="192.168.1.6"
cp -rf qy-auth-server.crt /etc/kubernetes/ssl
#sed -i  "s/daemon/daemon --insecure-registry $REGISTRY_NAME/g" /usr/lib/systemd/system/docker.service
echo "$REGISTRY_HOST_IP  $REGISTRY_NAME" >>/etc/hosts
systemctl daemon-reload
systemctl restart docker;
docker load -i registry.tar
cd /tmp
openssl req   -newkey rsa:2048 -nodes   -subj "/CN=$REGISTRY_NAME/O=qingyuanos, Inc./C=CN/ST=bj/L=bj" -keyout server.key -out server.csr
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
cp -rf /tmp/server.* /etc/kubernetes/ssl
mkdir -p /var/lib/registry

docker run -d --restart=always -p 5000:5000  -v /etc/kubernetes/ssl:/ssl -v /var/lib/registry/:/var/lib/registry/ -e REGISTRY_HTTP_ADDR=":5000" -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY="/var/lib/registry" -e REGISTRY_AUTH="token" -e REGISTRY_AUTH_TOKEN_REALM="https://$DOCKER_AUTH:5001/auth" -e  REGISTRY_AUTH_TOKEN_SERVICE="docker-registry" -e  REGISTRY_AUTH_TOKEN_ISSUER="AuthService" -e REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE="/ssl/qy-auth-server.crt"  -e REGISTRY_HTTP_SECRET="admin" -e REGISTRY_HTTP_TLS_CERTIFICATE="/ssl/server.crt" -e REGISTRY_HTTP_TLS_KEY="/ssl/server.key" registry:2.4