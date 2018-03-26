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
print "Zabbix host item analysis\n";
print "---------------------------------------------------------\n";


#--------------------------------------------------------------------------------------
# handle command line
#--------------------------------------------------------------------------------------

if (!GetOptions(
                'host|h=s'            => \$host_name,
                'help|?'              => \$cmd_help,
                'curl-debug|c'        => \$cmd_curl_debug,
                '<>'                  => \&print_usage) or defined $cmd_help ) {
        print_usage();
        exit;
}

if (!$host_name) { print_usage(); }
if ($cmd_curl_debug) { $CURL_DEBUG_FLAG = "ON"; }

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

print "Search host by name ...\n\n";

#--------------------------------------------------------------------------------------
# get host
#--------------------------------------------------------------------------------------

$reqBody = '\'{
        "jsonrpc":"2.0","auth":"'.$zbx_auth.'","id":2,
        "method": "host.get",
        "params": {
                "output":   [ "hostids"],
		"searchWildcardsEnabled": false,
                "search": {
                          "host": "'.$host_name.'"
                        },
		"selectItems": [ "name", "key_", "delay", "itemid", "status" ]
                }
        }\'';

#                "with_items": null,
#                "with_triggers": null
#                "selectTriggers": [ "description", "triggerid"]

$curlCmd = $curl.' -s -X GET -H \'Content-Type:application/json\' -d '.$reqBody.' '.$api_url;
$out = `$curlCmd`; EXE_DEBUG ($curlCmd, $?, $out, $CURL_DEBUG_FLAG );
$json = decode_json($out);

@results  = @{$json->{result}};
@items    = @{$results[0]->{items}};

$i = 1;
if ($results[0]->{hostid}) {
	if ($#items >= 0) {
		foreach $item (@items) 
		{	
			# only enabled items
			if ($item->{status} == 0 ) {
				print_line("=",80);
				printf ("Monitor:\n");
	                        printf ("--------\n");
		                printf ("Name : %s \n", $item->{name});
		                printf ("Key_ : %s \n", $item->{key_});
		                printf ("Delay: %s \n", $item->{delay});
				get_trigger ($item->{itemid});						
			}
		}
	} else {
		print "No items found for: ".$host_name."\n\n";
	}
} else 
{
	print "Host not found: ".$host_name."\n\n";
}

#--------------------------------------------------------------------------------------
# get_trigger
#--------------------------------------------------------------------------------------

sub get_trigger
{
	my $item_id = $_[0];
	my $reqBody = '\'{
	        "jsonrpc":"2.0","auth":"'.$zbx_auth.'","id":2,
	        "method": "trigger.get",
	        "params": {
			"expandExpression": true,
	                "output":  [ "description", "expression", "status" ],
			"itemids": "'.$item_id.'"
			}
        }\'';

	my $curlCmd = $curl.' -s -X GET -H \'Content-Type:application/json\' -d '.$reqBody.' '.$api_url;
	my $out = `$curlCmd`; EXE_DEBUG ($curlCmd, $?, $out, $CURL_DEBUG_FLAG );
	my $json = decode_json($out);
	my @results  = @{$json->{result}};

	my $i = 1;
	if ($#results >= 0) {
        	foreach my $r (@results)
	        {
			if ($r->{status} == 0 ) {
				print_line ("-",80);
		                printf ("--> Trigger %d:\n", $i++);
		                printf ("--> Description : %s \n", $r->{description});
	        	        printf ("--> Expression  : %s \n", $r->{expression});
			}
	        }
		print_line ("-",80);
	} else
	{
		
	}
}

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

#--------------------------------------------------------------------------------------
# usage
#--------------------------------------------------------------------------------------
sub print_usage
{
        print "\n";
        print "usage: zbx_host_items.pl -h <hostname> [-c -?]\n\n";

        print "                 --host|-h=<hostname> \n";
        print "                 --curl-debug|-c\n";
        print "                 --help|-?\n\n";

        print "Example:\n\n";
        print "\"zbx_host_items.pl -h clfsa32-cxbbe\"\n\n";

        exit;
}

#--------------------------------------------------------------------------------------
# print_line
#--------------------------------------------------------------------------------------
sub print_line
{
	my $c = $_[0];
	my $n = $_[1];
	
	for(my $i=1; $i<$n; $i++) {print $c;}
	print "\n";
}
