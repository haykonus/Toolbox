<?php
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_get_all_agents.pl");	
	echo $json;
?>