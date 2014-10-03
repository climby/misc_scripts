#!/usr/bin/perl

##------------------------------------------------------------------------------
# Description:
#
# Create Grandstream GXP1165 phonebook from Elastix 2.4 web portal.
# All phone extensions are configured in Elastix 2.4 web portal.
# This script would export phone extensions to an xml phonebook for GXP1165
#
#------------------------------------------------------------------------------

use strict;
use warnings;
use LWP;
use Data::Dumper;

my $UA = LWP::UserAgent->new();
push @{ $UA->requests_redirectable }, 'POST';
$UA->cookie_jar( {} );

sub get_ua {
    return $UA;
}

#login elastix
sub login {
    my $login_url = shift;
    my $user      = shift;
    my $password  = shift;

    my $ua       = get_ua();
    my $response = $ua->post(
        $login_url,
        {   'input_user'   => 'admin',
            'input_pass'   => 'xpassw0rdh',
            'submit_login' => 1
        }
    );

    if ( $response->is_success ) {
        my $content = $response->content;
        if ( $content =~ /Dashboard/mgi ) {
            return 1;
        }
    }

    die "login fail" . $response->status_line;
}

sub get_page {
    my $url = shift;

    my $ua       = get_ua();
    my $response = $ua->get($url);

    if ( $response->is_success ) {
        return $response->content;
    }
    else {
        die "can't access $url.Status:" . $response->status_line;
    }
}

#main

my $login_url = "https://192.168.66.254/index.php";
my $is_login = login( $login_url, "admin", "xpassw0rdh" );

my $extension_url
    = 'https://192.168.66.254/?menu=pbxconfig&type=setup&display=extensions';

my $extension_page = get_page($extension_url);

my @phone_book = $extension_page =~ /^\s*<li><a[^>]+display=(\d+)">([^&]+)\s+&/mg;

my %phone_hash = @phone_book;

my $fh;
open ($fh, ">", "phone_book.xml") or die $!;

print $fh  <<"EOF";
<?xml version="1.0" encoding="UTF-8"?>
<AddressBook>

EOF

foreach my $number (sort keys %phone_hash) {
    my $name = $phone_hash{$number};
    next if ($name eq "mingzi");
    print $fh <<"TXT";
    <Contact>
        <FirstName></FirstName>
        <LastName>$name</LastName>
        <Phone>
            <phonenumber>$number</phonenumber>
            <accountindex>0</accountindex>
            <download>0</download>
        </Phone>
    </Contact>    
TXT
    
}

print $fh  "\n</AddressBook>\n";
close $fh;

