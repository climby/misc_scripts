#!/usr/bin/perl 

use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder::XPath;
use Data::Dumper;
use URI;
use Encode;
use URI::QueryParam;
no warnings 'uninitialized';
no warnings 'utf8';

my $url = $ARGV[0];

my $uri            = URI->new($url);
my $competition_id = $uri->query_param('Competition_ID')
  || $uri->query_param('competition_ID');
my $type = $uri->query_param('s_Event_Type');
exit if ( !$competition_id );

$type = "MD" if ( $type eq 'MQ' );
$type = "WD" if ( $type eq 'WQ' );

my $fh;

# open csv file
my $file = "pingpong_${type}_${competition_id}.csv";

if ( -e $file ) {
	open $fh, ">>", $file or die $!;
}
else {
	open $fh, ">", $file or die $!;
	binmode $fh;
	print $fh chr(65279);
	my $title =
"项目,轮次,时间,运动员1,运动员2,运动员3,运动员4,得分1,得分2\n";

	print $fh $title;
}
my $ua = LWP::UserAgent->new;
my $resp;

while ( ( $resp = $ua->get($url) ) && ( $resp->is_success ) ) {

	print "#" x (80), "\n";
	print "#URL:$url\n";
	print "#" x (80), "\n";

	my $html = $resp->content;
	$html =~ s/&nbsp;/ /msig;
	my $tree = new HTML::TreeBuilder::XPath;
	$tree->parse($html);

	my $racename_xpath =
	  q(/html/body/div/table/tr/td/table/tr[2]/td[2]/p/b/font);
	my $race_title = $tree->findvalue($racename_xpath);

	my ( $race_name, $round ) = $race_title =~ /\s*(.*)\s*-\s*(.*)\s*/;

	$round =~ s/Round of//i;

	my $xpath = q(//table[@id='table1']/tr);
	my $items = $tree->findnodes($xpath);

	my $i = 1;
	my ( $player1, $player2, $player3, $player4, $score1, $score2, $time );
	for my $item ( $items->get_nodelist() ) {
		if ( $i % 4 == 1 ) {
			$player1 = $item->findvalue('td[1]/font/text()[3]');
			$player2 = $item->findvalue('td[1]/font/text()[6]');

		}
		if ( $i % 4 == 2 ) {
			my $sum_score = $item->findvalue('td[2]/font/b/font');
			( $score1, $score2 ) = $sum_score =~ /(\d+)-(\d+)/;
			$time = $item->findvalue('td[1]/font[1]/font[1]');

		}
		if ( $i % 4 == 0 ) {
			$player3 = $item->findvalue('td[1]/font[1]/font[2]/text()[2]');
			$player4 = $item->findvalue('td[1]/font[1]/font[2]/text()[5]');
			if ( $time && $player1 && $player3 && ( $score1 =~ /\d+/ ) ) {
				my $round_line =
"$race_name,$round,$time,$player1,$player2,$player3,$player4,$score1, $score2\n";
				print "$round_line";
				print $fh $round_line;
			}
		}

		$i++;

	}

	my $next_round_xpath = q(/html/body/div/table/tr/td/table/tr[3]/td[3]/p/a);
	my $next_round_node  = $tree->findnodes($next_round_xpath)->[0];
	my $next_round_href  = $next_round_node->findvalue('@href');
	my $next_round_text  = $next_round_node->findvalue('.');

	last if ( $next_round_text !~ /Next Round/i );

	my $next_round_url = URI->new_abs( $next_round_href, $url );

	$url = $next_round_url;
	sleep 1;

}
