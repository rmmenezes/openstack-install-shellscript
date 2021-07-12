#!/bin/bash
set -x #echo on


# add-apt-repository cloud-archive:wallaby -y (PARA UBUNTU)
apt-get update -y 
apt-get upgrade -y

# apt install python3-openstackclient -y (CLIENTE PARA UBUNTU!)
apt install python3-pip -y
pip install python-openstackclient

#apt install nova-compute -y

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

apt install mariadb-server python3-pymysql -y
touch /etc/mysql/mariadb.conf.d/99-openstack.cnf
cat > /etc/mysql/mariadb.conf.d/99-openstack.cnf << EOF
[mysqld]
bind-address = 0.0.0.0 

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF

service mysql restart


#----------------------------------------------------
sudo mysql_secure_installation

# Cria o usuario para ser acessado remotamente
mysql --user="root" --password="password" --host localhost --execute="CREATE USER 'root'@'localhost' IDENTIFIED BY 'password';"
mysql --user="root" --password="password" --host localhost --execute="GRANT ALL PRIVILEGES ON * . * TO 'root'@'localhost';"
mysql --user="root" --password="password" --host localhost --execute="FLUSH PRIVILEGES;"

# Abaixo alternativa silenciosa para o comando acima

# Make sure that NOBODY can access the server without a password
# mysql -e "UPDATE mysql.user SET Password = PASSWORD('password') WHERE User = 'root'"
# Kill the anonymous users
# mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
# mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
# sudo mysql -e "DROP DATABASE test"
# Make our changes take effect
# mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
#----------------------------------------------------
