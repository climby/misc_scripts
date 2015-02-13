#!/usr/bin/perl 

use strict;
use warnings;
no warnings 'uninitialized';
use utf8;

my $input = $ARGV[0];


my ( $date, $time, $transaction, $amount, $agent_number, $agent_name,
	$balance );

if ( $input =~
/Confirmed\.\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M)\s+(Withdraw)\s+[^\d]+([\.,\d]+)\s+from\s+(\d+)\s+-\s([^\n]+).*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	(
		$date, $time, $transaction, $amount, $agent_number, $agent_name,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7 );
}
elsif ( $input =~
/Confirmed\.\s+.*(received)\s+[^\d]+([\.,\d]+)\s+from\s+([^\d]+)\s+(\d+)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M)\s+.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	(
		$transaction, $amount, $agent_name, $agent_number, $date, $time,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7 );
}
elsif ( $input =~
/Confirmed\.\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M)\s+(Give)\s+[^\d]+([\.,\d]+)\s+.*to\s+([^\n]+).*New.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	( $date, $time, $transaction, $amount, $agent_name, $balance ) =
	  ( $1, $2, $3, $4, $5, $6 );
}
elsif ( $input =~
/Confirmed\.\s+.*(bought)\s+[^\d]+([\.,\d]+)\s+.*of\s+(.*)\s+(?:for)?\s*(\d*)\s*on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*New.*balance\s+is[^\d]+([\.,\d]+).*/msi
  )
{
	(
		$transaction, $amount, $agent_name, $agent_number, $date, $time,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7 );
}
elsif ( $input =~
/Confirmed\.\s+[^\d]+([\.,\d]+)\s+(sent)\s+to\s+([^\d]+)\s+(\d+)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*New.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	(
		$amount, $transaction, $agent_name, $agent_number, $date, $time,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7 );
}
elsif ( $input =~
/Confirmed\..*repaid\s+(loan)\s+[^\d]+([\.,\d]+)\s+from\s+(.*)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*balance\s+is[^\d]+([\.,\d]+).*loan/msi
  )
{
	( $transaction, $amount, $agent_name, $date, $time, $balance ) =
	  ( $1, $2, $3, $4, $5, $6 );
}


print "$date,$time,$transaction,$amount,$agent_number,$agent_name,$balance\n";
