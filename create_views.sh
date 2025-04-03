#!/bin/bash
### Create NFS Views on a VAST cluster
### Requires vcli installed
###---
#
#  Creates:
#    * VIP Pool
#    * View Policy
#    * Some number of views


###===================================== Variables ======================================###

#--- Load credentials from a secure file
# Cred file syntax .vast_creds
#Host=""
#USER=""
#PASS=""
CRED_FILE="$HOME/vast_creds"

# Define VIP Pool parameters
NAME="protocolsPool"  # Change this as needed
CIDR="24" # Change to your subnet
GW="10.100.2.1" # Gateway IP
IP_RANGE="10.100.2.70,10.100.2.75" # Define VIP range
ROLE="PROTOCOLS" # Network interface

# Set values for View Policy
FLAVOR="NFS"
AUTH_SRC="RPC_AND_PROVIDERS"
ACCESS_FLAV="ALL"

# Set values for View
NUM_VIEWS=6
POLICY_NAME="NFS_policy"


###======================================================================================###


# Check if the credentials file exists
if [[ ! -f "$CRED_FILE" ]]; then
    echo "Error: Credential file $CRED_FILE not found!"
    exit 1
fi

# Source the credentials securely
source "$CRED_FILE"

# Validate that credentials were loaded
if [[ -z "$HOST" || -z "$USER" || -z "$PASS" ]]; then
    echo "Error: Failed to load credentials from $CRED_FILE"
    exit 1
fi

echo "Creating $NUM_VIEWS NFS views under policy: $POLICY_NAME"

###--- Create VIP Pool ---###
echo "Creating VIP Pool: $VIP_POOL_NAME with range: $VIP_RANGE"

# Create the VIP Pool and redirect stdout to /dev/null (but keep errors visible)
if ! vcli -H "$HOST" -u "$USER" -p "$PASS" -c \
    "vippool create --name $NAME --subnet-cidr $CIDR --gw-ip $GW --ip-ranges $IP_RANGE --role $ROLE" > /dev/null; then
    echo "Error: Failed to create VIP Pool." >&2
    exit 1
fi

echo "VIP Pool $VIP_POOL_NAME created successfully!"

# Verify the VIP Pool creation (stdout redirected, stderr visible)
VIP_POOL_ID=$(vcli -H "$HOST" -u "$USER" -p "$PASS" -c "vippool list" | grep "$VIP_POOL_NAME" | awk '{print $2}' 2>/dev/null)


###--- Create View Policy
# Create an NFS view policy
if ! vcli -H "$HOST" -u "$USER" -p "$PASS" -c "viewpolicy create --name $POLICY_NAME --vip-pool-ids $VIP_POOL_ID --flavor $FLAVOR --auth-source $AUTH_SRC --access-flavor $ACCESS_FLAV"; then
    echo "Error: Failed to create NFS view policy."
    exit 1
fi

echo "Created NFS view policy: $POLICY_NAME"

# Retrieve policy ID
Policy_id=$(vcli -H "$HOST" -u "$USER" -p "$PASS" -c "viewpolicy list" | grep "$POLICY_NAME" | awk '{print $2}')

# Verify if Policy_id was successfully retrieved
if [[ -z "$Policy_id" ]]; then
    echo "Error: Failed to retrieve Policy ID for $POLICY_NAME"
    exit 1
fi

#echo "Policy ID: $Policy_id"

###--- Create View 
# Loop to create NFS views dynamically
for ((i=1; i<=NUM_VIEWS; i++)); do
    VIEW_PATH="/nfs$i"
    echo "Creating NFS view: $VIEW_PATH"

    if ! vcli -H "$HOST" -u "$USER" -p "$PASS" -c "view create --path $VIEW_PATH --protocols NFS --policy-id $Policy_id --create-dir"; then
        echo "Error: Failed to create NFS view $VIEW_PATH"
        exit 1
    fi
done

echo "NFS views creation process completed successfully."
