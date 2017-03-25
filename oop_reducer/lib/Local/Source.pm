package Local::Source;

use strict;
use warnings;

our $VERSION = '1.00';

sub new {}

sub next {
	my $self = shift;
	return (scalar @$self > 0) ? shift @$self : undef;
}

1;