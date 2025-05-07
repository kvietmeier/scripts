#!/bin/bash
#
# setup_git.sh - Automates Git installation and configuration, including secure PAT setup
#
# Created by: Karl Vietmeier
# License: Apache
#

# Function to install Git based on package manager
install_git() {
    if command -v dnf &> /dev/null; then
        echo "Detected DNF package manager. Installing Git using DNF..."
        sudo dnf install -y git
    elif command -v apt &> /dev/null; then
        echo "Detected APT package manager. Installing Git using APT..."
        sudo apt update
        sudo apt install -y git
    else
        echo "Unsupported package manager. Please install Git manually."
        exit 1
    fi
}

# Install Git if not already present
if ! command -v git &> /dev/null; then
    install_git
else
    echo "Git is already installed: $(git --version)"
fi

# --- Prompt user for configuration ---
read -p "Enter your full name for Git commits: " your_name
read -p "Enter your GitHub username: " user_name
read -p "Enter your email address: " your_email
read -p "Enter your preferred Git editor (default: vim): " editor
editor=${editor:-vim}
read -p "Enter your default Git branch name (default: main): " branch
branch=${branch:-main}

# Configure Git user info
echo "Configuring Git..."
git config --global user.name "$your_name"
git config --global user.email "$your_email"
git config --global core.editor "$editor"
git config --global init.defaultBranch "$branch"
git config --global credential.helper store  # Save credentials to ~/.git-credentials

# Prompt for GitHub PAT
read -s -p "Enter your GitHub Personal Access Token (PAT): " PAT
echo

# Clear any existing GitHub credentials
git credential reject <<EOF
protocol=https
host=github.com
EOF

# Approve new PAT for GitHub
printf "protocol=https\nhost=github.com\nusername=%s\npassword=%s\n" "$user_name" "$PAT" | git credential approve

# Final status
echo -e "\n Git and PAT have been successfully configured!"
git --version
git config --list | grep -E 'user.name|user.email|core.editor|init.defaultBranch|credential.helper'
