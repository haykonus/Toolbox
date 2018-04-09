<?php
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_get_agent_versions.pl");	
	echo $json;
?>	