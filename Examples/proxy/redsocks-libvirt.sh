#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
"$SCRIPT_DIR/redsocks-subnet.sh" libvirt0 192.168.122.1
