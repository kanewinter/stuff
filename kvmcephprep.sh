#!/bin/bash


qemu-img create -f rbd rbd:libvirt-pool/kane1-libvirt-image 500G

cat > /root/secret.xml <<EOF
<secret ephemeral='no' private='no'>
<usage type='ceph'>
<name>client.libvirt secret</name>
</usage>
</secret>
EOF

virsh secret-define --file /root/secret.xml | grep -v "Secret " | grep -v " created" > /root/client.libvirt

ceph auth get-key /root/client.libvirt > /root/client.libvirt.key

virsh secret-set-value --secret {uuid of secret} --base64 $(cat client.libvirt.key) && rm client.libvirt.key secret.xml




