#!/bin/bash

DESTINATION="/usr/share/zabbix/zabbix"
#read Files
cd $WORKDIR
`$WORKDIR/zbx_val_cl-hv-vm_names.sh`
`$WORKDIR/zbx_val_cluster_names.sh`
`$WORKDIR/zbx_val_disk_usage.sh`
`$WORKDIR/zbx_val_host_names.sh`
`$WORKDIR/zbx_val_hw-info.sh`
#move files to "export" directory
mv $WORKDIR/*.out $DESTINATION

exit 0

