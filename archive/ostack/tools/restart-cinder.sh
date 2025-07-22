#!/bin/bash

# Restart cinder on all nodes
ssh root@cinder "service cinder-volume restart"
ssh root@control1 "service cinder-api restart"
ssh root@control1 "service cinder-scheduler restart"
