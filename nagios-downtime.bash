#!/bin/sh
# This is a sample shell script showing how you can submit the SCHEDULE_HOST_DOWNTIME command
# to Nagios.  Adjust variables to fit your environment as necessary.

HOST=$1
SERVICE=$2
COMMENT=$3

USER='nlewis001c'
NOW=`date +%s`
COMMANDFILE='/mnt/vdc/data/bcv-nagios/opt/nagios/var/rw/nagios.cmd'



ssh bcv-srv-ops-prod-03.b.comcast.net "sudo printf '[%lu] SCHEDULE_SVC_DOWNTIME\;$HOST\;$SERVICE\;1110741500\;1110748700\;0\;0\;7200\;$USER\;$COMMENT\n' $NOW > $COMMANDFILE"
#ssh bcv-srv-ops-prod-05.b.comcast.net "printf "[%lu] SCHEDULE_SVC_DOWNTIME;$HOST;$SERVICE;1110741500;1110748700;0;0;7200;$USER;$COMMENT\n" $NOW > $COMMANDFILE"



#/bin/printf "[%lu] SCHEDULE_HOST_DOWNTIME;$HOST;1110741500;1110748700;0;0;7200;$USER;$COMMENT\n" $NOW > $COMMANDFILE

#/bin/printf "[%lu] SCHEDULE_HOST_SVC_DOWNTIME;host1;1110741500;1110748700;0;0;7200;Some One;Some Downtime Comment\n" $now > $commandfile


