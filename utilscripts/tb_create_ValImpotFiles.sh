#!/bin/bash

WORKDIR="/opt/zabbix-server/zabbix_scripts/util_scripts"
DESTINATION="/usr/share/zabbix/zabbix"
#Create Files
cd $WORKDIR > /dev/null 2>&1
`$WORKDIR/zbx_val_cl-hv-vm_names.sh > /dev/null 2>&1`
`$WORKDIR/zbx_val_cluster_names.sh > /dev/null 2>&1`
`$WORKDIR/zbx_val_disk_usage.sh > /dev/null 2>&1`
`$WORKDIR/zbx_val_host_names.sh > /dev/null 2>&1`
`$WORKDIR/zbx_val_hw-info.sh > /dev/null 2>&1`
#move files to "export" directory
mv $WORKDIR/*.out $DESTINATION > /dev/null 2>&1
sleep 2
echo 'success'
exit 0

