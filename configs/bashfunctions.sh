#!/bin/bash
#====================================================================================================#
# Script Name: bashfunctions.sh
#
# Purpose:
#   Provides helper functions for common Terraform operations and Google Cloud Platform (GCP)
#   authentication management. This script is intended to be sourced in your shell to make
#   infrastructure workflows more efficient.
#
# Features:
#   Terraform Helpers:
#     - tfapply     : Runs `terraform apply` with all `.tfvars` files in the current directory.
#     - tfdestroy   : Runs `terraform destroy` with all `.tfvars` files in the current directory.
#     - tfplan      : Runs `terraform plan` with all `.tfvars` files in the current directory.
#     - tfshow      : Displays the current Terraform state.
#     - tfinit      : Initializes the current Terraform working directory.
#     - tfaks2      : Custom apply/destroy for `aks2` with a specified `.tfvars` file.
#
#   GCP Authentication:
#     - gcp_auth    : Loads credentials from $HOME/.gcp/.gcp_env, activates the service account,
#                     sets the default GCP project, and validates access.
#     - gcp_deauth  : Clears GCP authentication from the environment and local gcloud session.
#
# Usage:
#   source ./terraform_gcp_utils.sh
#   tfapply
#   gcp_auth
#
# Requirements:
#   - Terraform CLI installed and available in PATH.
#   - Google Cloud SDK (gcloud) installed and available in PATH.
#   - A valid GCP service account key file and project ID defined in:
#       $HOME/.gcp/.gcp_env
#       Example:
#         export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/key-file.json"
#         export GCP_DEFAULT_PROJECT="my_gcp_project"
#
# Notes:
#   - Terraform functions automatically detect all `.tfvars` files in the current directory.
#   - GCP authentication requires `~/.gcp/.gcp_env` to exist and be correctly configured.
#====================================================================================================#

#====================================================================================================#
#--- Terraform Related
#====================================================================================================#

function tfapply() {
  local var_files=(*.tfvars)

  if [ ${#var_files[@]} -eq 0 ]; then
    echo "No .tfvars files found in the current directory."
    return 1
  fi

  local terraform_args=()
  for file in "${var_files[@]}"; do
    terraform_args+=("-var-file=$file")
  done

  terraform apply --auto-approve "${terraform_args[@]}"
}

function tfdestroy() {
  local var_files=(*.tfvars)

  if [ ${#var_files[@]} -eq 0 ]; then
    echo "No .tfvars files found in the current directory."
    return 1
  fi

  local terraform_args=()
  for file in "${var_files[@]}"; do
    terraform_args+=("-var-file=$file")
  done

  terraform destroy --auto-approve "${terraform_args[@]}"
}

function tfplan() {
  local var_files=(*.tfvars)

  if [ ${#var_files[@]} -eq 0 ]; then
    echo "No .tfvars files found in the current directory."
    return 1
  fi

  local terraform_args=()
  for file in "${var_files[@]}"; do
    terraform_args+=("-var-file=$file")
  done

  terraform plan "${terraform_args[@]}"
}

function tfshow() {
  terraform show
}

function tfinit() {
  terraform init
}

# Optional custom function like the PowerShell one commented out
# Usage: tfaks2 apply ./aks2-terraform.tfvars
function tfaks2() {
  local action="${1:-apply}"
  local var_file="${2:-./aks2-terraform.tfvars}"

  terraform "$action" -auto-approve -var-file="$var_file"
}

#====================================================================================================#
###--- GCP Authentication and utilities
#====================================================================================================#

gcp_auth() {
  # Example creds file in $HOME/.foo
  # GCP Credentials for function
  # export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.foo/key-file.json"
  # export GCP_DEFAULT_PROJECT="my_gcp_project"
  
  local env_file="$HOME/.foo/.foo_env"

  # Require env file
  if [ ! -f "$env_file" ]; then
    echo "Missing environment file: $env_file"
    return 1
  fi

  # Load credentials and project
  source "$env_file"

  # Require credentials file to be set and exist
  if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ] || [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Missing or invalid credentials file: \$GOOGLE_APPLICATION_CREDENTIALS is not set or file does not exist"
    return 1
  fi

  # Require project
  if [ -z "$GCP_DEFAULT_PROJECT" ]; then
    echo "Missing GCP project ID. Set GCP_DEFAULT_PROJECT in $env_file"
    return 1
  fi

  #chmod 600 "$GOOGLE_APPLICATION_CREDENTIALS"
  echo "Using credentials file: $GOOGLE_APPLICATION_CREDENTIALS"

  if gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS" > /dev/null 2>&1; then
    echo "Service account activated successfully."
  else
    echo "Failed to activate service account."
    return 1
  fi

  if gcloud config set project "$GCP_DEFAULT_PROJECT" > /dev/null 2>&1; then
    echo "GCP project set to: $GCP_DEFAULT_PROJECT"
  else
    echo "Failed to set GCP project: $GCP_DEFAULT_PROJECT"
    return 1
  fi

  if gcloud auth application-default print-access-token > /dev/null 2>&1; then
    echo "Application Default Credentials validated."
  else
    echo "Failed to retrieve access token."
    return 1
  fi
}

gcp_deauth() {
  echo "Deauthenticating from GCP..."

  # Unset environment variables
  unset GOOGLE_APPLICATION_CREDENTIALS
  unset GCP_DEFAULT_PROJECT

  # Revoke application default credentials (local cache)
  gcloud auth application-default revoke --quiet > /dev/null 2>&1
  gcloud auth revoke --quiet > /dev/null 2>&1

  echo "GCP authentication cleared from environment and local session."
}
