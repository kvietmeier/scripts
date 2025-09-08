#!/usr/bin/env python3
"""
===============================================================================
Title       : gcp_find_z3.py
Author      : Karl Vietmeier
Created     : 2025-09-05
License     : Apache License 2.0
Description : 
    This script performs a dry-run check to verify which GCP zones support 
    the 'z3-highmem-88-highlssd' machine type. It uses the Google Compute 
    Engine API via `googleapiclient` and relies on existing `gcloud` 
    authentication credentials.

    The script is currently hard-coded with a list of valid zones where the
    machine type is available. For each zone, it attempts to query the 
    machine type and prints PASS if available, otherwise FAIL with a 
    descriptive error.

Use this to get the list of valid zones:
gcloud compute machine-types list --filter="name:z3-highmem-88-highlssd" --format="table[box](zone, name)"


===============================================================================
Usage:
    python3 gcp_find_z3.py

Notes:
    - Requires `google-api-python-client` to be installed:
        pip3 install google-api-python-client
    - Must be authenticated via gcloud:
        gcloud auth application-default login
"""

from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.auth import default

# Get credentials and default project
credentials, PROJECT_ID = default()

MACHINE_TYPE = "z3-highmem-88-highlssd"

# Hard-coded valid zones
VALID_ZONES = [
    "us-central1-a","us-central1-c","us-central1-f","us-central1-d",
    "europe-west1-b","europe-west1-c","europe-west1-d",
    "us-west1-a","us-west1-b","us-west1-c",
    "us-east1-b","us-east1-c","us-east1-d",
    "asia-northeast1-a","asia-northeast1-b","asia-northeast1-c",
    "asia-southeast1-a","asia-southeast1-b","asia-southeast1-c",
    "us-east4-a","us-east4-b","us-east4-c",
    "australia-southeast1-c","australia-southeast1-b",
    "europe-west2-a","europe-west2-b","europe-west2-c",
    "europe-west3-c","europe-west3-a",
    "asia-south1-b","asia-south1-c",
    "europe-west4-c","europe-west4-b","europe-west4-a",
    "us-east7-b","us-east5-c","us-east5-b","us-east5-a",
    "us-south1-c","us-south1-a","us-south1-b",
    "northamerica-south1-b","northamerica-south1-a","northamerica-south1-c",
    "europe-north2-a","europe-north2-b"
]

# Build the Compute service client (uses gcloud credentials automatically)
service = build('compute', 'v1', credentials=credentials)

print("Dry-run results for creating 11 VMs of z3-highmem-88-highlssd\n")
print(f"{'ZONE':<25} {'RESULT'}")
print("-"*50)

for zone in VALID_ZONES:
    try:
        # Dry-run: check machine type exists
        request = service.machineTypes().get(
            project=PROJECT_ID,
            zone=zone,
            machineType=MACHINE_TYPE
        )
        request.execute()
        print(f"{zone:<25} PASS")
    except HttpError as e:
        if e.resp.status == 403:
            print(f"{zone:<25} FAIL: Quota or permission issue")
        else:
            print(f"{zone:<25} FAIL: Invalid machine type")
