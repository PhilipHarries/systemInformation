#!/usr/bin/perl

use warnings;
use strict;

my $hostname = `hostname`;


my $systemInformationDir = "/var/systemInformation/content";

my $datapoints = [ "contact", "location", "usage", "project", "notes" ];
my $collatedInfo = "";
my($temp, $filename);

my $fh;

foreach my $datapoint ( @$datapoints )
{
	$temp="";
	$filename = $systemInformationDir . "/" . ${datapoint} . ".txt";
	
	if ( -f $filename )
	{
		open( $fh, "<", $filename );
		foreach my $line ( <$fh> )
		{
			chomp($line);
			$line =~ s/:/-/g;
			$temp = $temp . $line;
		}
		close($fh);
	}
	$collatedInfo = $collatedInfo . ":" . $temp;
}
$collatedInfo =~ s/^://;

my $osType = getOSType();
my $osName = getOS();
my $type = "unknown";
$filename = $systemInformationDir . "/type.txt";
if ( -f $filename )
{
	$temp = "";
	open($fh, "<", $filename);
	foreach my $line ( <$fh> )
	{
		chomp($line);
		$temp = $temp . $line;
	}
	close($fh);
	$type = $temp;
}
elsif ("$osType" eq "Linux" )
{
	$type = getTypeLinux();
}

chomp($osName);
$osName =~ s/\n//g;

$collatedInfo = $collatedInfo . ":" . $osName . ":" . $type;

open( $fh, ">", $systemInformationDir . "/collatedVMDetails.txt") or die("could not open collatedVMDetails.txt!\n");
print $fh ( $collatedInfo . "\n" );
close($fh);


exit 0;


sub getOS
{
	my $filenameredhat = '/etc/redhat-release';
	my $filenamesolaris = '/etc/release';
	my $filenamewindows = 'C:\Windows';
	my $os = "";
	my $file;
	if( -e $filenameredhat )
	{
	        open $file, "<", $filenameredhat;
	        my @lines = <$file>;
	        chomp($lines[0]);
	        $os = ${lines[0]};
	        close ($file);
	}
	elsif( -e $filenamesolaris )
	{
	        open $file, "<", $filenamesolaris;
	        my @lines = <$file>;
	        $lines[0] =~ s/^ *//;
	        $lines[0] =~ s/\w+_\w+_\w+\s{1}.+//;
	        chomp($lines[0]);
	        $os = $lines[0];
	        close ($file);
	}
	elsif( -e $filenamewindows )
	{
	        my $release = `systeminfo | findstr /B /C:"OS Name"`;
	        $release =~ s/^OS Name:\s*M/M/;
	        chomp($release);
	        $os = $release;
	}
	else
	{
	        $os = "Operating System Not Known";
	}
	return $os;
}
sub getOSType
{
	my $filenameredhat = '/etc/redhat-release';
	my $filenamesolaris = '/etc/release';
	my $filenamewindows = 'C:\Windows';
	my $simpleOS = "";
	if( -e $filenameredhat )
	{
	        $simpleOS = "Linux";
	}
	elsif( -e $filenamesolaris )
	{
	        $simpleOS = "Solaris";
	}
	elsif( -e $filenamewindows )
	{
	        $simpleOS = "Windows";
	}
	else
	{
	        $simpleOS = "unknown";
	}
	return $simpleOS;
}
sub getTypeLinux
{
	my $type = `sudo -u root dmidecode --string system-product-name`;
	chomp $type;
	if( $type eq "KVM" )
	{
	        print("KVM");
	}
	else
	{
	        print("Physical");
	}
}
