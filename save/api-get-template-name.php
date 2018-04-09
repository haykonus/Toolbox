<?php
	$templateid = $_GET['templateid'];
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_get_template_name.pl ".$templateid);	
	echo $json;
?>