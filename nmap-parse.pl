#!/usr/bin/perl -w
#
# Joshua "Jabra" Abraham ( jabra@spl0it.org )
# 
# script to extract infomation from an nmap XML file
#
use strict;
use Getopt::Long;
use Nmap::Parser;
use vars qw( $PROG );
( $PROG = $0 ) =~ s/^.*[\/\\]//;    # Truncate calling path from the prog name

my $AUTH    = 'Joshua D. Abraham';  # author
my $VERSION = '1.00';               # version

my $np = new Nmap::Parser;          # parser object

my $xmlfile;
my %options;

#
# help ->
# display help information
# side effect:  exits program
#
sub help {
    print "Usage: $PROG [Input Options] [List or Search Options]
 Input option:
    -f  --file                      Input from file

 List options:
    -i  --iplist                    List all IP addresses.
        --hostlist                  List all hostnames.
    
 Search options:
    -p  --port NUM                  List IPs based on port.
    -s, --service STRING            List IPs based on service.\n";
    exit;
}

#
# print_version ->
# displays version
#
sub print_version {
    print "$PROG version $VERSION by $AUTH\n";
    exit;
}


GetOptions(
    \%options,
    'file|f=s',
    'hostlist', 'iplist|i',
    'port|p=s', 'service|s=s',
    'help|h'       => sub { help(); },
    'version|v'    => sub { print_version(); },
    'debug=s',
    )
    or exit 1;



if ( $options{file} ) {
    $np->parsefile($options{file});
}
else{
    help();
}

my @list;
if ( $options{iplist} ) {
    for my $host ( $np->all_hosts('up') ) {
        print $host->addr . "\n";
    }
}
elsif ( $options{hostlist} ) {
    for my $host ( $np->all_hosts('up') ) {
        if ($host->hostname eq '0'){
            print "Unknown Hostname\n";
        }
        else {
            print $host->hostname  . "\n";
        }
    }
}
elsif ( $options{port} ) {
    for my $host ($np->all_hosts()){
        if ( defined($host->tcp_port_state($options{port})) and
            $host->tcp_port_state($options{port}) eq 'open') {
            my $svc = $host->tcp_service($options{port});
            if (defined($svc->port) and $svc->port eq $options{port}){
                push(@list, $host->addr);
            }
        }
        if ( defined($host->udp_port_state($options{port})) and
            $host->udp_port_state($options{port}) eq 'open') {
            my $svc = $host->udp_service($options{port});
            if (defined($svc->port) and $svc->port eq $options{port}){
                push(@list, $host->addr);
            }
        }
    }
}
elsif ( $options{service} ){
    for my $host ($np->all_hosts()){
        for my $port ($host->tcp_open_ports() ){
            my $svc = $host->tcp_service($port);
            if (defined($svc->name) and $svc->name eq $options{service}){
                push(@list, $host->addr);
            }
        }
        for my $port ($host->udp_open_ports() ){
            my $svc = $host->tcp_service($port);
            if (defined($svc->name) and $svc->name eq $options{service}){
                push(@list, $host->addr);
            }
        }
    } 
}

foreach(@list){
    print "$_\n";
}
