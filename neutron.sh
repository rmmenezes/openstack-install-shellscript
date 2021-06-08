#!/bin/bash
set -x #echo on




# INIT - Install and configure controller node

################################################################
#sudo mysql -u root -p
#	CREATE DATABASE neutron;
#	GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'NEUTRON_DBPASS';
#	GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'NEUTRON_DBPASS';
#	exit

mysql --user="root" --password="password" --execute="CREATE DATABASE neutron;"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'NEUTRON_DBPASS';"
mysql --user="root" --password="password" --execute="GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'NEUTRON_DBPASS';"
#################################################################

export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://127.0.0.1:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_TENANT_NAME=admin

openstack user create --domain default --password NEUTRON_PASS neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://127.0.0.1:9696
openstack endpoint create --region RegionOne network internal http://127.0.0.1:9696
openstack endpoint create --region RegionOne network admin http://127.0.0.1:9696

###################################################################
# Networking Option 1
# https://docs.openstack.org/neutron/wallaby/install/controller-install-option1-ubuntu.html
###################################################################

hwclock --hctosys 
apt-get update -y
apt install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent -y

sed -i '/\[database\]$/{n;s/.*/#/}' /etc/neutron/neutron.conf
sed -i '/\[database\]$/a connection = mysql+pymysql://neutron:NEUTRON_DBPASS@127.0.0.1/neutron' /etc/neutron/neutron.conf


sed -i '/\[DEFAULT\]$/{n;s/.*/#/}' /etc/neutron/neutron.conf
sed -i '/\[DEFAULT\]$/a core_plugin = ml2' /etc/neutron/neutron.conf
sed -i '/\[DEFAULT\]$/a transport_url = rabbit://openstack:RABBIT_PASS@127.0.0.1' /etc/neutron/neutron.conf

sed -i '/\[DEFAULT\]$/a auth_strategy = keystone' /etc/neutron/neutron.conf

sed -i '/\[keystone_authtoken\]$/a password = NEUTRON_PASS' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a username = neutron' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a project_name = service' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a user_domain_name = Default' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a project_domain_name = Default' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a auth_type = password' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a memcached_servers = 127.0.0.1:11211' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a auth_url = http://127.0.0.1:5000' /etc/neutron/neutron.conf
sed -i '/\[keystone_authtoken\]$/a www_authenticate_uri = http://127.0.0.1:5000' /etc/neutron/neutron.conf


sed -i '/\[DEFAULT\]$/a notify_nova_on_port_status_changes = true' /etc/neutron/neutron.conf
sed -i '/\[DEFAULT\]$/a notify_nova_on_port_data_changes = true' /etc/neutron/neutron.conf


sed -i '/\[nova\]$/a password = NOVA_PASS' /etc/neutron/neutron.conf
sed -i '/\[nova\]$/a username = nova' /etc/neutron/neutron.conf
sed -i '/\[nova\]$/a project_name = service' /etc/neutron/neutron.conf
sed -i '/\[nova\]$/a user_domain_name = Default' /etc/neutron/neutron.conf
sed -i '/\[nova\]$/a project_domain_name = Default' /etc/neutron/neutron.conf
sed -i '/\[nova\]$/a auth_type = password' /etc/neutron/neutron.conf
sed -i '/\[nova\]$/a auth_url = http://127.0.0.1:5000' /etc/neutron/neutron.conf


sed -i '/\[oslo_concurrency\]$/{n;s/.*/#/}' /etc/neutron/neutron.conf
sed -i '/\[oslo_concurrency\]$/a lock_path = /var/lib/neutron/tmp' /etc/neutron/neutron.conf

# Configure the Modular Layer 2 (ML2) plug-in
sed -i '/\[ml2\]$/a lock_path = type_drivers = flat,vlan' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i '/\[ml2\]$/a tenant_network_types =' /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i '/\[ml2\]$/a mechanism_drivers = linuxbridge' /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i '/\[ml2\]$/a extension_drivers = port_security' /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i '/\[ml2_type_flat\]$/a flat_networks = provider' /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i '/\[securitygroup\]$/a enable_ipset = true' /etc/neutron/plugins/ml2/ml2_conf.ini


# Configure the Linux bridge agent

# Replace PROVIDER_INTERFACE_NAME with the name of the underlying provider physical network interface. See Host networking for more information.

# sed -i '/\[linux_bridge\]$/a physical_interface_mappings = provider:PROVIDER_INTERFACE_NAME' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i '/\[linux_bridge\]$/a physical_interface_mappings = provider:enp1s0' /etc/neutron/plugins/ml2/linuxbridge_agent.ini

sed -i '/\[vxlan\]$/a enable_vxlan = false' /etc/neutron/plugins/ml2/linuxbridge_agent.ini

sed -i '/\[securitygroup\]$/a enable_security_group = true' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i '/\[securitygroup\]$/a firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver' /etc/neutron/plugins/ml2/linuxbridge_agent.ini

sed -i '/\[DEFAULT\]$/a interface_driver = linuxbridge' /etc/neutron/dhcp_agent.ini
sed -i '/\[DEFAULT\]$/a dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq' /etc/neutron/dhcp_agent.ini
sed -i '/\[DEFAULT\]$/a enable_isolated_metadata = true' /etc/neutron/dhcp_agent.ini

###################################################################
# END
# Networking Option 1
# https://docs.openstack.org/neutron/wallaby/install/controller-install-option1-ubuntu.html
###################################################################



# Configure the metadata agent
sed -i '/\[DEFAULT\]$/a nova_metadata_host = 127.0.0.1' /etc/neutron/metadata_agent.ini
sed -i '/\[DEFAULT\]$/a metadata_proxy_shared_secret = METADATA_SECRET' /etc/neutron/metadata_agent.ini

# Configure the Compute service to use the Networking service
sed -i '/\[neutron\]$/a metadata_proxy_shared_secret = METADATA_SECRET' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a service_metadata_proxy = true' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a password = NEUTRON_PASS' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a username = neutron' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a project_name = service' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a region_name = RegionOne' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a user_domain_name = Default' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a project_domain_name = Default' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a auth_type = password' /etc/nova/nova.conf
sed -i '/\[neutron\]$/a auth_url = http://127.0.0.1:5000' /etc/nova/nova.conf

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

service nova-api restart

service neutron-server restart
service neutron-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

service neutron-l3-agent restart


# END - Install and configure controller node