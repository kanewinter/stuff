#!/bin/bash

script_dir=$( command cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
rm -f $script_dir/results.txt
rm -f $script_dir/commands.txt

#[ $# -lt 3 ] && { echo "Usage: $0 <server list> <pass/fail>"; exit 1; }

while getopts h?s:m:p:D opt; do
    case "$opt" in
    h|\?)
        echo "Usage: $0 -s <server list> -m <pass|fail> -p <ports> -D <debug>"
        exit 0
        ;;
    s)  input_file=$OPTARG
        ;;
    m)  switch=$OPTARG
        ;;
    p)  ports=$OPTARG
        ;;
    D)  DEBUG=1
        ;;
    esac
done
if [ $switch == "pass" ]
  then
    switch=0
  else
    if [ $switch == "fail" ]
      then
        switch=2
    fi
fi
[[ $DEBUG ]] && echo "switch $switch"

switchlist=""

[[ $DEBUG ]] && echo "Processing $input_file"

while read -r fqdn ; do

  [[ "$fqdn" =~ ^#.*$ ]] && continue
  [[ "$fqdn" =~ ^\s*$ ]] && continue

  for port in $ports ; do
      echo "tcping -t 3 $fqdn $port >/dev/null 2>&1 ; connected=\$? ; echo "$fqdn $port \$connected" >> results.txt" >> commands.txt
 [[ $DEBUG ]] && echo "tcping -t 3 $fqdn $port >/dev/null 2>&1 ; connected=\$? ; echo "$fqdn $port \$connected" >> results.txt"
  done
done < $input_file



if [[ $DEBUG ]]
   then
     echo "Beginning pings..."
     cat commands.txt | xargs -t -I CMD --max-procs=10 bash -c CMD
   else
     cat commands.txt | xargs -I CMD --max-procs=10 bash -c CMD
fi

while read -r result ; do
result=($result)
[[ $DEBUG ]] && echo "Host: ${result[0]} Port: ${result[1]} Result: ${result[2]}"
      if [[ ${result[2]} == $switch ]]
        then
          if [[ ! $switchlist =~ .*${result[0]}.* ]]
            then
                if [[ -z $switchlist ]]
                  then
                    switchlist=${result[0]}
                  else
                    switchlist=${result[0]}","$switchlist
                fi
          fi
      fi
done < results.txt

if [[ $switch -eq 2 ]]
  then
    if [[ ! -z $switchlist ]]
      then
[[ $DEBUG ]] && echo "List of Faliures:"
        echo $switchlist
        exit 1
      else
        echo "Blank Fail List"
        exit 0
      fi
fi
if [[ $switch -eq 0 ]]
  then
    if [[ ! -z $switchlist ]]
      then
[[ $DEBUG ]] && echo "List of Successes:"
        echo $switchlist
        exit 0
      else
        echo "Blank Pass List"
        exit 1
    fi
fi
