<?php

    $action     = $_GET['action']; 
    $arg1       = $_GET['arg1'];
    $arg2       = $_GET['arg2'];
    $arg3       = $_GET['arg3'];
    
    $json = exec ($action.' "'.$arg1.'" "'.$arg2.'" "'.$arg3.'"');
    echo $json;

?>