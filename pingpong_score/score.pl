#!/usr/bin/perl

use strict;
use warnings;
use HTML::TreeBuilder::XPath;
use URI;
use URI::QueryParam;
use LWP;

my $START_ID = 2200; 
my $END_ID   = 2300;

my $ua = LWP::UserAgent->new();

my $file = "url.txt";
my $fh;

open $fh, ">", $file or die $!;

foreach my $id ( $START_ID .. $END_ID ) {
	my $url =
	  q(http://ittf.com/competitions/competitions2.asp?Competition_ID=) . $id;
	print "URL:$url\n";
	my $resp = $ua->get($url);
	if ( $resp && $resp->is_success ) {
		my $html     = $resp->content();
		my $tree_obj = HTML::TreeBuilder::XPath->new();
		$tree_obj->parse($html);

		my $xpath =
q{//table[@width = '170' and contains(.,'Main Draw')]|//table[@width = '170' and contains(.,'2nd Stage')] };
		my $node = $tree_obj->findnodes($xpath)->[0];
		next if ( !$node );
		foreach my $link_node ( $node->findnodes('.//a') ) {
			my $link_url = $link_node->findvalue('./@href');
			if ( $link_url !~ /^http:/ ) {

				# relative url
				$link_url = URI->new_abs( $link_url, $url );

				# remove the /../
				$link_url =~ s/\/\.\.//g;
			}
			print $fh $link_url, "\n";
		}
	}

}

close $fh;

=cut 

# read the url file and fetch the webpage
open $fh, "<", $file or die $!;
while ( my $line = <$fh> ) {
	chomp $line;
	my $uri_obj = URI->new($line);
	my $type    = $uri_obj->query_param('s_Event_Type');
	next if ( !$type );
	if ( ( $type eq 'MS' ) or ( $type eq 'WS' ) ) {
		`perl single.pl  $line`;
	}
	if ( ( $type eq 'MD' ) or ( $type eq 'WD' ) ) {
		`perl double.pl  $line`;
	}
}

=cut 