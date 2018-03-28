<?php

	$template = $_GET['template'];
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_search_template.pl "."\"".$template."\"");	
	echo $json;
?>