#!/usr/bin/perl 

use strict;
use warnings;
no warnings 'uninitialized';
use utf8;

my $input = $ARGV[0];

my (
	$type,   $code,         $date,       $time, $transaction,
	$amount, $agent_number, $agent_name, $balance
);

if ( $input =~
/(.*)\s+Confirmed\.\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M)\s+(Withdraw)\s+[^\d]+([\.,\d]+)\s+from\s+(\d+)\s+-\s([^\n]+).*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	$type = 'Agent Withdraw';
	(
		$code, $date, $time, $transaction, $amount, $agent_number, $agent_name,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7, $8 );
}
elsif ( $input =~
/(.*)\s+Confirmed\.\s+.*(received)\s+[^\d]+([\.,\d]+)\s+from\s+([^\d]+)\s+(\d+)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M)\s+.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	$type = 'Receive';
	(
		$code, $transaction, $amount, $agent_name, $agent_number, $date, $time,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7, $8 );
}
elsif ( $input =~
/(.*)\s+Confirmed\.\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M)\s+(Give)\s+[^\d]+([\.,\d]+)\s+.*to\s+([^\n]+).*New.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	$type = 'Agent Deposit';
	( $code, $date, $time, $transaction, $amount, $agent_name, $balance ) =
	  ( $1, $2, $3, $4, $5, $6, $7 );
}
elsif ( $input =~
/(.*)\s+Confirmed\.\s+.*(bought)\s+[^\d]+([\.,\d]+)\s+.*of\s+(.*)\s+(?:for)?\s*(\d*)\s*on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*New.*balance\s+is[^\d]+([\.,\d]+).*/msi
  )
{
	(
		$code, $transaction, $amount, $agent_name, $agent_number, $date, $time,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7, $8 );
}
elsif ( $input =~
/(.*)\s+Confirmed\.\s+[^\d]+([\.,\d]+)\s+(sent)\s+to\s+([^\d]+)\s+(\d+)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*New.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	$type = 'Send';
	(
		$code, $amount, $transaction, $agent_name, $agent_number, $date, $time,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7, $8 );
}
elsif ( $input =~
/(.*)\s+Confirmed\.\s+[^\d]+([\.,\d]+)\s+(sent)\s+to\s+(.*)\s+for\s+(.*)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*New.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	$type = 'Paybill';
	(
		$code, $amount, $transaction, $agent_name, $agent_number, $date, $time,
		$balance
	) = ( $1, $2, $3, $4, $5, $6, $7, $8 );
}
elsif ( $input =~
/(.*)\s+Confirmed\..*repaid\s+(loan)\s+[^\d]+([\.,\d]+)\s+from\s+(.*)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*balance\s+is[^\d]+([\.,\d]+).*loan/msi
  )
{

	# ignore this type;
	#( $code, $transaction, $amount, $agent_name, $date, $time, $balance ) =
	#  ( $1, $2, $3, $4, $5, $6, $7 );
}
elsif ( $input =~
/(.*)\s+Confirmed\.\s+[^\d]+([\.,\d]+)\s+(paid)\s+to\s+(.*)\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M).*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	$type = 'Buy goods';
	( $code, $amount, $transaction, $agent_name, $date, $time, $balance ) =
	  ( $1, $2, $3, $4, $5, $6, $7 );
}
elsif ( $input =~
/(.*)\s+Confirmed\.?\s+on\s+([\/\d]+)\s+at\s+([\d:]+\s+[AP]M)[^\d]+([\.,\d]+)\s+(withdrawn)\s+from\s+([\d]+)\s+-\s+AGENT\s+ATM.*balance\s+is[^\d]+([\.,\d]+)/msi
  )
{
	$type = "Atm Withdraw";
	( $code, $date, $time,, $amount, $transaction, $agent_number, $balance ) =
	  ( $1, $2, $3, $4, $5, $6, $7 );
}

print
"$type,$code,$date,$time,$transaction,$amount,$agent_number,$agent_name,$balance\n";
