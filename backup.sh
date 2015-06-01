#!/bin/bash

if [ ! -f /media/backup/backupdrivemounted ]; then
    echo "Backup Drive Missing"
    exit
fi


LOCKFILE=/home/kane/scripts/backup.lock
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

#restore -iaf <dumpfile.dmp>
#creates a full dir tree to the restored file(s) rooted
#wherever you run the command from so do not run from /

DATESTAMP=`date +'%m%d%H%M'`
DAY=`date +%a`

echo "Beginning Backup"
echo "rsyncing VMs"
echo `date`
rsync -av /var/lib/libvirt/images/* /media/backup/vms/
#rsync -av /home/kane /media/backup/kane
rsync -av --delete-after --delete-excluded --force --exclude 'kane/.cache' --exclude 'kane/.thunderbird' --exclude 'kane/Dropbox' --exclude 'kane/ISO' /home/kane /media/backup/kane
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


rm -f ${LOCKFILE}
trap - INT TERM EXIT
