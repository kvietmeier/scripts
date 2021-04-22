#!/bin/bash
sudo -E swupd bundle-add telemetrics
sudo -E mkdir -p /etc/telemetrics
sudo -E ln -sf /etc/hostname /etc/telemetrics/opt-in-static-machine-id
