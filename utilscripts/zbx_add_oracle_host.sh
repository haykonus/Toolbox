#!/bin/sh
#set -xv
#exec 2>/tmp/add_oracel_host.txt
oid=$1
oid=$(echo $oid | tr '[:lower:]' '[:upper:]')
host="ora1"$oid
host=$(echo $host | tr '[:upper:]' '[:lower:]')

#
#Autorisation
#
zbx_auth=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","id":1,
"method": "user.login",
"params": { "user": "api", "password": "@p1" }
}' http://zabbix/api_jsonrpc.php |  jq -r .result`
#
#get hostid
#
hostid=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","auth":"'$zbx_auth'","id":2,
"method": "host.get",
"params": {
        "output": ["hostid"],
        "filter":{
                 "host": ["'$host'"]
                 }
          }
}' http://zabbix/api_jsonrpc.php |  jq -r .result[].hostid `
#
# if host not found create host
#

if [[ -z $hostid ]] ; then

hostcreate=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","auth":"'$zbx_auth'","id":3,
"method": "host.create",
"params": {
          "host": "'$host'",
          "interfaces": [ {"useip":0,"dns":"'$host'","ip":"127.0.0.1","main":1,"port":"10050","type":1} ],
          "groups": [ {"groupid":"31"} , {"groupid":"2"} ],
          "macros": [ { "macro": "{$ORAOID}", "value": "'$oid'" }],
          "templates": [ {"templateid":"10422"} ]
          }
}' http://zabbix/api_jsonrpc.php `
echo $hostcreate
#create ZIS Event Unit
zexec zismain -tcp  "CMD 0301 rexusr REXX ZEXEC_Create_EU \"Oracle $oid\" \"DiscoveredApplications\" "
fi

exit

