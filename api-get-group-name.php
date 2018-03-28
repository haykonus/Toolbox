<?php
	$groupid = $_GET['groupid'];
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_get_group_name.pl ".$groupid);	
	echo $json;
?>