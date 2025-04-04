#!/bin/bash
### Create NFS Views on a VAST cluster
### Requires vcli installed

###============================= Variables =============================###

CRED_FILE="$HOME/vast_creds.sh"

# VIP Pool parameters
NAME="protocolsPool"
CIDR="24"
GW="10.100.2.1"
IP_RANGE="10.100.2.200,10.100.2.206"
ROLE="PROTOCOLS"

# View Policy parameters
FLAVOR="NFS"
AUTH_SRC="RPC_AND_PROVIDERS"
ACCESS_FLAV="ALL"

# View parameters
NUM_VIEWS=6
POLICY_NAME="NFS_policy"
PATH_NAME="share"

###=====================================================================###

# Load credentials
if [[ ! -f "$CRED_FILE" ]]; then
    echo "Error: Credential file $CRED_FILE not found!" >&2
    exit 1
fi

source "$CRED_FILE"

if [[ -z "$HOST" || -z "$USER" || -z "$PASS" ]]; then
    echo "Error: Failed to load credentials from $CRED_FILE" >&2
    exit 1
fi

echo "Creating $NUM_VIEWS NFS views under policy: $POLICY_NAME"

###=====================================================================###
###--- Create VIP Pool 
###=====================================================================###
echo "Creating VIP Pool: $NAME with range: $IP_RANGE"

vcli -H "$HOST" -u "$USER" -p "$PASS" -c \
    "vippool create --name $NAME --subnet-cidr $CIDR --gw-ip $GW --ip-ranges $IP_RANGE --role $ROLE" > /dev/null

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create VIP Pool." >&2
    exit 1
fi

echo "VIP Pool $NAME created successfully!"

# Get VIP_POOL_ID
VIP_POOL_ID=$(vcli -H "$HOST" -u "$USER" -p "$PASS" -c "vippool list" 2>/dev/null | grep "$NAME" | awk '{print $2}')

###=====================================================================###
###--- Create View Policy 
###=====================================================================###
echo "Creating NFS view policy: $POLICY_NAME"

vcli -H "$HOST" -u "$USER" -p "$PASS" -c \
    "viewpolicy create --name $POLICY_NAME --flavor $FLAVOR --auth-source $AUTH_SRC --access-flavor $ACCESS_FLAV" > /dev/null

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create NFS view policy." >&2
    exit 1
fi

echo "Created NFS view policy: $POLICY_NAME"

# Get policy ID
Policy_id=$(vcli -H "$HOST" -u "$USER" -p "$PASS" -c "viewpolicy list" 2>/dev/null | grep "$POLICY_NAME" | awk '{print $2}')

if [[ -z "$Policy_id" ]]; then
    echo "Error: Failed to retrieve Policy ID for $POLICY_NAME" >&2
    exit 1
fi

###=====================================================================###
###--- Create Views
###=====================================================================###
for ((i=1; i<=NUM_VIEWS; i++)); do
    VIEW_PATH="/${PATH_NAME}${i}"
    echo "Creating NFS view: $VIEW_PATH"

    vcli -H "$HOST" -u "$USER" -p "$PASS" -c \
        "view create --path $VIEW_PATH --protocols NFS --policy-id $Policy_id --create-dir" > /dev/null

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create NFS view $VIEW_PATH" >&2
        exit 1
    fi
done

echo "NFS views creation process completed successfully."
