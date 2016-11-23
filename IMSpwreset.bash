#!/usr/bin/env bash

app_host=bcv-srv-app-prod.b.comcast.net:10003
cluster=cims

username=$1
password=$2

json_input="{\"batchId\":\"cf-pw-reset\",\"cluster\":\"$cluster\",\"username\":\"$username\",\"password\":\"$password\"}"
curl -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d $json_input "http://$app_host/v2/ps/cluster/passwordModify"
