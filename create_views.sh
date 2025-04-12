#!/bin/bash
###=====================================================================###
###
### Configure VAST Cluster
###
### Create: 
###   VIP Pool
###   View Policy mapped to pool
###   n Number of Views
###
###=====================================================================###



###============================= Variables =============================###

CRED_FILE="$HOME/vast_creds"

# VIP Pool parameters
VIP1_NAME="DataSharesPool"
IP_RANGE1="10.100.2.201,10.100.2.212"
ROLE1="PROTOCOLS"
VIP2_NAME="ReplicationPool"
IP_RANGE2="10.100.2.221,10.100.2.226"
ROLE2="REPLICATION"

# Common
CIDR="24"
GW="10.100.2.1"

# View Policy parameters
FLAVOR="MIXED_LAST_WINS"
AUTH_SRC="RPC_AND_PROVIDERS"
ACCESS_FLAV="ALL"

# View parameters
NUM_VIEWS=3
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
echo "Creating VIP Pool: $NAME with range: $IP_RANGE1"
vcli -H "$HOST" -u "$USER" -p "$PASS" -c \
    "vippool create --name $VIP1_NAME \
    --subnet-cidr $CIDR \
    --gw-ip $GW \
    --ip-ranges $IP_RANGE1 \
    --role $ROLE1" > /dev/null

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create VIP Pool." >&2
    exit 1
fi

vcli -H "$HOST" -u "$USER" -p "$PASS" -c \
    "vippool create --name $VIP2_NAME \
    --subnet-cidr $CIDR \
    --gw-ip $GW \
    --ip-ranges $IP_RANGE2 \
    --role $ROLE2" > /dev/null

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create VIP Pool." >&2
    exit 1
fi

echo "VIP Pool $VIP1_NAME created successfully!"
echo "VIP Pool $VIP2_NAME created successfully!"

# Get Protocol VIP_POOL_ID
PrPOOL_ID=$(vcli -H "$HOST" -u "$USER" -p "$PASS" -c "vippool list" 2>/dev/null | grep "$VIP1_NAME" | awk '{print $2}')


###=====================================================================###
###--- Create View Policy 
###=====================================================================###
echo "Creating NFS view policy: $POLICY_NAME"

vcli -H "$HOST" -u "$USER" -p "$PASS" -c "viewpolicy create --name $POLICY_NAME --flavor $FLAVOR --auth-source $AUTH_SRC --access-flavor $ACCESS_FLAV --permission-per-vip-pool ${PrPOOL_ID}=RW" > /dev/null

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create NFS view policy." >&2
    exit 1
fi

echo "Created NFS view policy: $POLICY_NAME"

# Get policy ID
Policy_ID=$(vcli -H "$HOST" -u "$USER" -p "$PASS" -c "viewpolicy list" 2>/dev/null | grep "$POLICY_NAME" | awk '{print $2}')

if [[ -z "$Policy_ID" ]]; then
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
        "view create --path $VIEW_PATH --protocols NFS --policy-id $Policy_ID --create-dir" > /dev/null

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create NFS view $VIEW_PATH" >&2
        exit 1
    fi
done

echo "NFS views creation process completed successfully."
