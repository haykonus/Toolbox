<?php
	$host = $_GET['host'];
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_get_host.pl "."\"".$host."\"");	
	echo $json;
?>