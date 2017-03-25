package Local::Row;

use strict;
use warnings;

our $VERSION = '1.00';

sub new {
	my $class = $_[0];
	my $log_string = $_[1];
	my $self = {};
	$self->{str} = $log_string;
	bless $self, $class;
	
	return $self;
}

sub get {}

1;