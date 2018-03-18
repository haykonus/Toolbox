#!/usr/bin/perl

#--------------------------------------------------------------------------------------
# 2017 Heiko Strugalla (0176 - 5723 1422)
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
#$api_url  = "http://zabbix.pepp.local/zabbix/api_jsonrpc.php";
$api_url  = "http://zabbix/api_jsonrpc.php";


#--------------------------------------------------------------------------------------
# Autorisation
#--------------------------------------------------------------------------------------
$reqBody = '\'{
        "jsonrpc":"2.0","id":1,
        "method": "user.login",
        "params": { "user": "api", "password": "@p1" }
}\'';
				  # "user": "api", "password": "@p1"
				  
$curlCmd = $curl.' -s -X GET -H \'Content-Type:application/json\' -d '.$reqBody.' '.$api_url;
$out = `$curlCmd`; EXE_DEBUG ($curlCmd, $?, $out, $CURL_DEBUG_FLAG );
$zbx_auth = decode_json($out)->{'result'};

#--------------------------------------------------------------------------------------
# Get items with key "agent.version"
#--------------------------------------------------------------------------------------

$reqBody = '\'{
        "jsonrpc":"2.0","auth":"'.$zbx_auth.'","id":2,
        "method": "item.get",
        "params": {
                "output":   [ "key_","lastvalue","name","itemid"],
                "selectHosts" : [ "name","status","hostid" ] ,
                "searchWildcardsEnabled" : true,
                "search": {
                          "key_": "agent.version"
                        }
                }
        }\'';
$curlCmd = $curl.' -s -X GET -H \'Content-Type:application/json\' -d '.$reqBody.' '.$api_url;
$out = `$curlCmd`; EXE_DEBUG ($curlCmd, $?, $out, $CURL_DEBUG_FLAG );
$json = decode_json($out);
@results = @{$json->{'result'}};

# hash array
%agent   = ();

foreach $r (@results) {
        # managed host ?
        if ( $r->{hosts}[0]->{status} eq '0' && $r->{lastvalue} ne '0') {
                if ($agent{$r->{lastvalue}}) {
                        # agent exists
                        $agent{$r->{lastvalue}}++;
                } else
                {
                        # new agent
                        $agent{$r->{lastvalue}} = 1;
                }
        }
}


# build JSON like: '[{"version":"3.4.4", "number":"345"},{"version":"3.2.4", "number":"456"}]'

$json = '['; $first = 1;
foreach my $key (keys(%agent)) {
	$json .= ',' if not $first; $first = 0;
	$json .= '{"version":"'.$key.'","number":"'.$agent{$key}.'"}';
}
$json .= ']';
#print $json;
#sleep(1);
print   '[{"version":"2.4.7","number":"68"},{"version":"1.8.3","number":"13"},{"version":"2.0.6","number":"1"},{"version":"2.0.4","number":"570"},{"version":"3.4.4","number":"1468"},{"version":"2.4.8","number":"2"},{"version":"2.4.5","number":"7"},{"version":"2.0.9","number":"2"},{"version":"2.4.3","number":"1"},{"version":"2.4.4","number":"6"},{"version":"2.2.3","number":"7"},{"version":"3.4.0","number":"944"},{"version":"3.2.0","number":"3"}]';

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


