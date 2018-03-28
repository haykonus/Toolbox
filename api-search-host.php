<?php

	$host = $_GET['host'];
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_search_host.pl "."\"".$host."\"");	
	echo $json;
?>