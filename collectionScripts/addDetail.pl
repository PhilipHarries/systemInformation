#!/usr/bin/perl

use warnings;
use strict;

use Socket;
use Net::Ping;
use LWP::Simple;

my $debug="off";
sub printDebug
{
	my $inString = shift;
	if($debug ne "off") { print("DEBUG: $inString"); }
}

my $hostName;
my $address;

sub ipResolve
{
	my $hostName = shift;
	my $address="";
	if ($address = gethostbyname( $hostName ))
	{
		$address = inet_ntoa($address);
		return("$address");
	}
	else
	{
		return("");
	}
}
sub nameResolve
{
  my $address = shift;
  my $hostName;
  if ( $hostName = gethostbyaddr( inet_aton( $address), AF_INET) )
  {
    return($hostName);
  }
  else
  {
    return("");
  }
}
sub replaceColon
{
	my $inString = shift;
	if($inString =~ m/:/){printDebug("string $inString matched :\n");}
	$inString =~ s/:/-/g;
	return($inString);
}

sub removeControlM
{
	my $inString = shift;
	if($inString =~ m/\r/){printDebug("string $inString matched ^M\n");}
	$inString =~ s/\r//g;
	return($inString);
}

sub cleanString
{
	my $inString = shift;
	$inString = removeControlM(replaceColon($inString));
	return($inString);
}

my $proto = getprotobyname('tcp');
my $hostname;
my $port = 5898;
my $p;
my $url = "";
my $contact = "noanswer";
my $type = "noanswer";
my $os = "noanswer";
my $usage = "noanswer";
my $notes = "noanswer";
my $project = "noanswer";
my $location = "noanswer";
my $prefix = "not specified";
my($returnTime, $duration);
my $newline = "";
my $info = "";
my $ip = "not resolved";

my($fh1,$fh2,$fh3);

open($fh1, "<", "/var/systemInformation/content/whatWhereRaw.txt");

my @vmList;
@vmList = <$fh1>;
close($fh1);
my($physhost,$vmname,$vmstate,$numCpus,$maxMem,$usedMem,$collatedDetails);
my($usageSet,$notesSet,$projectSet,$contactSet,$typeSet,$osSet,$prefixSet,$origVmname,$inUsage,$inNotes,$inProject,$inContact,$inOs,$inType);

