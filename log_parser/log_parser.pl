#/usr/bin/perl

use Tie::File;

my $file = "./test/example.log";
my @file_content;

#use Tie::File to read file. It will not load the file into memory totally
tie @file_content, 'Tie::File', $file or die $!;

foreach my $line (@file_content) {

    next if ( $line =~ /^\s*$/ );

    #ignore the corrupt lines which are not start with <\d+> and end with "]";
    next if ( $line !~ /^\s*<\d+>.*\]\s*$/ );
    print "raw log line:\n";
    print "$line\n";
    print "="x(80)."\n" ;
    my ($data_log,     $hostname,      $httpd_status_code,
        $request_time, $geoip_country, $geoip_organization,
        $request,      $refer,         $source_log
        )
        = $line
        =~ /\[([^\]]+)\] \[([^\]]+)\] \[(\d+)\] \[([\d\.]+)\] \[-\] \[[\d\.]+\] \[([^\]]+)\] \[([^\]]+)\] \[\d+\] \[\d+\] \[-\] \[[^\]]+\] \[(.*)\s*HTTP[^\]]+\] \[([^\]]+)\] \[([^\]]+)\]/i;

    print "hostname:$hostname\n";
    print "httpd_status_code:$httpd_status_code\n";
    print "request_time:$request_time\n";
    print "geoip_country:$geoip_country\n";
    print "geoip_organization:$geoip_organization\n";
    print "request:$request\n";
    print "refer:$refer\n";
    print "source_log:$source_log\n";
    print "data_log:$data_log\n";
    print "\n";

}

