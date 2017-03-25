package Local::Source::Array;

use strict;
use warnings;

our $VERSION = '1.00';

our @ISA = qw(Local::Source);

use Local::Source;

sub new {
	my $class = shift;
	shift;	#пропускаем название параметра
	my $array = shift;

	bless $array, $class;
}


1;