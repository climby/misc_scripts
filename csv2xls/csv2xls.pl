#!/bin/perl

use strict;
use warnings;
use utf8;
use Spreadsheet::WriteExcel;
use POSIX;
use Data::Dumper;

my $dir = $ARGV[0] || '.';
my @files = glob "$dir/All_deals_*.csv";
die "Can't find file All_deals_*.csv in directory:'$dir'"
  if ( scalar(@files) < 1 );
my $in_csv = pop @files;

my $date_str = strftime( "%Y%m%d", localtime );
my $out_xls = "Ordrar ML ${date_str}.xls";

#print $out_xls ;

# Create a new Excel workbook
my $workbook = Spreadsheet::WriteExcel->new($out_xls);

# Add a worksheet
my $worksheet = $workbook->add_worksheet();

# make number be displayed as text
my $format1 = $workbook->add_format(num_format => '@');

#open the csv file
open my $fh, "<:encoding(Latin1)", $in_csv or die $!;
binmode STDOUT, ':encoding(UTF-8)';
my $line_number = 0;
my @header      = (
	'Referens',  'Aktivitet', 'Premie',          'Alt b',
	'Alt c',     'Alt d',     'Alt e',           'Efternamn',
	'Förnamn',  'Co Adress', 'Adress',          'Postnr',
	'Postort',   'Personnr',  'Betalningssätt', 'Antal lotter',
	'Telefonnr', 'Mobilnr',   'Land kod',        'Bild/Ljud',
	'Kundnr',    'e-post',    'Nyhetsbrev',      'AdressID',
	'U-kod'
);
while ( my $line = <$fh> ) {
	chomp($line);
	my @colums = split /;/, $line;

	# remove double quote
	for ( my $i = 0 ; $i < scalar(@colums) ; $i++ ) {
		$colums[$i] =~ s/"(.*)"/$1/;
	}

	# copy header
	if ( $line_number == 0 ) {
		for ( my $i = 0 ; $i < 25 ; $i++ ) {
			$worksheet->write_string( $line_number, $i, $header[$i] );
		}
		$line_number++;
		next;
	}

	#Column A is empty
	$worksheet->write_string( $line_number, 0, '' );

	#Colum B
	my $B_content = $colums[25];
	$B_content =~ s/\d+//g;
	my $month_day = strftime( "%m%y", localtime );
	$B_content .= $month_day;
	$worksheet->write_string( $line_number, 1, $B_content );

	# Colum C D E F G are empty
	for my $i ( 2 .. 6 ) {
		$worksheet->write_string( $line_number, $i, '' );
	}

	# Colum H
	my $H_content = $colums[2];
	$worksheet->write_string( $line_number, 7, $H_content );

	# Colum I
	my $I_content = $colums[1];
	$worksheet->write_string( $line_number, 8, $I_content );

	#Column J is empty
	$worksheet->write_string( $line_number, 9, '' );

	# Colum K
	my $K_content = $colums[8];
	$worksheet->write_string( $line_number, 10, $K_content );

	# Colum L
	my $L_content = $colums[9];
	$worksheet->write_string( $line_number, 11, $L_content,$format1 );

	# Colum M
	my $M_content = $colums[11];
	$worksheet->write_string( $line_number, 12, $M_content );

	# Colum N
	my $N_content = $colums[6];
	$worksheet->write_string( $line_number, 13, $N_content ,$format1);

	# Colum O
	my $O_content = "EK";
	$worksheet->write_string( $line_number, 14, $O_content );

	# Colum P
	my $P_content = "6";
	$worksheet->write_string( $line_number, 15, $P_content,$format1 );

	# Colum Q
	my $Q_content = $colums[12];

	if ( $Q_content =~ /^0?7/ ) {
		$Q_content = '';
	}
	else {
		if ( $Q_content =~ /^0/ ) {
			$Q_content =~ s/(0\d\d)(.*)/${1}-$2/;
		}
		else {
			$Q_content =~ s/(\d\d)(.*)/0${1}-$2/;
		}
	}
	$worksheet->write_string( $line_number, 16, $Q_content );

	# Colum R
	my $R_content = $colums[12];
	if ( $R_content =~ /^0?7/ ) {
		if ( $R_content =~ /^0/ ) {
			$R_content =~ s/(0\d\d)(.*)/${1}-$2/;
		}
		else {
			$R_content =~ s/(\d\d)(.*)/0${1}-$2/;
		}
	}
	else {
		$R_content = '';
	}
	$worksheet->write_string( $line_number, 17, $R_content );

	# Colum S
	my $S_content = "1";
	$worksheet->write_string( $line_number, 18, $S_content ,$format1);

	# Colum T
	my $T_content = $colums[6];
	$worksheet->write_string( $line_number, 19, $T_content ,$format1);

	for my $i ( 20 .. 24 ) {
		$worksheet->write_string( $line_number, $i, '' );
	}

	$line_number++;
}

