#!/bin/bash

# New IP address for vastvms (set it here or pass as argument)
NEW_IP="$1"
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.bak"

# Check if IP was provided
if [ -z "$NEW_IP" ]; then
  echo "Usage: $0 <new_ip_address>"
  exit 1
fi

# Backup the original hosts file
cp "$HOSTS_FILE" "$BACKUP_FILE"
echo "Backup created at $BACKUP_FILE"

# Check if 'vastvms' exists in the file
if grep -qE '^\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\s+vastvms\b' "$HOSTS_FILE"; then
  # Replace existing line
  sed -i -E "s|^\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\s+vastvms\b.*|$NEW_IP vastvms|" "$HOSTS_FILE"
  echo "Updated vastvms IP to $NEW_IP"
else
  # Append new entry
  echo "$NEW_IP vastvms" >> "$HOSTS_FILE"
  echo "Added new vastvms entry: $NEW_IP"
fi
