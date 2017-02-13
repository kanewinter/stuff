#!/bin/bash
echo "Region?"
read region
echo "Instance?"
read instance

export OS_REGION_NAME="$region"
openstack server delete $instance