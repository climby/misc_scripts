#!/usr/bin/perl

use strict;
use warnings;
use HTML::TreeBuilder::XPath;
use URI;
use URI::QueryParam;
use LWP;

=cut

my $url = q(http://ittf.com/competitions/test/matches_per_round1.asp?s_Event_Type=MS&Competition_ID=2551&rnd=32);
my $uri_obj = URI->new($url);
my $type = $uri_obj->query_param('s_Event_Type');
print "$type\n";

=cut

my $ua = LWP::UserAgent->new();

foreach my $id ( 2100 .. 2300 ) {
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
		my $value = $node->findvalue('.');
		print "$id:$value\n";
	}

}
