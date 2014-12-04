#!/bin/bash

DATESTAMP=`date +'%m%d%H%M'`
DAY=`date +%a`

echo "Beginning Backup"
echo "rsyncing VMs"
echo `date`
rsync -av /media/backup/vms /media/backup/olddrive/
rsync -av /media/backup/fedorasetup /media/backup/olddrive/
rsync -av /media/backup/packages /media/backup/olddrive/
rsync -av /media/backup/repos /media/backup/olddrive/
rsync -av /media/backup/cron /media/backup/olddrive/
echo `date`
rsync -av /media/backup/kane /media/backup/olddrive/

rsync -av /media/backup/*.gz /media/backup/olddrive/

echo `date`
printf "Backup\nCompleted\n`date`\nExit Code $CODE\n\n"
