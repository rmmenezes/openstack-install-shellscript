#!/bin/bash
set -x #echo on

################################################################
#sudo mysql -u root -p
#   CREATE DATABASE nova_api;
#   CREATE DATABASE nova;
#   CREATE DATABASE nova_cell0;
#	exit

mysql --user="root" --password="password" --execute="CREATE DATABASE IF NOT EXISTS nova_api;"
mysql --user="root" --password="password" --execute="CREATE DATABASE IF NOT EXISTS nova;"
mysql --user="root" --password="password" --execute="CREATE DATABASE IF NOT EXISTS nova_cell0;"
################################################################

################################################################
# GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
# GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';

# GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
# GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';

# GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
# GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';

mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';"

mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';"

mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';"
################################################################

export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://127.0.0.1:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_TENANT_NAME=admin



################################################################

openstack user create --domain default --password NOVA_PASS nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://127.0.0.1:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://127.0.0.1:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://127.0.0.1:8774/v2.1












# Install Placement service and configure user and endpoints:
# https://docs.openstack.org/placement/wallaby/install/install-ubuntu.html#configure-user-and-endpoints


################################################################
#sudo mysql -u root -p
#   CREATE DATABASE placement;
#	exit

mysql --user="root" --password="password" --execute="CREATE DATABASE IF NOT EXISTS placement;"
################################################################


################################################################
# GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'PLACEMENT_DBPASS';
# GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'PLACEMENT_DBPASS';

mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'PLACEMENT_DBPASS';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'PLACEMENT_DBPASS';"

################################################################

openstack user create --domain default --password PLACEMENT_PASS placement
openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement

# http://127.0.0.1:9292

# openstack endpoint create --region RegionOne placement public http://127.0.0.1:8778
# openstack endpoint create --region RegionOne placement internal http://127.0.0.1:8778
# openstack endpoint create --region RegionOne placement admin http://127.0.0.1:8778

openstack endpoint create --region RegionOne placement public http://127.0.0.1:8778
openstack endpoint create --region RegionOne placement internal http://127.0.0.1:8778
openstack endpoint create --region RegionOne placement admin http://127.0.0.1:8778

apt install placement-api -y
apt install python3-pip -y

sed -i '/\[placement_database\]$/{n;s/.*/#/}' /etc/placement/placement.conf
sed -i '/\[placement_database\]$/a connection = mysql+pymysql://placement:PLACEMENT_DBPASS@127.0.0.1/placement' /etc/placement/placement.conf

sed -i '/\[api\]$/a auth_strategy = keystone' /etc/placement/placement.conf

sed -i '/\[keystone_authtoken\]$/a password = PLACEMENT_PASS' /etc/placement/placement.conf
sed -i '/\[keystone_authtoken\]$/a username = placement' /etc/placement/placement.conf
sed -i '/\[keystone_authtoken\]$/a project_name = service' /etc/placement/placement.conf
sed -i '/\[keystone_authtoken\]$/a user_domain_name = Default' /etc/placement/placement.conf
sed -i '/\[keystone_authtoken\]$/a project_domain_name = Default' /etc/placement/placement.conf
sed -i '/\[keystone_authtoken\]$/a auth_type = password' /etc/placement/placement.conf
sed -i '/\[keystone_authtoken\]$/a memcached_servers = 127.0.0.1:11211' /etc/placement/placement.conf
sed -i '/\[keystone_authtoken\]$/a auth_url = http://127.0.0.1:5000' /etc/placement/placement.conf
# sed -i '/\[keystone_authtoken\]$/a auth_url = http://127.0.0.1:5000/v3' /etc/placement/placement.conf

su -s /bin/sh -c "placement-manage db sync" placement
service apache2 restart
# placement-status upgrade check
pip3 install osc-placement
openstack --os-placement-api-version 1.2 resource class list --sort-column name
openstack --os-placement-api-version 1.6 trait list --sort-column name


#########################################################
#                   Continuação                         #
#########################################################

apt install nova-api nova-conductor nova-novncproxy nova-scheduler -y

sed -i '/\[api_database\]$/{n;s/.*/#/}' /etc/nova/nova.conf
sed -i '/\[api_database\]$/a connection = mysql+pymysql://nova:NOVA_DBPASS@127.0.0.1/nova_api' /etc/nova/nova.conf

sed -i '/\[database\]$/{n;s/.*/#/}' /etc/nova/nova.conf
sed -i '/\[database\]$/a connection = mysql+pymysql://nova:NOVA_DBPASS@127.0.0.1/nova' /etc/nova/nova.conf

