<?php

	$hostid = $_GET['hostid'];
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_get_host_items.pl ".$hostid);	
	echo $json;
?>