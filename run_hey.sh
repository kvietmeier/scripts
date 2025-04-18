#!/bin/bash

###----------------------------------------------------------------### 
#   Wrapper to run "hey" - an HTTP load generator written in Go.
#   https://github.com/rakyll/hey
#   Check if "hey_linux_amd64" exists in the current directory.
#----------------------------------------------------------------####

# Function to display usage
usage() {
  echo "Usage: $0 -u <target-url> -z <duration>"
  echo "  -u  Target URL (e.g. http://<external-ip>)"
  echo "  -z  Duration (e.g. 20m, 10s)"
  exit 1
}

# Check if the "hey_linux_amd64" file exists in the current directory
if [ ! -f "./hey_linux_amd64" ]; then
  echo "Error: 'hey_linux_amd64' is not found in the current directory."
  echo "Please download it from https://github.com/rakyll/hey/releases"
  exit 1
fi

# Default values
target_url=""
duration="20m"

# Parse command-line arguments
while getopts ":u:z:" opt; do
  case $opt in
    u) target_url="$OPTARG" ;;
    z) duration="$OPTARG" ;;
    *) usage ;;
  esac
done

# Validate required parameters
if [[ -z "$target_url" ]]; then
  echo "Error: Target URL is required"
  usage
fi

if [[ -z "$duration" ]]; then
  echo "Error: Duration is required"
  usage
fi

# Run the hey load generator using the "hey_linux_amd64" binary in the current directory
./hey_linux_amd64 -z $duration $target_url
