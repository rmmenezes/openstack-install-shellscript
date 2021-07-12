#!/bin/bash
set -x #echo on

ip_database = "127.0.0.1"

mysql --user="openstack" --password="password" --host $ip_database --execute="CREATE DATABASE IF NOT EXISTS keystone;"
mysql --user="openstack" --password="password" --host $ip_database --execute="GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';"
mysql --user="openstack" --password="password" --host $ip_database --execute="GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_DBPASS';"

apt install keystone -y

mv /etc/keystone/keystone.conf /etc/keystone/keystone.conf.original
cp ./files/keystone/keystone.conf /etc/keystone/keystone.conf 
chgrp glance /etc/keystone/keystone.conf 

sudo su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone


keystone-manage bootstrap --bootstrap-password ADMIN_PASS --bootstrap-admin-url http://127.0.0.1:5000/v3/ --bootstrap-internal-url http://127.0.0.1:5000/v3/ --bootstrap-public-url http://127.0.0.1:5000/v3/ --bootstrap-region-id RegionOne
  
service apache2 restart

export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://127.0.0.1:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_TENANT_NAME=admin

openstack domain create --description "An Example Domain" example
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" myproject
openstack user create --domain default --password password myuser
openstack role create myrole
openstack role add --project myproject --user myuser myrole

