#!/usr/bin/env python3
#-----------------------------------------------------------------------#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#-----------------------------------------------------------------------#

"""
Original Script:
  Test whether a VAST Cluster VMS is responding to API calls - is it installed and running?

Updated Version:
  Is the cluster itself online and reasdy for configuration?

It returns the `state` field from /api/clusters/ as it transitions through each phase:
  * INSTALLING
  * INIT
  * ACTIVATING
  * ONLINE

Motivation:
  The VMS will respond to API calls as soon as it is running but the cluster won't 
  accept configuration commands until it is ONLINE. 

Credits:
Modified from the original script by: 
    Karl Vietmeier - VAST Data Cloud Solutions Architect

    Original Author:
    Casey Golliher - VAST Data Customer Success
"""

import json
import requests
import urllib3
import sys

urllib3.disable_warnings()

# --- Defaults ---
DEFAULT_HOSTNAME = "vms"
DEFAULT_USERNAME = "admin"
DEFAULT_PASSWORD = "123456"

# --- Help / Usage ---
def print_usage():
    print(f"Usage: {sys.argv[0]} [<ip_or_hostname>] [<username>] [<password>]")
    print("Defaults:")
    print(f"  Hostname/IP : '{DEFAULT_HOSTNAME}' (resolved from /etc/hosts)")
    print(f"  Username    : '{DEFAULT_USERNAME}'")
    print(f"  Password    : '{DEFAULT_PASSWORD}'")

# --- Get IP from /etc/hosts ---
def get_ip_from_hosts(hostname=DEFAULT_HOSTNAME, hosts_file="/etc/hosts"):
    with open(hosts_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and line.endswith(hostname):
                return line.split()[0]
    raise Exception(f"Hostname '{hostname}' not found in {hosts_file}")

# --- Parse CLI Args ---
if len(sys.argv) > 1 and sys.argv[1] in ("-h", "--help"):
    print_usage()
    sys.exit(0)

target = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_HOSTNAME
username = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_USERNAME
password = sys.argv[3] if len(sys.argv) > 3 else DEFAULT_PASSWORD

# Resolve IP if needed
if target.replace(".", "").isdigit():
    vms_ip = target
else:
    vms_ip = get_ip_from_hosts(target)

# --- API Call ---
base_url = f"https://{vms_ip}/api/v5"
token_url = f"{base_url}/token/"
cluster_url = f"{base_url}/clusters/"

# Step 1: Authenticate
auth_payload = {"username": username, "password": password}
auth_headers = {"Content-Type": "application/json", "Accept": "*/*"}

try:
    auth_response = requests.post(token_url, json=auth_payload, headers=auth_headers, verify=False)
    auth_response.raise_for_status()
    token = auth_response.json()['access']
except Exception as e:
    print("OFFLINE")
    sys.exit(1)

# Step 2: Get cluster state
headers = {
    "Accept": "*/*",
    "Authorization": f"Bearer {token}"
}

try:
    cluster_response = requests.get(cluster_url, headers=headers, verify=False)
    cluster_response.raise_for_status()
    clusters = cluster_response.json()

    if clusters and isinstance(clusters, list):
        state = clusters[0].get("state", "UNKNOWN")
        print(state)
        sys.exit(0)
    else:
        print("UNKNOWN")
        sys.exit(1)

except Exception as e:
    print("OFFLINE")
    sys.exit(1)
