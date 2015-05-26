#!/bin/sh

for i in db.*
do
    mv "$i" "`echo $i | sed 's/db.//'`"
done
