#!/bin/bash
###===================================================================================###
#  File:        setup_blackwell.sh
#  Created By:  Karl Vietmeier
#  Purpose:     De Novo Setup for NVIDIA Blackwell (Ubuntu 24.04 + Driver 580+)
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
#  To use in Terraform - 
#  metadata = {
#    # Read the startup script from the external file
#    startup-script = file("${path.module}/scripts/setup_blackwell.sh")
#  }
#
###===================================================================================###

set -e

# 1. LOGGING CONFIGURATION
# Redirect all output to a log file for debugging
LOG_FILE="/var/log/blackwell-install.log"
exec > >(tee "$LOG_FILE") 2>&1
echo "--- Starting De Novo NVIDIA Blackwell Setup [$(date)] ---"

# 2. PERSISTENT DISK CONFIGURATION
DEVICE_PATH="/dev/disk/by-id/google-robotics_data"
MOUNT_DIR="/mnt/disks/robotics_data"

echo "[INFO] configuring persistent storage at $MOUNT_DIR..."
mkdir -p "$MOUNT_DIR"

# Check if disk is formatted; if not, format it (EXT4)
if ! blkid "$DEVICE_PATH"; then
    echo "[INFO] Formatting new Hyperdisk..."
    mkfs.ext4 -m 0 -E discard "$DEVICE_PATH"
fi

# Mount the disk
mount -o discard,defaults "$DEVICE_PATH" "$MOUNT_DIR"

# Ensure it mounts on future reboots (Idempotent fstab check)
if ! grep -qs "$MOUNT_DIR" /etc/fstab; then
    echo "$DEVICE_PATH $MOUNT_DIR ext4 discard,defaults,nofail 0 2" >> /etc/fstab
fi

# 3. NVIDIA DRIVER INSTALLATION (Ubuntu 24.04 / R580-Open)
echo "[INFO] Adding NVIDIA repositories..."
apt-get update
apt-get install -y wget software-properties-common

# Add the official CUDA keyring
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt-get update

echo "[INFO] Installing NVIDIA Drivers (580-open) and CUDA 12.8..."
# Install kernel headers required for compiling open kernel modules
apt-get install -y linux-headers-$(uname -r) build-essential

# Install the specific driver branch required for Blackwell
apt-get install -y nvidia-driver-580-open cuda-toolkit-12-8

# 4. DOCKER INSTALLATION (Redirected to Persistent SSD)
echo "[INFO] Installing and configuring Docker..."
apt-get install -y docker.io

# Create Docker data directory on the persistent SSD
mkdir -p "$MOUNT_DIR/docker"

# Configure Docker daemon to use the SSD
cat <<EOF > /etc/docker/daemon.json
{
    "data-root": "$MOUNT_DIR/docker",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF

# 5. NVIDIA CONTAINER TOOLKIT
echo "[INFO] Installing NVIDIA Container Toolkit..."
apt-get install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# 6. COMPLETION
echo "--- Setup Complete. Rebooting System [$(date)] ---"
reboot