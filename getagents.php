<?php
	$json = exec ("/bin/perl /var/www/html/perl/zbx_agent_versions-js.pl");	
	echo $json;
?>	