#!/usr/bin/perl

use strict;
use warnings;
use HTML::TreeBuilder::XPath;
use URI;
use URI::QueryParam;
use LWP;

my $START_ID = 2278;
my $END_ID   = 2278;

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
q{//table[@width = '170' and ./tr[2][contains(.,'Main Draw')]]|//table[@width = '170' and ./tr[2][contains(.,'2nd Stage')]]|//table[@width = '170' and ./tr[2][contains(.,'Qualification')]] };
		my $node = $tree_obj->findnodes($xpath)->[0];
		next if ( !$node );
		my @matched_urls = ();
		foreach $node ( $tree_obj->findnodes($xpath)->get_nodelist() ) {
			foreach my $link_node ( $node->findnodes('.//a') ) {
				my $link_url = $link_node->findvalue('./@href');
				if ( $link_url !~ /^http:/ ) {

					# relative url
					$link_url = URI->new_abs( $link_url, $url );

					# remove the /../
					$link_url =~ s/\/\.\.//g;
				}
				push( @matched_urls, $link_url );

			}
		}

		# reverse the urls. start qualification matched
		foreach my $one_url ( reverse @matched_urls ) {
			print $fh $one_url, "\n";
		}
	}

}

close $fh;






# read the url file and fetch the webpage
open $fh, "<", $file or die $!;
while ( my $line = <$fh> ) {
	my $team_flag = 0;
	chomp $line;
	$team_flag = 1 if ( $line =~ m{/2ndstage/}i );
	my $uri_obj = URI->new($line);
	my $type    = $uri_obj->query_param('s_Event_Type') || $uri_obj->query_param('Event_Type');
	$type = $type ? $type : '';
	if ( $type or $team_flag ) {

		if (  $type =~ /^(M|W)S(P|Q)?$/) {
			`perl single.pl  $line`;
		}
		if (  $type =~ /^(M|W)(D|Q)$/) {
			`perl double.pl  $line`;
		}
		if ($team_flag) {
			`perl team.pl $line`;
		}
	}
}



