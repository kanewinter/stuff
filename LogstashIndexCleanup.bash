#!/bin/bash

HOST=$1
NUMBER=$2
NAGIOS=$3

OLDEST=`curl -s -XGET "$HOST:9200/logstash-*?pretty=true" | grep logstash- | sed 's/\ \ \"logstash\-//g' | sed 's/\".*//g' | sort -n | head -$NUMBER`

echo ${OLDEST[@]}

for i in "${OLDEST[@]}"
do

if [ "$NAGIOS" ]
  then
    logger -s Remediation action by Nagios deleting the oldest Logstash Index logstash-$i on $HOST
fi

logger -s Deleting Elasticsearch Index logstash-$i
#curl -XDELETE "$HOST:9200/logstash-$i"

done
exit 0