foreach my $line (@vmList)
{
	$contact = "noanswer";
	$type = "noanswer";
	$os = "noanswer";
	$usage = "noanswer";
	$notes = "noanswer";
	$project = "noanswer";
	$location = "noanswer";
	$prefix = "not specified";
	$usageSet = "false";
	$notesSet = "false";
	$projectSet = "false";
	$contactSet = "false";
	$osSet = "false";
	$typeSet = "false";
	$origVmname = "unset";
	$vmname = "unset";
	
	chomp($line);
	($physhost,$vmname,$vmstate,$numCpus,$maxMem,$usedMem) = split(/:/,$line);

	$ip = ipResolve($vmname);
	if($ip ne "")
	{
		$vmname = nameResolve($ip);
		$origVmname = $vmname;
		# bring all the vm names down to just being that - the vmname, but resolvable
		$vmname =~ s/\.*//;
	}
	printDebug("$vmname $origVmname \n");
	if( "${origVmname}" ne "unset" )
	{
		my $vmDetailsDir = "/var/systemInformation/content/system_details/${origVmname}";
		if ( ! -d "${vmDetailsDir}" ) { mkdir("${vmDetailsDir}"); }
		if ( -f "${vmDetailsDir}/project.txt" )
		{
			$project = "";
			open($fh3, "<", "${vmDetailsDir}/project.txt");
			foreach my $projectLine (<$fh3>)
			{
				chomp($projectLine);
				$project = "${project}" . $projectLine;
			}
			close($fh3);
			$projectSet = "true";
		} else { print("${vmDetailsDir}/project.txt not present\n" ); }
		if ( -f "${vmDetailsDir}/contact.txt" )
		{
			$contact = "";
			open($fh3, "<", "${vmDetailsDir}/contact.txt");
			foreach my $contactLine (<$fh3>)
			{
				chomp($contactLine);
				$contact = "${contact}" . $contactLine;
			}
			close($fh3);
			$contactSet = "true";
		} else { print("${vmDetailsDir}/contact.txt not present\n" ); }
		if ( -f "${vmDetailsDir}/usage.txt" )
		{
			$usage = "";
			open($fh3, "<", "${vmDetailsDir}/usage.txt");
			foreach my $usageLine (<$fh3>)
			{
				chomp($usageLine);
				$usage = "${usage}" . $usageLine;
			}
			close($fh3);
			$usageSet = "true";
		} else { print("${vmDetailsDir}/usage.txt not present\n" ); }
		if ( -f "${vmDetailsDir}/prefix.txt" )
		{
			$prefix = "";
			open($fh3, "<", "${vmDetailsDir}/prefix.txt");
			foreach my $prefixLine (<$fh3>)
			{
				chomp($prefixLine);
				$prefix = "${prefix}" . $prefixLine;
			}
			close($fh3);
			$prefixSet = "true";
		} else { print("${vmDetailsDir}/prefix.txt not present\n" ); }
		if ( -f "${vmDetailsDir}/notes.txt" )
		{
			$notes = "";
			open($fh3, "<", "${vmDetailsDir}/notes.txt");
			foreach my $notesLine (<$fh3>)
			{
				chomp($notesLine);
				$notes = "${notes}" . $notesLine;
			}
			close($fh3);
			$notesSet = "true";
		} else { print("${vmDetailsDir}/notes.txt not present\n" ); }
	
		# the following are cached - the files are deleted regularly to ensure refresh
		if ( -f "${vmDetailsDir}/type.txt" )
		{
			$type = "";
			open($fh3, "<", "${vmDetailsDir}/type.txt" );
			printDebug("reading type from cache for ${origVmname}\n");
			foreach my $typeLine (<$fh3>)
			{
				chomp($typeLine);
				$type = "${type}" . $typeLine;
			}
			printDebug("type is ${type}\n");
			$typeSet = "true";
			close($fh3);
		}
		else
		{
			printDebug("no type cached for ${origVmname}\n");
		}
		if ( -f "${vmDetailsDir}/os.txt" )
		{
			$os = "";
			open($fh3, "<", "${vmDetailsDir}/os.txt" );
			printDebug("reading os from cache for ${origVmname}\n");
			foreach my $osLine (<$fh3>)
			{
				chomp($osLine);
				$os = "${os}" . $osLine;
			}
			printDebug("os is ${os}\n");
			$osSet = "true";
			close($fh3);
		}
		else
		{
			printDebug("no os cached for ${origVmname}\n");
		}
	
		if($notesSet eq "true" 
			&& $contactSet eq "true"
			&& $usageSet eq "true"
			&& $projectSet eq "true"
			&& $osSet eq "true"
			&& $typeSet eq "true"
			&& $prefixSet eq "true"
			)
		{
			printDebug("all parameters set by local files\n");
			$newline = join(":", $vmname, $physhost, $ip, $vmstate, $numCpus, $maxMem, $usedMem, $contact , $type , $os , $usage , $project, $prefix, $notes );
		}	
		else
		{
	
			if( "" ne ipResolve($vmname))
			{
				$p = Net::Ping->new("tcp",1);
				$p->port_number( $port );
				if($p->ping($ip))
				{
					$url = "http://".${ip}.":".$port."/collatedVMDetails.txt";
					if(get($url))
					{
						chomp($collatedDetails=get($url));
						$inOs = "";
						$inType = "";
						($inContact, $location, $inUsage, $inProject, $inNotes , $inOs,  $inType) = split(/:/,$collatedDetails);
						if(!defined($inOs) ) { $inOs = ""; }
						if(!defined($inType) ) { $inType = ""; }
						if($notesSet eq "false") { $notes = $inNotes; $notesSet = "true"; }
						if($contactSet eq "false") { $contact = $inContact; $contactSet = "true"; }
						if($usageSet eq "false") { $usage = $inUsage; $usageSet = "true"; }
						if($projectSet eq "false") { $project = $inProject; $projectSet = "true"; }
						if($osSet eq "false" ) 
						{ 	
							if($inOs ne "")
							{
								printDebug("read os from collatedVMDetails.txt\n");
								$os = $inOs;
								$osSet = "true";
								if("$os" eq "noanswer" || "$os" eq "" )
								{
									printDebug("not writing os to cache for ${origVmname} as no answer received\n");
								}
								else
								{
									open($fh3, ">", "/var/systemInformation/content/system_details/${origVmname}/os.txt" );
									print $fh3 ("$os");
									printDebug("writing os (${os})to cache for ${origVmname}\n");
									close($fh3);
								}
							}
							else
							{
								printDebug("os set in collatedVMDetails, but empty\n");
							}
						}
						if($typeSet eq "false" )
						{
							if($inType ne "")
							{
								$type = $inType;
								$typeSet = "true";
								if("$type" eq "noanswer" || "$type" eq "" )
								{
									printDebug("not writing type to cache for ${origVmname} as no answer received\n");
								}
								else
								{
									open($fh3, ">", "/var/systemInformation/content/system_details/${origVmname}/type.txt" );
									print $fh3 ("$type");
									printDebug("writing type (${type}) to cache for ${origVmname}\n");
									close($fh3);
								}
							}
							else
							{
								printDebug("type set in collatedVMDetails, but empty\n");
							}
						}
					}
					else
					{
						printDebug("could not get $url\n");
					}
					if($projectSet eq "false")
					{
						$url = "http://".${ip}.":".$port."/project.txt";
						if(get($url))
						{
							chomp($project=get($url));
						} 
						else
						{
							$project="unset";
							printDebug("could not get $url\n");
						}
					}
					if($contactSet eq "false")
					{
						$url = "http://".${ip}.":".$port."/contact.txt";
						if(get($url)){chomp($contact=get($url));}else{$contact="unset";printDebug("could not get $url\n");}
					}
					if($usageSet eq "false")
					{
						$url = "http://".${ip}.":".$port."/usage.txt";
						if(get($url)){chomp($usage=get($url));}else{$usage="unset";printDebug("could not get $url\n");}
					}
					if($notesSet eq "false")
					{
						$url = "http://".${ip}.":".$port."/notes.txt";
						if(get($url)){chomp($notes=get($url));}else{$notes="";printDebug("could not get $url\n");}
					}
					if($osSet eq "false")
					{
						$url = "http://".${ip}.":".$port."/os.txt";
						if(get($url))
						{
							chomp($os=get($url));
							printDebug("os is set to ${os} from ${url}\n");
						}
						else
						{
							printDebug("could not get $url\n");
							$url = "http://".${ip}.":".${port}."/os.pl";
							if(get($url))
							{
								chomp($os=get($url));
								printDebug("os is set to ${os} from ${url}\n");
							}
							else
							{
								$os="";
								printDebug("could not get $url\n");
							}
						}
						if("${os}" eq "noanswer" || "${os}" eq "" )
						{
							printDebug("not writing os to cache for ${origVmname} as no answer received\n");
						}
						else
						{
							open($fh3, ">", "/var/systemInformation/content/system_details/${origVmname}/os.txt" );
							print $fh3 ("$os");
							printDebug("writing os (${os}) to cache for ${origVmname}\n");
							close($fh3);
						}
					}
					else
					{
						printDebug("osSet is true - os is set to $os ...?\n");
					}
					if($typeSet eq "false")
					{
						$url = "http://".${ip}.":".$port."/type.pl";
						if(get($url))
						{
							printDebug("type is set to ${type} prior to reading ${url}\n");
							chomp($type=get($url));
							printDebug("type is set to ${type} from ${url}\n");
						}
						else
						{
							printDebug("could not get $url\n");
							$url="http://".${ip}.":".$port."/type.txt";
							if(get($url))
							{
								chomp($type=get($url));
							}
							else
							{
								printDebug("could not get $url\n");
								$type="unknown";
							}
						}
						if("$type" eq "noanswer" || "$type" eq "" )
						{
							printDebug("not writing type to cache for ${origVmname} as no answer received\n");
						}
						else
						{
							open($fh3, ">", "/var/systemInformation/content/system_details/${origVmname}/type.txt" );
							print $fh3 ("$type");
							printDebug("writing type (${type}) to cache for ${origVmname}\n");
							close($fh3);
						}
					}
					printDebug("${vmname}: $type\n");
				}
				
				if(!$os){$os="";}
				if(!$type){$type="";}
				$os =~ s/\r//g;
				$vmname=cleanString($vmname);
				$physhost=cleanString($physhost);
				$physhost=cleanString($physhost);
				$ip=cleanString($ip);
				$vmstate=cleanString($vmstate);
				$numCpus=cleanString($numCpus);
				$maxMem=cleanString($maxMem);
				$usedMem=cleanString($usedMem);
				$contact=cleanString($contact);
				$type=cleanString($type);
				$os=cleanString($os);
				$usage=cleanString($usage);
				$project=cleanString($project);
				$notes=cleanString($notes);
				$prefix=cleanString($prefix);
				$newline = join(":", $vmname, $physhost, $ip, $vmstate, $numCpus, $maxMem, $usedMem, $contact , $type , $os , $usage , $project, $prefix, $notes );
				
			}
			else
			{
				$newline = "$vmname:$physhost:not resolved:::::::::::";
			}
		}
		$info = $info . $newline."\n";
		#print($newline,"\n");
	}
	else
	{
		print("Could not resolve ${vmname} (on ${physhost})\n");
	}
}

open($fh2,">","/var/systemInformation/content/vmRawDetails.txt");
print($fh2 $info,"\n");
close($fh2);

exit 0;
