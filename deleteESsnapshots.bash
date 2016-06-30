#!/bin/bash

#   yum install jq

LIMIT=360
REPO=backup

SNAPSHOTS=`curl -s -XGET "localhost:9200/_snapshot/$REPO/_all" | jq -r ".snapshots[:-${LIMIT}][].snapshot"`

echo ${SNAPSHOTS[@]}

for i in "${SNAPSHOTS[@]}"
do

echo "curl -XDELETE "localhost:9200/_snapshot/$REPO/$i"" >> commands.txt
cat commands.txt | xargs -I CMD --max-procs=5 bash -c CMD

done
exit 0
