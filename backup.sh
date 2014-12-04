#!/bin/bash

DATESTAMP=`date +'%m%d%H%M'`
DAY=`date +%a`

echo "Beginning Backup"
echo "rsyncing VMs"
echo `date`
rsync -av /var/lib/libvirt/images/* /media/backup/vms/
rsync -av /home/kane /media/backup/kane
rsync -av /home/kane/fedorasetup /media/backup/fedorasetup/fedorasetup.$DAY
rsync -av --delete-after --delete-excluded --force --exclude 'kane/.cache/*' --exclude 'kane/Dropbox' --exclude 'kane/ISO' /home/kane /media/backup/kane
rpm -qa > /media/backup/packages/packages.$DAY
ls /etc/yum.repos.d/ > /media/backup/repos/repos.$DAY
crontab -l > /media/backup/cron/cron.$DAY
echo `date`

#==========================================
if [ $# = 2 ] ; then
  NODENAME=$1
  LEVEL=$2
elif [ $# = 1 ] ; then
  NODENAME=$HOSTNAME
  LEVEL=$1
else
  NODENAME=$HOSTNAME
  LEVEL=0
fi

SKIPLIST="/home/kane/Dropbox /home/kane/Videos /home/kane/ISO /home/kane/secure /media /dev/tty /usr /var/lib/libvirt/images"
INODELIST=`ls -1id ${SKIPLIST} | awk '{ORS=","; print $1}' | sed 's/,$//'`
echo /sbin/dump -u -e ${INODELIST} -${LEVEL} -f /media/backup/${NODENAME}.${DATESTAMP}-lvl-${LEVEL}.dmp / | sh -x
CODE=$?
echo "zipping..."
ionice -c 2 -n 7 nice -n 20 gzip -vvv -c /media/backup/${NODENAME}.${DATESTAMP}-lvl-${LEVEL}.dmp > /media/backup/$DAY-${LEVEL}.gz
echo "Done zipping..."
CODE="$CODE + $?"
rm -f /media/backup/${NODENAME}.${DATESTAMP}-lvl-${LEVEL}.dmp
CODE="$CODE + $?"
printf "Backup\nCompleted\n`date`\nExit Code $CODE\n\n"
#=============================================
