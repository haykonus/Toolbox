<?php

header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

header("HTTP/1.1 301 Moved Permanently");
header("Location: http://svx-zabbixp001/main.php");
header("Connection: close");
?>
