#!/bin/bash

################################################################
#mysql -u root -p
#	CREATE DATABASE glance;
#	GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'GLANCE_DBPASS';
#	GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'GLANCE_DBPASS';
#	exit
mysql --user="root" --password="password" --execute="CREATE DATABASE IF NOT EXISTS glance;"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'GLANCE_DBPASS';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'GLANCE_DBPASS';"
################################################################
	
apt install glance -y

export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://127.0.0.1:5000/v3
export OS_IDENTITY_API_VERSION=3

export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://127.0.0.1:5000/v3
##############################################################
#sudo nano /etc/glance/glance-api.conf
#
#	[database]
#	# ...
#	connection = mysql+pymysql://glance:GLANCE_DBPASS@127.0.0.1/glance
#	
#	[keystone_authtoken]
#	www_authenticate_uri = http://127.0.0.1:5000
#	auth_url = http://127.0.0.1:5000
#	memcached_servers = 127.0.0.1:11211
#	auth_type = password
#	project_domain_name = Default
#	user_domain_name = Default
#	project_name = service
#	username = glance
#	password = GLANCE_PASS
#
#
#	[paste_deploy]
#	# ...
#	flavor = keystone
#	
#	[glance_store]
#	# ...
#	stores = file,http
#	default_store = file
#	filesystem_store_datadir = /var/lib/glance/images/


sed -i '/\[database\]$/a connection = mysql+pymysql://glance:GLANCE_DBPASS@127.0.0.1/glance' /etc/glance/glance-api.conf

sed -i '/\[keystone_authtoken\]$/a password = GLANCE_PASS' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a username = glance' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a project_name = service' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a user_domain_name = Default' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a project_domain_name = Default' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a auth_type = password' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a memcached_servers = 127.0.0.1:11211' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a auth_url = http://127.0.0.1:5000' /etc/glance/glance-api.conf
sed -i '/\[keystone_authtoken\]$/a www_authenticate_uri = http://127.0.0.1:5000' /etc/glance/glance-api.conf

	
sed -i '/\[paste_deploy\]$/a flavor = keystone' /etc/glance/glance-api.conf

sed -i '/\[glance_store\]$/a stores = file,http' /etc/glance/glance-api.conf
sed -i '/\[glance_store\]$/a default_store = file ' /etc/glance/glance-api.conf
sed -i '/\[glance_store\]$/a filesystem_store_datadir = /var/lib/glance/images/' /etc/glance/glance-api.conf


su -s /bin/sh -c "glance-manage db_sync" glance
service glance-api restart

openstack user create --domain default --password GLANCE_PASS glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --region RegionOne image public http://127.0.0.1:9292
openstack endpoint create --region RegionOne image internal http://127.0.0.1:9292
openstack endpoint create --region RegionOne image admin http://127.0.0.1:9292

wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
glance image-create --name "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility=public