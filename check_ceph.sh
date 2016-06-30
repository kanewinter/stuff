#!/bin/bash

HOSTNAME=$1
RESULT=`curl -s $HOSTNAME:80/api/v0.1/health`

if [ -z "$RESULT" ]; then
    CODE=2
    RESULT="CEPH Monitor Fail"
else
  if [ "$RESULT" != "HEALTH_OK" ] ; then
    CODE=2
  else
    CODE=0
  fi
fi

echo $RESULT
exit $CODE
