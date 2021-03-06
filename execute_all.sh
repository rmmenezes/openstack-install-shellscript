#!/bin/bash
set -x #echo on

chmod 777 ./default.sh
chmod 777 ./keystone.sh
chmod 777 ./glance.sh
chmod 777 ./nova.sh
chmod 777 ./neutron.sh
chmod 777 ./horizon.sh

echo "######################################################"
echo "################   Default         ###################"
echo "######################################################"
./default.sh

echo "######################################################"
echo "################   Keystone         ##################"
echo "######################################################"
./keystone.sh

echo "######################################################"
echo "################   Glance         ###################"
echo "######################################################"
./glance.sh

echo "######################################################"
echo "################   Nova         ######################"
echo "######################################################"
./nova.sh

echo "######################################################"
echo "################   Neutron         ###################"
echo "######################################################"
./neutron.sh

echo "######################################################"
echo "################   Horizon         ###################"
echo "######################################################"
./horizon.sh

echo "######################################################"
echo "################   FIM !!!         ###################"
echo "######################################################"