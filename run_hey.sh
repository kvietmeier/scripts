#!/bin/bash
###----------------------------------------------------------------### 
#   Wrapper to run "hey" - an http load generator written in go
#   https://github.com/rakyll/hey
#   Use it to put load on a K8S application
#   
#   Can be installed on Ubuntu with "apt install hey"
#
#   If you can't install it and don't have go, you can do this (Azure Cloud Shell)
#
#   export GOPATH=~/go
#   export PATH=$GOPATH/bin:$PATH
#   go get -u github.com/rakyll/hey
#   hey -z 20m http://<external-ip>
#   

# Run the installed version 
target_url="http://<>"
duration="20m"

hey -z $duration $target_url