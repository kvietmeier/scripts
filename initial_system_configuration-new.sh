#!/bin/bash
# ==================================================================================================
# Copyright (c) 2025 Karl Vietmeier. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for details.
# ==================================================================================================

### Safety valves
set -euo pipefail

###====================================================================================###
### Global Configuration & Logging
###====================================================================================###
LOG_OUT="/tmp/compiletools-out.log"
CLOUD_INIT_LOG="/tmp/cloud-init-out.txt"

# Redirect STDOUT and STDERR to log file and console
exec > >(tee -a "$LOG_OUT") 2>&1

echo "Script started at $(date)"

log_status() {
    echo "$1" | tee -a "$CLOUD_INIT_LOG"
}

###====================================================================================###
### User and Directory Setup
###====================================================================================###
setup_users() {
    log_status "Setting up users and directories..."
    if ! id -u labuser >/dev/null 2>&1; then
        if [ -f /etc/debian_version ]; then
            useradd -m -s /bin/bash -G sudo labuser
        elif [ -f /etc/redhat-release ]; then
            useradd -m -s /bin/bash -G wheel labuser
        else
            useradd -m -s /bin/bash labuser
        fi
        echo "labuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/labuser
    fi

    LABUSER_HOME="/home/labuser"
    mkdir -p "$LABUSER_HOME/output" "$LABUSER_HOME/git"
    chown -R labuser:labuser "$LABUSER_HOME"
}

###====================================================================================###
### Environment Customization (Aliases)
###====================================================================================###
apply_aliases() {
    log_status "Applying shell aliases..."
    local ALIAS_BLOCK
    ALIAS_BLOCK=$(cat <<'EOF'
# Custom Aliases
alias la="ls -Av"
alias ls="ls -hF --color=auto"
alias l="ls -CFv"
alias ll='ls -lhvF --group-directories-first'
alias lla='ls -alhvF --group-directories-first'
alias grep='grep --color=auto'
alias cdb='cd -'
alias cdu='cd ..'
alias df='df -kh'
alias du='du -h'
set -o vi
bind 'set bell-style none'
EOF
    )

    echo "$ALIAS_BLOCK" >> /root/.bashrc
    echo "$ALIAS_BLOCK" >> /home/labuser/.bashrc
}

###====================================================================================###
### Package Installation
###====================================================================================###
install_packages() {
    log_status "Installing system packages..."
    if [ -f /etc/debian_version ]; then
        apt-get update -y
        apt-get install -y build-essential debhelper libboost-dev libboost-program-options-dev \
            libboost-system-dev libboost-thread-dev libssl-dev libncurses-dev libnuma-dev \
            libaio-dev librdmacm1 bpfcc-tools man-db chrony dnsutils docker.io nfs-common \
            cmake dkms autoconf libcurl4-openssl-dev uuid-dev zlib1g-dev git python3-dev
        
        systemctl disable --now unattended-upgrades apt-daily.timer apt-daily-upgrade.timer || true

    elif [ -f /etc/redhat-release ]; then
        dnf groupinstall -y "Development Tools"
        dnf install -y epel-release
        dnf install -y numactl-devel libaio-devel boost-devel boost-program-options \
            boost-system boost-thread ncurses-devel openssl-devel bcc-tools man-db \
            chrony bind-utils nfs-utils cmake rdma-core libcurl-devel libuuid-devel \
            zlib zlib-devel libarchive git docker python3-devel
    fi
}

###====================================================================================###
### Performance Tools Compilation
###====================================================================================###
install_performance_tools() {
    local GIT_DIR="/root/git"
    mkdir -p "$GIT_DIR"

    _build() {
        local url=$1 dir=$2 cmd=$3
        cd "$GIT_DIR"

        if [ -d "$dir" ]; then
            log_status ">>> [SKIP] $dir directory found. Skipping recompile."
        else
            log_status ">>> [BUILD] Compiling $dir..."
            git clone "$url" "$dir" || { log_status "!!! Git clone failed"; return 1; }
            cd "$dir"
            if eval "$cmd"; then
                log_status ">>> [SUCCESS] $dir installed."
            else
                log_status "!!! [ERROR] FAILED building $dir"
                cd "$GIT_DIR" && rm -rf "$dir"
                return 1
            fi
        fi
    }

    # 1. DOOL
    _build "https://github.com/scottchiefbaker/dool.git" "dool" "./install.py"

    # 2. FIO
    _build "https://github.com/axboe/fio.git" "fio" "./configure && make -j$(nproc) && make install"

    # 3. iPerf
    _build "https://github.com/esnet/iperf.git" "iperf" "./configure && make -j$(nproc) && make install && echo '/usr/local/lib' > /etc/ld.so.conf.d/iperf.conf && ldconfig"

    # 4. SockPerf
    _build "https://github.com/mellanox/sockperf" "sockperf" "./autogen.sh && ./configure && make -j$(nproc) && make install"

    # 5. Elbencho (With Rocky 9 OpenSSL Fix)
    # We define the build command with explicit OpenSSL paths for Rocky 9
    local EL_CMD
    if [ -f /etc/redhat-release ]; then
        # Nuke any potential poisoned cache if the directory exists but we're forcing a build
        # Note: In the current _build logic, this only runs if the dir is new or deleted.
        EL_CMD="find . -name 'CMakeCache.txt' -delete && \
                find . -name 'CMakeFiles' -type d -exec rm -rf {} + && \
                OPENSSL_ROOT_DIR=/usr OPENSSL_LIBRARIES=/usr/lib64 OPENSSL_INCLUDE_DIR=/usr/include \
                make S3_SUPPORT=1 -j $(nproc) && \
                make rpm && dnf install -y ./packaging/RPMS/x86_64/elbencho*.rpm"
    else
        EL_CMD="make S3_SUPPORT=1 -j $(nproc) && make install"
    fi
    
    _build "https://github.com/breuner/elbencho.git" "elbencho" "$EL_CMD"
}
###====================================================================================###
### Main Execution
###====================================================================================###
main() {
    setup_users
    apply_aliases
    install_packages
    # configure_chrony (omitted here for brevity, but include if needed)
    install_performance_tools

    log_status "Script completed successfully at $(date)"
    cd /root
}

main