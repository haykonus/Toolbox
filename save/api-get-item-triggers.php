<?php

	$itemid = $_GET['itemid'];
	$json = exec ("/bin/perl /var/www/html/utilscripts/tb_get_item_triggers.pl ".$itemid);	
	echo $json;
?>