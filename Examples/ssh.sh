#!/bin/bash
sudo -E swupd bundle-add openssh-server
sudo -E mkdir -p /etc/ssh
sudo -E tee /etc/ssh/sshd_config > /dev/null <<- EOF
PermitRootLogin no
ChallengeResponseAuthentication no
PasswordAuthentication no
KbdInteractiveAuthentication no
Subsystem sftp /usr/libexec/sftp-server
EOF
