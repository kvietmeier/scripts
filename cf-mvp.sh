#!/usr/bin/env bash
set -ex

#   ____ _                 _ _____                     _              __  ____     ______  
#  / ___| | ___  _   _  __| |  ___|__  _   _ _ __   __| |_ __ _   _  |  \/  \ \   / /  _ \ 
# | |   | |/ _ \| | | |/ _` | |_ / _ \| | | | '_ \ / _` | '__| | | | | |\/| |\ \ / /| |_) |
# | |___| | (_) | |_| | (_| |  _| (_) | |_| | | | | (_| | |  | |_| | | |  | | \ V / |  __/ 
#  \____|_|\___/ \__,_|\__,_|_|  \___/ \__,_|_| |_|\__,_|_|   \__, | |_|  |_|  \_/  |_|    
#                                                             |___/                        
#
# Source script came from - 
# https://gist.github.com/cwest/87050bbc2258200a63e8
#
# I localizefd my own copy
#
# Prerequisites and Assumptions
# 1. Tested on a mac with up-to-date operating system and XCode installed.
# 2. Modern vagrant and VirtualBox installed.
# 3. git installed.
# 4. A modern ruby installed (via rbenv, rvm, or similar).
#
# You may need to reduce the number of compilation workers and parallel update jobs.  
# 

# vars
BOSH_DIR=/Volumes/SD_Card/projects/vagrant
VM_MEMORY=8048 # 8G of Memory.
WORKSPACE=$(mktemp -d $BOSH_DIR/cf-workspace-XXXX)
STEMCELL_LOCAL=/Users/vietmeik/sd/ISO/vagrant/bosh-stemcell-2776-warden-boshlite-ubuntu-trusty-go_agent.tgz
STEMCELL_VERSION=2776
REDIS_VERSION=424
export REDIS_VERSION STEMCELL_VERSION WORKSPACE VM_MEMORY BOSH_DIR

sudo -v # cache sudo for long enough (I hope)

main () {
    initial_setup
    git_clone
    vagrant_up
    cf_provision
    configure_diego
    redis_deploy
    create_org
}


# Don't need these
# Only do once (Spiff in my PATH)
initial_setup () {
    #  - add check for xcode
    cd $WORKSPACE
    mkdir -p bin && cd $WORKSPACE/bin
    curl -L -o spiff.zip "https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_darwin_amd64.zip"
    unzip spiff.zip && rm -f spiff.zip
    curl -L "https://cli.run.pivotal.io/stable?release=macosx64-binary&source=github" | tar -zx
    PATH=$WORKSPACE/bin:$PATH
    gem install bosh_cli bosh_cli_plugin_micro --no-ri --no-rdoc
}

# Pull down the github repos
git_clone () {
    cd $WORKSPACE
    git clone https://github.com/cloudfoundry/bosh-lite
    git clone https://github.com/cloudfoundry/cf-release
    git clone https://github.com/cloudfoundry-incubator/diego-release
    git clone https://github.com/pivotal-cf/cf-redis-release.git
}

### BOSH and Cloud Foundry

# Setup Vagrant VM
vagrant_up () {
    cd $WORKSPACE/bosh-lite
    vagrant box update
    vagrant up
    bin/add-route # will require sudo
    sleep 30 
    bosh target 192.168.50.4 lite
}

# Provision Cloud Foundry bits
cf_provision () {
    # This can fail - 
    # bosh upload stemcell "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=$STEMCELL_VERSION"
  
    # So I have a local copy
    bosh upload stemcell $STEMCELL_LOCAL
    ./bin/provision_cf
}


# Diego and Docker Support
configure_diego() {
    cd $WORKSPACE/diego-release
    git checkout master
    ./scripts/update
    bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release
    bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/etcd-release
    ./scripts/generate-bosh-lite-manifests
    bosh deployment bosh-lite/deployments/diego.yml
    bosh create release --name diego --force
    bosh -n upload release
    bosh -n deploy
    cf login -a api.bosh-lite.com -u admin -p admin --skip-ssl-validation
    cf enable-feature-flag diego_docker
}
  

# Redis and Redis Service Broker
redis_deploy () {
    cd $WORKSPACE/cf-redis-release
    perl -pe 's/bundle\s+exec\s+//' manifests/cf-redis-lite.yml > cf-redis.yml

    # May need different version of bosh_cli
    # vietmeik@Skarn (/Volumes/SD_Card/projects/vagrant/cf-workspace-MQQ7/cf-redis-release)$ bosh deployment cf-redis.yml
      # Could not find proper version of bosh_cli (1.2858.0) in any of the sources
    # edit the Gemfile
    # vietmeik@Skarn (~/sd/projects/vagrant/cf-workspace-MQQ7/cf-redis-release)$ cat Gemfile
    # source 'https://rubygems.org'
    # 
    # gem 'aws-sdk'
    # gem 'bosh_cli', '1.3184.1.0'

    bosh deployment cf-redis.yml
    bosh -n upload release releases/cf-redis/cf-redis-$REDIS_VERSION.yml
    bosh -n deploy
    bosh run errand broker-registrar
}

# Create org and space
create_org () {
    cf create-org pivotal
    cf target -o pivotal
    cf create-space demo
    cf target -s demo
}  


# Call main() here





