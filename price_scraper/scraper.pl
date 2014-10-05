#!/bin/perl

use LWP::UserAgent;
use HTML::TreeBuilder::XPath;

# since there are non ascii characters in the page.
# use utf8 to handle all output
use utf8;
binmode( STDIN,  ':encoding(utf8)' );
binmode( STDOUT, ':encoding(utf8)' );
binmode( STDERR, ':encoding(utf8)' );
use Data::Dumper;

my $url = "http://www.theoutnet.com/en-DE/Shop/Clothing";

my $ua       = LWP::UserAgent->new( requests_redirectable => [] );
my $response = $ua->get($url);
my $content  = $response->decoded_content;

# save the webpage as a file for parsing
open my $fh, ">", "file.html" or die $!;
print $fh $content;

my $tree = HTML::TreeBuilder::XPath->new_from_file('file.html');

# find out the item block in the webpage
my @items = $tree->findnodes('//div[@class="product-details"');

for my $i (@items) {
	my $item_name       = $i->findvalue('span[@itemprop="name"]');
	my $orig_price      = $i->findvalue('./div/div[@itemprop="price"]/span');
	my $now_price       = $i->findvalue('./div/div/div/span[@class="now-price"]');
    print $item_name . "\n";
	print $orig_price . "   Now price:" . $now_price . "\n";
	print "=" x (80) . "\n";

}

