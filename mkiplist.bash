#!/bin/bash

FILE=$2
LIST=( `cat "$1" `)
for i in "${LIST[@]}"
do

echo "$i `nslookup $i | grep Address:\  | awk '{ print $2 }'`" >> $FILE

done
exit 0
