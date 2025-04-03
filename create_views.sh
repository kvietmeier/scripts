#!/bin/bash
### Create NFS Views on a VAST cluster
### Requires vcli installed

# Set default values
NUM_VIEWS=6
POLICY_NAME="NFS_policy"

# Load credentials from a secure file
CRED_FILE="$HOME/.vast_creds.conf"

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

#echo "Using HOST: $HOST"
echo "Creating $NUM_VIEWS NFS views under policy: $POLICY_NAME"

# Create an NFS view policy
if ! vcli -H "$HOST" -u "$USER" -p "$PASS" -c "viewpolicy create --name $POLICY_NAME --flavor NFS --auth-source RPC_AND_PROVIDERS --access-flavor ALL"; then
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

echo "Policy ID: $Policy_id"

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
