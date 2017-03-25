package Local::Source::Text;

use strict;
use warnings;

our $VERSION = '1.00';

our @ISA = qw(Local::Source);

use Local::Source;

sub new {
	my $class = $_[0];
	shift;	#пропускаем название параметра
	my $text = $_[1];
	my $delimeter = defined $_[2] ? $_[1] : "\n";

	my @array = split $delimeter, $text;
	bless \@array, $class; 
}

1;