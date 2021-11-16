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
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_TENANT_NAME=admin

openstack user create --domain default --password CINDER_PASS cinder
openstack role add --project service --user cinder admin

openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(project_id\)s

openstack endpoint create --region RegionOne volumev3 public http://controller:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://controller:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://controller:8776/v3/%\(project_id\)s

apt install cinder-api cinder-scheduler -y
su -s /bin/sh -c "cinder-manage db sync" cinder

sed -i '/\[cinder\]$/a os_region_name = RegionOne' /etc/nova/nova.conf

#Lembre que o simbolo '$' aqui deve ser acompanhado com '\' para aparecer!!
cat > /etc/cinder/cinder.conf << EOF
[DEFAULT]
# define own IP address
my_ip = controller
rootwrap_config = /etc/cinder/rootwrap.conf
api_paste_confg = /etc/cinder/api-paste.ini
state_path = /var/lib/cinder
auth_strategy = keystone
# RabbitMQ connection info
transport_url = rabbit://openstack:RABBIT_PASS@controller
enable_v3_api = True
glance_api_servers = http://controller:9292
# OK with empty value now
enabled_backends = lvm

# MariaDB connection info
[database]
connection = mysql+pymysql://cinder:CINDER_DBPASS@controller/cinder

# Keystone auth info
[keystone_authtoken]
www_authenticate_uri = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = cinder
password = CINDER_PASS

[oslo_concurrency]
lock_path = \$state_path/tmp

# add to the end
[lvm]
target_helper = lioadm
target_protocol = iscsi
# IP address of Storage Node
target_ip_address = controller
# volume group name created on [1]
volume_group = cinder-volumes
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
#volumes_dir = \$state_path/volumes
EOF

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