#!/usr/bin/python

import rados, sys

#cluster = rados.Rados(conffile='/my-cluster/ceph.conf')
#cluster = rados.Rados(conffile=sys.argv[1])
cluster = rados.Rados(conffile = '/my-cluster/ceph.conf', conf = dict (keyring = '/my-cluster/ceph.client.admin.keyring'))



#cluster = rados.Rados(conffile='/my-cluster/ceph.conf')
print "\nlibrados version: " + str(cluster.version())
print "Will attempt to connect to: " + str(cluster.conf_get('mon initial members'))

cluster.connect()
print "\nCluster ID: " + cluster.get_fsid()

print "\n\nCluster Statistics"
print "=================="
cluster_stats = cluster.get_cluster_stats()

for key, value in cluster_stats.iteritems():
 print key, value

print "\nAvailable Pools"
print "----------------"
pools = cluster.list_pools()
for pool in pools:
 print pool

