#!/bin/bash

# Restart neutron on all control nodes
ssh root@control1 "service neutron-server restart"
ssh root@control1 "service neutron-dhcp-agent restart"
ssh root@control1 "service neutron-l3-agent restart"
ssh root@control1 "service neutron-metadata-agent restart"
#ssh root@control1 "service neutron-openvswitch-agent restart"

