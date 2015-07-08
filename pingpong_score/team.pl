#!/usr/bin/perl 

use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder::XPath;
use Data::Dumper;
use URI;
use URI::QueryParam;

my $url = $ARGV[0];
#$url =
#q{http://ittf.com/ittf_team_events/2ndstage/teams_2nd_stage_16_positions_wttc_print_2.asp?Tour_Code=2278&Event_Type=mstm2&team_stage=112};

my $ua = LWP::UserAgent->new;
my $resp;
my @team_match_urls = ();
my %matches;

my $uri_obj    = URI->new($url);
my $type       = $uri_obj->query_param('Event_Type');
my $tour_code  = $uri_obj->query_param('Tour_Code');
my $team_stage = $uri_obj->query_param('team_stage');

$resp = $ua->get($url);

exit if ( !$resp->is_success );

my $html = $resp->content;
$html =~ s/&nbsp;/ /msig;
my $tree = new HTML::TreeBuilder::XPath;
$tree->parse($html);
my $table_xpath = q{/html/body/div/div/table/tr/td/table};
my $table_node  = $tree->findnodes($table_xpath)->[0];
foreach my $node ( $table_node->findnodes('tr/td/a') ) {
	my $text = $node->findvalue('.');
	if ( $text =~ /^\s*\d+\s+-\s+\d+\s*$/ ) {
		my $href = $node->findvalue('@href');
		$href =~ s/\s*$//g;
		my $abs_href = URI->new_abs( $href, $url );
		push( @team_match_urls, $abs_href );
	}
}

foreach my $team_url (@team_match_urls) {
	$resp = $ua->get($team_url);
	if ( $resp && $resp->is_success ) {
		my $html = $resp->content;
		$html =~ s/&nbsp;/ /msig;
		my $tree = new HTML::TreeBuilder::XPath;
		$tree->parse($html);

		my $head_table_xpath = q{//table[@id='table1']};
		my $head_table_node  = $tree->findnodes($head_table_xpath)->[0];
		my $head1            = $head_table_node->findvalue('tr/td[2]');
		my $head2            = $head_table_node->findvalue('tr/td[3]');

		my $team = "$head1:$head2";

		my $xpath    = q{/html/body/div[1]/table/tr/td/table[1]};
		my $node     = $tree->findnodes($xpath)->[0];
		my $match_id = $node->findvalue('tr[2]/td[2]');
		$match_id =~ s/^[^\d]+//g;
		my $date = $node->findvalue('tr[3]/td[3]');
		my $time = $node->findvalue('tr[3]/td[4]');

		my $date_time = "$date $time";

		$xpath = q{/html/body/div/table/tr/td/table[2]};
		$node  = $tree->findnodes($xpath)->[0];
		my $i = 0;
		$matches{$match_id} = [];
		foreach my $row_node ( $node->findnodes('tr/td[1]/b/font[text()]') ) {
			my $player1 = $row_node->findvalue('../../text()');
			my $player2 = $row_node->findvalue('../../../td[4]/text()');
			my $score1  = $row_node->findvalue('.');
			my $score2  = $row_node->findvalue('../../../td[4]/b/font');
			my $line_team;
			if ( $i == 0 ) {
				$line_team = $team;
				$i++;
			}
			else {
				$line_team = '';
			}

			my $line = sprintf( "%s,%s,%s,%s,%s,%s,%d,%d",
				$type, $match_id, $date_time, $line_team, $player1, $player2,
				$score1, $score2 );

			push @{ $matches{$match_id} }, $line;
		}
	}
}

# write to csv file
my $file = "pingpong_${type}_${tour_code}_${team_stage}.csv";
open my $fh, ">", $file or die $!;
print $fh chr(65279);
my $title =
  "项目,轮次,时间,团队,运动员1,运动员2,得分1,得分2\n";
print $fh $title;
foreach my $match_id ( sort keys %matches ) {
	my $match_ref = $matches{$match_id};
	foreach my $line (@$match_ref) {
		print $fh "$line\n";
	}
}
close $fh;
