#!/bin/bash 
#
# install_cloud_sdks.sh - Multi-cloud CLI automation for Azure, AWS, GCP, and OCI
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#

set -e

#######################################
# QUIET MODE (default = true)
#######################################
QUIET=true

for arg in "$@"; do
    case "$arg" in
        --quiet) QUIET=true ;;
        --verbose) QUIET=false ;;
    esac
done

run_cmd() {
    if [ "$QUIET" = true ]; then
        "$@" > /dev/null
    else
        "$@"
    fi
}

echo "Installing Cloud SDKs (Azure, AWS, GCP, and OCI)..."

#######################################
# OS / PKG MANAGER DETECTION
#######################################
detect_pkg_mgr() {
    if command -v apt &> /dev/null; then
        PKG_MGR="apt"
        UPDATE_CMD=(sudo apt update -y)
        INSTALL_CMD=(sudo apt install -y)
    elif command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
        UPDATE_CMD=(sudo dnf makecache)
        INSTALL_CMD=(sudo dnf install -y)
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
        UPDATE_CMD=(sudo yum makecache)
        INSTALL_CMD=(sudo yum install -y)
    else
        echo "Unsupported package manager"
        exit 1
    fi
}

#######################################
# HELPERS
#######################################
command_exists() {
    command -v "$1" &> /dev/null
}

file_contains() {
    local file=$1
    local text=$2
    grep -qF "$text" "$file" 2>/dev/null
}

#######################################
# WSL
#######################################
detect_wsl_and_install_wslu() {
    if grep -qi "microsoft" /proc/version; then
        echo ""
        echo "WSL detected. Installing wslu for browser integration..."
        echo ""
        if ! command_exists wslview && [[ "$PKG_MGR" == "apt" ]]; then
            run_cmd "${UPDATE_CMD[@]}"
            run_cmd "${INSTALL_CMD[@]}" wslu
        fi
        export BROWSER=wslview
    else
        echo "Standard Linux detected. Skipping wslu."
    fi
}

#######################################
# PREREQS
#######################################
install_prereqs() {
    echo ""
    echo "####################################"
    echo "Installing prerequisites..."
    echo "####################################"
    echo ""

    case "$PKG_MGR" in
        apt)
            run_cmd "${UPDATE_CMD[@]}"
            run_cmd "${INSTALL_CMD[@]}" curl gnupg lsb-release ca-certificates unzip python3-venv
            ;;
        dnf|yum)
            run_cmd "${UPDATE_CMD[@]}"
            run_cmd "${INSTALL_CMD[@]}" curl gnupg2 ca-certificates unzip python3 python3-venv || true
            ;;
    esac
}

#######################################
# AZURE
#######################################
install_azure() {
    if ! command_exists az; then
        echo ""
        echo "####################################"
        echo "Azure CLI..."
        echo "####################################"
        echo ""
        if [[ "$PKG_MGR" == "apt" ]]; then
            run_cmd bash -c "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
        else
            echo "Azure install not implemented for $PKG_MGR (skipping)"
        fi
    fi
}

#######################################
# AWS
#######################################
install_aws() {
    if ! command_exists aws; then
        echo ""
        echo "####################################"
        echo "AWS CLI v2..."
        echo "####################################"
        echo ""

        TMP_DIR=$(mktemp -d)
        cd "$TMP_DIR"
        run_cmd curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
        run_cmd unzip -q awscliv2.zip
        run_cmd sudo ./aws/install --update
        cd - > /dev/null
        rm -rf "$TMP_DIR"
    fi
}

#######################################
# GCP
#######################################
install_gcp() {
    if ! command_exists gcloud; then
        echo ""
        echo "####################################"
        echo "Google Cloud SDK..."
        echo "####################################"
        echo ""

        if [[ "$PKG_MGR" == "apt" ]]; then
            KEYRING="/usr/share/keyrings/cloud.google.gpg"
            LIST="/etc/apt/sources.list.d/google-cloud-sdk.list"

            if [ ! -f "$KEYRING" ]; then
                run_cmd bash -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o $KEYRING"
            fi

            if ! file_contains "$LIST" "packages.cloud.google.com"; then
                echo "deb [signed-by=$KEYRING] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee "$LIST" > /dev/null
            fi

            run_cmd "${UPDATE_CMD[@]}"
            run_cmd "${INSTALL_CMD[@]}" google-cloud-cli
        else
            echo "GCP install not implemented for $PKG_MGR (skipping)"
        fi
    fi
}

#######################################
# OCI
#######################################
install_oci() {
    if ! command_exists oci; then
        echo ""
        echo "####################################"
        echo "OCI CLI..."
        echo "####################################"
        echo ""

        run_cmd bash -c "curl -sL https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh | bash -s -- --accept-all-defaults"

        if [ ! -f /usr/local/bin/oci ]; then
            sudo ln -s ~/bin/oci /usr/local/bin/oci || true
        fi
    fi
}

#######################################
# TERRAFORM
#######################################
install_terraform() {
    if ! command_exists terraform; then
        echo ""
        read -p "Terraform not found. Would you like to install Terraform? (y/n): " install_tf
        if [[ "$install_tf" =~ ^[Yy]$ ]]; then
            echo ""
            echo "####################################"
            echo "Terraform..."
            echo "####################################"
            echo ""

            if [[ "$PKG_MGR" == "apt" ]]; then
                KEYRING="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
                LIST="/etc/apt/sources.list.d/hashicorp.list"

                if [ ! -f "$KEYRING" ]; then
                    run_cmd bash -c "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o $KEYRING"
                fi

                if ! file_contains "$LIST" "apt.releases.hashicorp.com"; then
                    echo "deb [signed-by=$KEYRING] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee "$LIST" > /dev/null
                fi

                run_cmd "${UPDATE_CMD[@]}"
                run_cmd "${INSTALL_CMD[@]}" terraform
            else
                echo "Terraform install not implemented for $PKG_MGR (skipping)"
            fi
        else
            echo "Skipping Terraform installation."
        fi
    fi
}

#######################################
# ASCIINEMA
#######################################
install_asciinema() {
    if ! command_exists asciinema; then
        echo ""
        read -p "asciinema not found. Would you like to install asciinema? (y/n): " install_ascii
        if [[ "$install_ascii" =~ ^[Yy]$ ]]; then
            echo ""
            echo "####################################"
            echo "asciinema..."
            echo "####################################"
            echo ""

            run_cmd "${UPDATE_CMD[@]}"
            run_cmd "${INSTALL_CMD[@]}" asciinema
        else
            echo "Skipping asciinema installation."
        fi
    fi
}

#######################################
# MAIN
#######################################
main() {
    detect_pkg_mgr
    detect_wsl_and_install_wslu
    install_prereqs
    install_azure
    install_aws
    install_gcp
    install_oci
    install_terraform
    install_asciinema
}

main

echo "✅ All Cloud SDKs installed."