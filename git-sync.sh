#!/bin/bash

# ==============================================================================
# Usage: ./gitsync.sh [pull|push]
# Description: Unified sync utility to manage all Git repos in ~/projects.
# ==============================================================================
# Copyright 2026 Karl V.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# ==============================================================================

PROJECTS_DIR="${HOME}/projects"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Function to pull updates
do_pull() {
    echo "--- Starting Global Pull (Rebase/Autostash) ---"
    git pull --rebase --autostash
}

# Function to push updates
do_push() {
    if [[ -n $(git status -s) ]]; then
        echo "--- Found changes. Pushing... ---"
        git add .
        git commit -m "Syncing laptop on the road: $TIMESTAMP"
        git push
    else
        echo "--- No changes to push. ---"
    fi
}

# --- Main Logic ---

ACTION=$1

if [[ "$ACTION" != "pull" && "$ACTION" != "push" ]]; then
    echo "Usage: $0 {pull|push}"
    exit 1
fi

cd "$PROJECTS_DIR" || exit

for d in */ ; do
    if [ -d "$d/.git" ]; then
        echo -e "\n📂 Project: \033[1;34m$d\033[0m"
        cd "$d" || continue
        
        if [ "$ACTION" == "pull" ]; then
            do_pull
        else
            do_push
        fi
        
        cd ..
    fi
done

echo -e "\n✅ All tasks complete."
