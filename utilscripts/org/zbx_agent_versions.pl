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

$api_url  = "http://zabbix/api_jsonrpc.php";


print "---------------------------------------------------------\n";
print "Zabbix agent version analysis\n";
print "---------------------------------------------------------\n";

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
# Get items with key "agent.version"
#--------------------------------------------------------------------------------------

#print "Get host items with key 'agent.version' ...\n\n";

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

`rm -f *hosts >/dev/null 2>&1`;

open ($fh_all_hosts, ">", all_hosts_and_agents);

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
                open ($fh, ">>", $r->{lastvalue}."-hosts");
                print $fh $r->{hosts}[0]->{name}."\n";
                close $fh;

		print $fh_all_hosts $r->{hosts}[0]->{name}.":".$r->{lastvalue}."\n";
# print list to stdout
		print $r->{hosts}[0]->{name}."\t".$r->{lastvalue}."\n";

	}
}

close $fh_all_hosts;

#
#print ("version  #installed\n");
#print ("-------------------\n");
#
#for $version (keys %agent) {
#	push (@temp, $version);
#}
#@versions = sort (@temp);
#foreach $v (@versions){
#      	print $v."\t ".$agent{$v}."\n";
#}


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

