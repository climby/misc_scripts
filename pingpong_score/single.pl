#!/usr/bin/perl 

use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder::XPath;
use Data::Dumper;
use URI;
use URI::QueryParam;
no warnings 'uninitialized';
no warnings 'utf8';

my $url = $ARGV[0];

my $uri            = URI->new($url);
my $competition_id = $uri->query_param('Competition_ID');
my $type           = $uri->query_param('s_Event_Type');
my $group_flag     = 0;
if ( $uri->query_param('Event_Type') ) {
	$group_flag = 1;
	$type       = $uri->query_param('Event_Type');
}

my ($type_str) = $type =~ /(\w{2})\w*/;

exit if ( !$competition_id );

my $fh;

# open csv file
my $file = "pingpong_${type_str}_${competition_id}.csv";

if ( -e $file ) {
	open $fh, ">>", $file or die $!;
}
else {
	open $fh, ">", $file or die $!;
	binmode $fh;
	print $fh chr(65279);
	
}

my $ua = LWP::UserAgent->new;
my $resp;
if ($group_flag) {
	my $score_hashref = {};
	if ( ( $resp = $ua->get($url) ) && ( $resp->is_success ) ) {
		print "#" x (80), "\n";
		print "#URL:$url\n";
		print "#" x (80), "\n";

		my $html = $resp->content;
		$html =~ s/&nbsp;/ /msig;
		my $tree = new HTML::TreeBuilder::XPath;
		$tree->parse($html);

		# get max score columns
		my $max_column_xpath =
q(/html/body/div/table/tr/td/p/table/tr[1]/td[2]/div/table/tr[2]/td[position() > '8']);
		my $max_column = 1;
		foreach my $column_node ( $tree->findnodes($max_column_xpath) ) {
			my $cell_value = $column_node->findvalue('.');
			my ($number) = $cell_value =~ /^\s*(\d+)\s*/;
			if ($number) {
				$max_column = $number;

			}
			else {
				last;
			}
		}

		$score_hashref->{'max_column'} = $max_column;
		my $row_xpath =
		  q(/html/body/div/table/tr/td/p/table/tr[1]/td[2]/div/table/tr);

		my $group;
		foreach my $row_node ( $tree->findnodes($row_xpath) ) {
			my $group_xpath = q(./td[@colspan = '22']/font/b/text()[1]);
			my $group_str   = $row_node->findvalue($group_xpath);
			if ( $group_str and ( $group_str ne $group ) ) {
				$group = $group_str;
				if ( !exists( $score_hashref->{$group} ) ) {
					$score_hashref->{$group} = [];
				}
				next;
			}
			if ($group) {
				my $name = $row_node->findvalue('td[7]/font[1]');
				next if ( !$name );
				my $line         = ",,$name";
				my $max_position = 8 + $max_column;
				my $score_xpath  =
				  $row_node->findnodes( 'td[position()> 7 and position() <'
					  . $max_position
					  . ' ]' );
				foreach my $score_node ( $score_xpath->get_nodelist ) {
					my $value = $score_node->getValue;
					$line .= ",$value";
				}
                $line =~  s/-/~/g;
				push( @{ $score_hashref->{$group} }, $line );
			}

		}

	}

	# print to csv file
	my $score_colum = join( ',', ( 1 .. $score_hashref->{max_column} ) );
	delete $score_hashref->{max_column};
	foreach my $one_group (
		sort { ( $a =~ /(\d+)\s*$/ )[0] <=> ( $b =~ /(\d+)\s*$/ )[0] }
		keys %{$score_hashref}
	  )
	{

		if ( $one_group =~ /Group\s+1\s*$/ ) {
			print  $fh "Begin,$one_group,比赛用名,$score_colum\n";
		}
		else {
			print  $fh ",$one_group,比赛用名,$score_colum\n";
		}

		foreach my $one_row ( @{ $score_hashref->{$one_group} } ) {
			print $fh  "$one_row\n";
		}
		print $fh "\n\n";
	}
}
else {
	
	my $title = "项目,轮次,时间,运动员1,运动员2,得分1,得分2\n";
    print $fh $title;
    
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
		my ( $player1, $player2, $score1, $score2, $time );
		for my $item ( $items->get_nodelist() ) {
			if ( $i % 4 == 1 ) {
				$player1 =
				  $item->findvalue('td[1]/font/text()[3]|td[1]/font/text()[6]');
			}
			if ( $i % 4 == 2 ) {
				my $sum_score = $item->findvalue('td[2]/font/b/font');
				( $score1, $score2 ) = $sum_score =~ /(\d+)-(\d+)/;
				$time = $item->findvalue('td[1]/font[1]/font[1]');

			}
			if ( $i % 4 == 0 ) {
				$player2 = $item->findvalue('td[1]/font[1]/font[2]/text()[2]');

				if ( $player1 && $player2 && $time && ( $score1 =~ /\d+/ ) ) {
					my $round_line =
"$race_name,$round,$time,$player1,$player2,$score1, $score2\n";
					print "$round_line";
					print $fh $round_line;
				}
			}

			$i++;

		}

		my $next_round_xpath =
		  q(/html/body/div/table/tr/td/table/tr[3]/td[3]/p/a);
		my $next_round_node = $tree->findnodes($next_round_xpath)->[0];
		my $next_round_href = $next_round_node->findvalue('@href');
		my $next_round_text = $next_round_node->findvalue('.');

		last if ( $next_round_text !~ /Next Round/i );

		my $next_round_url = URI->new_abs( $next_round_href, $url );

		$url = $next_round_url;
	}
}
