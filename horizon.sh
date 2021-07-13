#!/bin/bash
set -x #echo on
echo "horizon" > /etc/hostname

apt install openstack-dashboard -y

mv /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.original
cp ./files/horizon/local_settings.py /etc/openstack-dashboard/local_settings.py 

systemctl reload apache2.service