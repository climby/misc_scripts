#!/usr/bin/perl

use strict;
use warnings;
use HTML::TreeBuilder::XPath;
use URI;
use URI::QueryParam;
use LWP;

#------------------------------------------------------------------------------
#
# Call handler to fetch match score and write file according url characters
#
#-----------------------------------------------------------------------------
sub write_score_file {
    my $url = shift;

    return if ( !$url );

    my $team_flag = 0;
    $team_flag = 1 if ( $url =~ m{/2ndstage/}i );
    my $uri_obj = URI->new($url);
    my $type    = $uri_obj->query_param('s_Event_Type')
        || $uri_obj->query_param('Event_Type');
    $type = $type ? $type : '';

    if ($team_flag) {
        print "get team race:$url\n";
        open my $team_cmd_fh, "perl team.pl '$url'|";
        while ( my $output_line = <$team_cmd_fh> ) {
            print "[team]:" . $output_line;
        }
    } elsif ($type) {

        if ( $type =~ /^(M|W)S(P|Q)?$/ ) {
            print "get single race:$url\n";
            open my $single_cmd_fh, "perl single.pl  '$url' | ";
            while ( my $output_line = <$single_cmd_fh> ) {
                print "[single]:" . $output_line;
            }
        }
        if ( $type =~ /^(M|W)(D|Q)$/ ) {
            print "get double race:$url\n";
            open my $double_cmd_fh, "perl double.pl '$url' |";
            while ( my $output_line = <$double_cmd_fh> ) {
                print "[double]:" . $output_line;
            }
        }
    }

}

#------------------------------------------------------------------------------
# print help
#------------------------------------------------------------------------------
sub print_help {
    print <<"TXT";
  
Usage:
------------------------------------------------------------------------------- 
   $0  <start Competition_ID>  [end Competition_ID]

   start Competition_ID  mandatory   From this competition ID to scrape web page
   end Competition_ID    optional    scape data from the start competition ID
                                     to the end competition ID
TXT
}

#------------------------------------------------------------------------------
# main start
#------------------------------------------------------------------------------
my $START_ID;
my $END_ID;

# get command line arguments

if ( @ARGV < 1 ) {
    print_help();
    exit();
}

$START_ID = $ARGV[0];
$END_ID = $ARGV[1] ? $ARGV[1] : $ARGV[0];

if ( $START_ID !~ /^\d+$/ or $END_ID !~ /^\d+$/ ) {
    print_help();
    die "ERROR: invalid competitin ID!";
}

my $ua = LWP::UserAgent->new();

my $file = "url.txt";
my $fh;

open $fh, ">", $file or die $!;

foreach my $id ( $START_ID .. $END_ID ) {
    my $url
        = q(http://ittf.com/competitions/competitions2.asp?Competition_ID=)
        . $id
        . q(&category=Special);
    print "URL:$url\n";
    my $resp = $ua->get($url);
    if ( $resp && $resp->is_success ) {
        my $html     = $resp->content();
        my $tree_obj = HTML::TreeBuilder::XPath->new();
        $tree_obj->parse($html);

        my $xpath
            = q{//table[@width = '170' and ./tr[2][contains(.,'Main Draw')]]|//table[@width = '170' and ./tr[2][contains(.,'2nd Stage')]]|//table[@width = '170' and ./tr[2][contains(.,'Qualification')]] };
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
my $hash_ref = {};
open $fh, "<", $file or die $!;
while ( my $line = <$fh> ) {
    chomp $line;
    if ( exists $hash_ref->{$line} ) {
        next;
    } else {
        $hash_ref->{$line} = 1;
    }
    write_score_file($line);
}

