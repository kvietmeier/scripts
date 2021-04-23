#!/bin/bash
# Probably needs to be in te archive - 

# Tear down/build up from Vagranfile in bosh-lite repository
vagrant destroy -f  
vagrant up

# Target the BOSH cli at the new VM we've created. The ip is the default specified in the BOSH-lite Vagrantfile
bosh target 192.168.50.4  
bosh login

# Add the stemcell you would like to target you can view avaialble stem-cells with `bosh public stemcells`
#bosh download public stemcell bosh-stemcell-60-warden-boshlite-ubuntu-lucid-go_agent.tgz  
#bosh upload stemcell bosh-stemcell-60-warden-boshlite-ubuntu-lucid-go_agent.tgz

# Make sure routing rules are set up, otherwise you won't be able to access the VMs beyond the bosh director
./scripts/add-route
