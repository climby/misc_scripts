#!/usr/bin/perl

use DBI;

my $database = 'qubitsmi';
my $hostname = 'localhost';
my $user     = 'root';
my $password = '******';

my $dsn = "DBI:mysql:database=$database;host=$hostname";

my $dbh = DBI->connect( $dsn, $user, $password, { 'RaiseError' => 1 } );

my $sql  = "SELECT `id`,`one` FROM p_test";
my $rs   = $dbh->selectcol_arrayref( $sql, { Columns => [ 1, 2 ] } );
my $i    = 0;
my %hash = @$rs;
open my $fh, ">", "log.txt" or die $!;
foreach my $id ( keys %hash ) {
	my $str    = $hash{$id};
	my $output = `/usr/bin/perl ./regex_extract.pl "$str" `;
	print $fh "ID:$id\n";
	print $fh "raw:\n";
	print $fh $str, "\n";
	print $fh "=" x (80), "\n";
	print $fh "result:" . $output;
	print $fh "=" x (80), "\n\n\n";
	$i++ if ( $output =~ /,,,,,/ );

}

my $total = scalar(@$rs);
print $fh "Summary:\n";
print $fh "Total Records:", $total, "\n";
print $fh "Processed Records:", $total - $i, "\n";
print $fh "Non processed Records:", $i, "\n";

close $fh;

