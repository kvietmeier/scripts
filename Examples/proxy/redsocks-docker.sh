#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
"$SCRIPT_DIR/redsocks-subnet.sh" docker0 172.17.0.1
