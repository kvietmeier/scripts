#!/bin/bash
### Create a VIP Pool on a VAST Data Cluster
### Requires vcli installed

# Define VIP Pool parameters
NAME="protocolsPool"  # Change this as needed
CIDR="24" # Change to your subnet
GW="10.100.2.1" # Gateway IP
IP_RANGE="10.100.2.80,10.100.2.85" # Define VIP range
ROLE="PROTOCOLS" # Network interface

# Load credentials from a secure file
CRED_FILE="$HOME/.vast_creds.conf"

# Check if the credentials file exists
if [[ ! -f "$CRED_FILE" ]]; then
    echo "Error: Credential file $CRED_FILE not found!" >&2
    exit 1
fi

# Source the credentials securely
source "$CRED_FILE"

# Validate that credentials were loaded
if [[ -z "$HOST" || -z "$USER" || -z "$PASS" ]]; then
    echo "Error: Failed to load credentials from $CRED_FILE" >&2
    exit 1
fi

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

if [[ -z "$VIP_POOL_ID" ]]; then
    echo "Error: VIP Pool ID retrieval failed!" >&2
    exit 1
fi

echo "VIP Pool ID: $VIP_POOL_ID"
