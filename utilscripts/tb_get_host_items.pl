#!/bin/perl

#--------------------------------------------------------------------------------------
# 2018 Heiko Strugalla (0049 176 - 5723 1422)
#--------------------------------------------------------------------------------------
use JSON;
use Data::Dumper;
use Getopt::Long;

use constant { true => 1, false => 0 };


#--------------------------------------------------------------------------------------
# some definitions
#--------------------------------------------------------------------------------------

$curl               = '/bin/curl';
$CURL_DEBUG_FLAG    = "OFF";
$api_url  			= "http://zabbix/api_jsonrpc.php";

$host_id 			= $ARGV[0];

#--------------------------------------------------------------------------------------
# Autorisation
#--------------------------------------------------------------------------------------

$reqBody = '\'{ 
	"jsonrpc":"2.0","id":1,
	"method": "user.login",
	"params": { "user": "api", "password": "@p1" }
}\'';

$curlCmd = $curl.' -s -X GET -H \'Content-Type:application/json\' -d '.$reqBody.' '.$api_url;
$out = `$curlCmd`; EXE_DEBUG ($curlCmd, $?, $out, $CURL_DEBUG_FLAG );
$zbx_auth = decode_json($out)->{'result'};

#--------------------------------------------------------------------------------------
# get host
#--------------------------------------------------------------------------------------

$reqBody = '\'{
        "jsonrpc":"2.0","auth":"'.$zbx_auth.'","id":2,
        "method": "item.get",
        "params": {
				"hostids": "'.$host_id.'",
                "output":   [ "name", "key_", "delay", "itemid", "status" ],
				"selectTriggers": [ "triggerid" ]		
        }
}\'';

$curlCmd = $curl.' -s -X GET -H \'Content-Type:application/json\' -d '.$reqBody.' '.$api_url;
$out = `$curlCmd`; EXE_DEBUG ($curlCmd, $?, $out, $CURL_DEBUG_FLAG );
$json = decode_json($out);

print $out;
#print Dumper($json);

#--------------------------------------------------------------------------------------
# simple debug function for command execution ...
#--------------------------------------------------------------------------------------
sub EXE_DEBUG
{
        my $cmd        = $_[0];
        my $cmd_ret    = $_[1];
        my $cmd_out    = $_[2];
        my $DEBUG_FLAG = $_[3]; # "ON"=debug on; "OFF"=debug off

        if ($DEBUG_FLAG eq "ON") {
                print "Command       : " . $cmd     . "\n";
                print "Command return: " . $cmd_ret . "\n";
                print "Command output: " . $cmd_out . "\n\n";
        }
}

