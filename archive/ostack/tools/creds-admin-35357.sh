#!/bin/bash

export OS_AUTH_URL=http://10.255.186.6:35357/v2.0
export OS_TENANT_ID=f485ccaf3f02479281d288a3220a22e7
export OS_TENANT_NAME="admin"
export OS_USERNAME="admin"
export OS_PASSWORD=admin

# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="RegionOne"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
