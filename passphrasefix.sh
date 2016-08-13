if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s`
    ssh-add /home/nlewis001c/.ssh/id_rsa_common
    ssh-add /home/nlewis001c/.ssh/id_rsa_kanewinter_github
    ssh-add /home/nlewis001c/.ssh/id_rsa
fi
