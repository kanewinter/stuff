#!/bin/bash
yum install -y lvm2
pvcreate /dev/vdc
vgcreate docker /dev/vdc
lvcreate --wipesignatures y -n thinpool docker -l 95%VG
lvcreate --wipesignatures y -n thinpoolmeta docker -l 2%VG
lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta
echo "activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
}" > /etc/lvm/profile/docker-thinpool.profile
lvchange --metadataprofile docker-thinpool docker/thinpool
lvs -o+seg_monitor
echo "DOCKER_STORAGE_OPTIONS=\"--storage-driver=devicemapper --storage-opt=dm.thinpooldev=/dev/mapper/docker-thinpool --storage-opt=dm.use_deferred_removal=true --storage-opt=dm.use_deferred_deletion=true\"" > /etc/sysconfig/docker-storage
curl http://yumrepo.sys.comcast.net/bcv/scripts/el7/bcv-bootstrap.bash | bash

function puppet_kick {
    status=0
    n=0
    w=0
    until [ $w -ge 3 ] ; do
        /usr/local/bin/puppet agent --server puppet.comcast.net --environment bcv_dev --test
        status=$?
        if [[ "$status" -eq "0" ]] || [[ "$status" -eq "2" ]]; then
          status=0
          w=$[$w+1]
        else
        	echo "+++++++++++++++++++++++++++++++++++++++++++"
        	echo "status: $status, retry: $n"
        	echo "+++++++++++++++++++++++++++++++++++++++++++"
        fi
        n=$[$n+1]
    done
    return $status
}

puppet_kick

init 6