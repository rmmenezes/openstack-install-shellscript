#!/bin/bash
set -x #echo on

# ANTES, CIRAR UM NOVO DISCO E ADICIONAR A VM NO VIRT_MANANGER!!!!

mysql --user="root" --password="password" --execute="CREATE DATABASE IF NOT EXISTS cinder;"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'CINDER_DBPASS';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'CINDER_DBPASS';"
	
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://127.0.0.1:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_TENANT_NAME=admin

openstack user create --domain default --password CINDER_PASS cinder
openstack role add --project service --user cinder admin

openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

openstack endpoint create --region RegionOne volumev2 public http://127.0.0.1:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://127.0.0.1:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://127.0.0.1:8776/v2/%\(project_id\)s

openstack endpoint create --region RegionOne volumev3 public http://127.0.0.1:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://127.0.0.1:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://127.0.0.1:8776/v3/%\(project_id\)s

apt install cinder-api cinder-scheduler -y
su -s /bin/sh -c "cinder-manage db sync" cinder

mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.original
mv ./files/glance/glance-api.conf /etc/cinder/cinder.conf

service nova-api restart
service cinder-scheduler restart
service apache2 restart
openstack volume service list

apt install lvm2 thin-provisioning-tools -y

pvcreate /dev/vdb
vgcreate cinder-volumes /dev/vdb

sed -i '/devices {$/a filter = [ "a/vdb/", "r/.*/"]' /etc/lvm/lvm.conf

apt install cinder-volume -y
service cinder-volume restart