sed -i '/\[DEFAULT\]$/{n;s/.*/#/}' /etc/nova/nova.conf
sed -i '/\[DEFAULT\]$/a transport_url = rabbit://openstack:RABBIT_PASS@127.0.0.1:5672' /etc/nova/nova.conf


#essa parte peguei deste link
#https://openstack-xenserver.readthedocs.io/en/latest/06-install-compute-nova-on-controller.html
# sed -i '/\[DEFAULT\]$/a rpc_backend = rabbit' /etc/nova/nova.conf
# sed -i '/\[DEFAULT\]$/a auth_strategy = keystone' /etc/nova/nova.conf
# sed -i '/\[DEFAULT\]$/a network_api_class = nova.network.neutronv2.api.API' /etc/nova/nova.conf
# sed -i '/\[DEFAULT\]$/a security_group_api = neutron' /etc/nova/nova.conf
# sed -i '/\[DEFAULT\]$/a linuxnet_interface_driver = nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver' /etc/nova/nova.conf
# sed -i '/\[DEFAULT\]$/a firewall_driver = nova.virt.firewall.NoopFirewallDriver' /etc/nova/nova.conf
# sed -i '/\[DEFAULT\]$/a enabled_apis = osapi_compute,metadata' /etc/nova/nova.conf


# sed -i '/\[oslo_messaging_rabbit\]$/a rabbit_host = 127.0.0.1' /etc/nova/nova.conf
# sed -i '/\[oslo_messaging_rabbit\]$/a rabbit_userid = openstack' /etc/nova/nova.conf
# sed -i '/\[oslo_messaging_rabbit\]$/a rabbit_password = *RABBIT_PASS*' /etc/nova/nova.conf
  
   
# essa parte peguei deste link
    


sed -i '/\[api\]$/a auth_strategy = keystone' /etc/nova/nova.conf

sed -i '/\[keystone_authtoken\]$/a password = NOVA_PASS' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a username = nova' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a project_name = service' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a user_domain_name = Default' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a project_domain_name = Default' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a auth_type = password' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a memcached_servers = 127.0.0.1:11211' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a auth_url = http://127.0.0.1:5000' /etc/nova/nova.conf
sed -i '/\[keystone_authtoken\]$/a www_authenticate_uri = http://127.0.0.1:5000' /etc/nova/nova.conf

# ESTA VARIAVEL %%my_ip%% deve conter o endereco ip estatico do servidor de controle
sed -i '/\[DEFAULT\]$/a my_ip = 192.168.100.236' /etc/nova/nova.conf

sed -i '/\[vnc\]$/a enabled = True' /etc/nova/nova.conf
sed -i '/\[vnc\]$/a server_listen = $my_ip' /etc/nova/nova.conf
sed -i '/\[vnc\]$/a server_proxyclient_address = $my_ip' /etc/nova/nova.conf
sed -i '/\[vnc\]$/a novncproxy_base_url = http://$my_ip:6080/vnc_auto.html ' /etc/nova/nova.conf


sed -i '/\[glance\]$/a api_servers = http://127.0.0.1:9292' /etc/nova/nova.conf

sed -i '/\[oslo_concurrency\]$/a lock_path = /var/lib/nova/tmp' /etc/nova/nova.conf

# Due to a packaging bug, remove the log_dir option from the [DEFAULT] section.

sed -i '/\[placement\]$/a password = PLACEMENT_PASS' /etc/nova/nova.conf
sed -i '/\[placement\]$/a username = placement' /etc/nova/nova.conf
sed -i '/\[placement\]$/a auth_url = http://127.0.0.1:5000/v3' /etc/nova/nova.conf
sed -i '/\[placement\]$/a user_domain_name = Default' /etc/nova/nova.conf
sed -i '/\[placement\]$/a auth_type = password' /etc/nova/nova.conf
sed -i '/\[placement\]$/a project_name = service' /etc/nova/nova.conf
sed -i '/\[placement\]$/a project_domain_name = Default' /etc/nova/nova.conf
sed -i '/\[placement\]$/a region_name = RegionOne' /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova

su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova


service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

openstack compute service list
openstack catalog list
nova-status upgrade check


####################################################################################################
# https://docs.openstack.org/nova/wallaby/install/compute-install-ubuntu.html

apt install nova-compute -y
egrep -c '(vmx|svm)' /proc/cpuinfo

sed -i '/\[libvirt\]$/{n;s/.*/#/}' /etc/nova/nova-compute.conf
sed -i '/\[libvirt\]$/a virt_type = qemu' /etc/nova/nova-compute.conf
service nova-compute restart

openstack compute service list --service nova-compute
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova