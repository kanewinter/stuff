#!/bin/bash

#   yum install jq

touch commands.txt
echo -n "" > commands.txt

LIMIT=360
REPO=backup

SNAPSHOTS=`curl -s -XGET "localhost:9200/_snapshot/$REPO/_all" | jq -r ".snapshots[:-${LIMIT}][].snapshot"`

SNAPSHOTS=($SNAPSHOTS)

for i in "${SNAPSHOTS[@]}"
do

echo "curl -XDELETE "localhost:9200/_snapshot/$REPO/$i" 2>&1 >> snapshotcleanup.log" >> commands.txt
done

cat commands.txt | xargs -I CMD --max-procs=1 bash -c CMD

rm -f commands.txt
exit 0
