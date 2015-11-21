#! /bin/bash

stop ssnoded

swift-init all stop
killall -u swift
find /srv/node/d*/ -delete

du -sh /srv/node
swift-init all start
sleep 5
start ssnoded
sleep 5
ssdiag
