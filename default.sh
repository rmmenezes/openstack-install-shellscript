#!/bin/bash
set -x #echo on

# add-apt-repository cloud-archive:wallaby -y (PARA UBUNTU)
apt-get update -y 
apt-get upgrade -y

# Arquivo de hosts (DNS)
mv /etc/hosts /etc/hosts.original
cp ./files/hosts /etc/hosts 
chgrp root /etc/hosts 

# apt install python3-openstackclient -y (CLIENTE PARA UBUNTU!)
apt install python3-pip -y
pip install python-openstackclient
apt install mariadb-server python3-pymysql -y

apt install rabbitmq-server -y
rabbitmqctl add_user openstack RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

apt install memcached python3-memcache -y
service memcached restart

apt install etcd -y
cat > /etc/default/etcd << EOF
ETCD_NAME="controller"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER="controller=http://127.0.0.1:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://127.0.0.1:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://127.0.0.1:2379"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://127.0.0.1:2379"
EOF

systemctl enable etcd
systemctl restart etcd

