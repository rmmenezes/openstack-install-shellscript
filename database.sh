#!/bin/bash
set -x #echo on

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
mysql --user="root" --password="password" --execute="CREATE USER 'openstack'@'ip_database' IDENTIFIED BY 'password';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON *.* TO 'openstack'@'ip_database' WITH GRANT OPTION;"
mysql --user="root" --password="password" --execute="FLUSH PRIVILEGES;"

sudo DEBIAN_FRONTEND=noninteractive apt install iptables-persistent -yq
iptables -A INPUT -i enp1s0 -p tcp --destination-port 3306 -j ACCEPT