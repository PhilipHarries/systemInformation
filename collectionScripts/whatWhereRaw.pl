#!/usr/bin/perl

use warnings;
use strict;

use Socket;
use Net::Ping;
use LWP::Simple;
use Net::DNS;

my $fd;

open($fd,">","/var/systemInformation/content/whatWhereRaw.txt");

my $ping;
my $proto = getprotobyname('tcp');
my $port = 5898;
my $url = "";
my $resolver = Net::DNS::Resolver->new();
my @systemNames;
my @physicalHosts;
my $vmDetails;
my $domains = [ 'x.y.z.com', 'a.b.c.com', 'p.q.r.co.uk' ];
my @zone;
foreach my $domain (@$domains)
{
        @zone = $resolver->axfr($domain);
        foreach my $resolvedRecord (@zone)
        {
                if($resolvedRecord->type() eq "A")
                {
                        if(        $resolvedRecord->name() !~ /vip/
                                && $resolvedRecord->name() !~ /ora/
                                && $resolvedRecord->name() !~ /scan/
                                && $resolvedRecord->name() !~ /vip/
                                && $resolvedRecord->name() !~ /gateway/
                                && $resolvedRecord->name() !~ /-apps/
                                && $resolvedRecord->name() !~ /ilo\./
                                && $resolvedRecord->name() !~ /eva/
                                && $resolvedRecord->name() !~ /defgw/
                                && $resolvedRecord->name() !~ /^lon[fg]sw/
                                && $resolvedRecord->name() !~ /^ch[12]-oa1/
                                && $resolvedRecord->name() !~ /^${domain}$/
                        )
                        {
                                push(@systemNames,$resolvedRecord->name());
                                #print("DEBUG: ", $resolvedRecord->name() . " has type A\n");
                        }
                }
        }
}

@physicalHosts=grep(/^serv|^ch1bl/,@systemNames);
foreach my $hostServer (@physicalHosts)
{
        $ping = Net::Ping->new("tcp", 1);
        $ping->port_number($port);
        if( $ping->ping($hostServer) )
        {
                $url = "http://" . $hostServer . ":" . $port . "/vmDetails.txt";
                if ( $vmDetails = get $url)
                {
                        my @vmInfo=split("\n",$vmDetails);
                        foreach my $aVmInfo (@vmInfo)
                        {
                                print $fd
                                (
                                        $aVmInfo,"\n",
                                );
                        }
                }
        }
}

close($fd);

exit 0;