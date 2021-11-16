#!/bin/bash

cat > ~/.bashrc << EOF
## Edit here ##
export ip_vm_controller="192.168.122.61"
export ip_vm_computer="192.168.122.61"
## Edit here ##

## Dont edit here ##
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_TENANT_NAME=admin
## Dont edit here ##
EOF

source ~/.bashrc