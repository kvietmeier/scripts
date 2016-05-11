#!/bin/bash

# Unset
unset OS_AUTH_URL
unset OS_TENANT_ID
unset OS_TENANT_NAME
unset OS_USERNAME
unset OS_PASSWORD

export OS_AUTH_URL=http://10.255.186.6:5000/v2.0
export OS_TENANT_ID=d24f065841db4ff39c61a1ed968e19b2
export OS_TENANT_NAME="XtremIO-02"
export OS_USERNAME="xtremio_02"
export OS_PASSWORD=xtremio

# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="RegionOne"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
