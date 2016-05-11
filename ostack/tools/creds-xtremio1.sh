#!/bin/bash

export OS_AUTH_URL=http://10.255.186.6:5000/v2.0
export OS_TENANT_ID=3f3e67e93ff04a2e9df23b6a7758ad88
export OS_TENANT_NAME="XtremIO-01"
export OS_USERNAME="xtremio_01"
export OS_PASSWORD=xtremio

# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="RegionOne"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
