#!/bin/sh
#set -xv
#exec 2>/tmp/$0
host=$1
from=$2
till=$3
#timetill=$(date +%s -d"1days ago")
timefrom=$(date +%s -d"$from days ago")
timetill=$(date +%s -d"$till days ago")
#
#Autorisation
#
zbx_auth=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","id":1,
"method": "user.login",
"params": { "user": "api", "password": "@p1" }
}' http://zabbix/api_jsonrpc.php |  jq -r .result`

hostid=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","auth":"'$zbx_auth'","id":2,
"method": "host.get",
"params": {
        "output": ["hostid"],
        "filter":{
                 "host": ["'$host'"]
                 }
          }
}' http://zabbix/api_jsonrpc.php |  jq -r .result[].hostid `

# if host not found check host in UC

if [[ -z $hostid ]] ; then

host=$(echo $host | tr '[:lower:]' '[:upper:]')
hostid=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","auth":"'$zbx_auth'","id":2,
"method": "host.get",
"params": {
        "output": ["hostid"],
        "filter":{
                 "host": ["'$host'"]
                 }
}
}' http://zabbix/api_jsonrpc.php |  jq -r .result[].hostid `

fi

problemeids=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","auth":"'$zbx_auth'","id":2,
"method": "problem.get",
"params": {
          "output":   ["eventid"],
          "hostids" : [ "'$hostid'"],
          "time_from" : "'$timefrom'",
          "time_till" : "'$timetill'"
          }
}' http://zabbix/api_jsonrpc.php | jq -c "[.result[].eventid]" `
ackevent=`curl -s -X GET -H 'Content-Type:application/json' -d'{ "jsonrpc":"2.0","auth":"'$zbx_auth'","id":3,
"method": "event.acknowledge",
"params": {
          "eventids": '$problemeids',
          "message" : "Closed by api-script",
          "action"  : 1
          }
}' http://zabbix/api_jsonrpc.php `

echo $ackevent	
exit

