#!/bin/bash
#
# install_cloud_sdks.sh - Multi-cloud CLI automation for Azure, AWS, GCP, and OCI
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#

set -e

echo "Installing Cloud SDKs (Azure, AWS, GCP, and OCI)..."

# 1. Detect WSL and install wslu if needed
if grep -qi "microsoft" /proc/version; then
    echo ""
    echo "WSL detected. Installing wslu for browser integration..."
    echo ""
    sudo apt update && sudo apt install -y wslu
    # Set the default browser for the session
    export BROWSER=wslview
else
    echo "Standard Linux detected. Skipping wslu."
fi

# Prerequisites
echo ""
echo "####################################"
echo "Installing prerequisites..."
echo "####################################"
echo ""
sudo apt update && sudo apt install -y curl gnupg lsb-release ca-certificates unzip python3-venv

# --- AZURE ---
if ! command -v az &> /dev/null; then
    echo ""
    echo "####################################"
    echo "Azure CLI..."
    echo "####################################"
    echo ""
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# --- AWS ---
if ! command -v aws &> /dev/null; then
    echo ""
    echo "####################################"
    echo "AWS CLI v2..."
    echo "####################################"
    echo ""
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip && sudo ./aws/install && rm -rf aws awscliv2.zip
fi

# --- GCP ---
if ! command -v gcloud &> /dev/null; then
    echo ""
    echo "####################################"
    echo "Google Cloud SDK..."
    echo "####################################"
    echo ""
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt update && sudo apt install -y google-cloud-cli
fi

# --- OCI (Oracle) ---
if ! command -v oci &> /dev/null; then
    echo ""
    echo "####################################"
    echo "OCI CLI..."
    echo "####################################"
    echo ""
    # The official Oracle installer
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
    # Link it so it's in your path immediately
    sudo ln -s ~/bin/oci /usr/local/bin/oci || true
fi

echo "✅ All Cloud SDKs installed."