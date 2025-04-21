#!/bin/bash
###--- Not working yet

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

# Install Git
install_git

###--- Variables
your_name="Frank Herbert"
user_name="myusername"
your_email="myemail@server.com"
editor="vim"
branch="main"
path2token="$HOME/.pat.tmp"


# Configure Git user name and email
echo "Configuring Git user name and email..."
git config --global user.name "$your_name"
git config --global user.email "$your_email"

# Set other helpful Git global settings
echo "Setting up Git global settings..."
git config --global core.editor "$editor"
git config --global init.defaultBranch "$branch"

# Add PAT from a local file or environment variable
if [ -f "$path2token" ]; then
    echo "Using PAT from file..."
    PAT=$(cat "$path2token")
elif [ -n "$PAT_TOKEN" ]; then
    echo "Using PAT from environment variable..."
    PAT="$PAT_TOKEN"
else
    echo "No PAT found. Please create a .pat_token file or set the PAT_TOKEN environment variable."
    exit 1
fi

# Add PAT to Git credential manager
echo "Adding PAT to credential manager..."
git credential reject "https://github.com"  # Clear any previous credentials
echo "https://${user_name}:${PAT}@github.com" | git credential approve

# Verify Git installation and configuration
echo "Git and PAT have been set up. Here are the details:"
git --version
git config --list