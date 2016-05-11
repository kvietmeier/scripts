#!/bin/bash

# Restart nova on all compute nodes
ssh root@nova1 "service nova-compute restart"
ssh root@nova2 "service nova-compute restart"
ssh root@nova3 "service nova-compute restart"

ssh root@control1 "~/restart-nova.sh"
