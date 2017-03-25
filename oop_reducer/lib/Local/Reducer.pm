package Local::Reducer;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut


sub new {
	my $class = shift;
	my ($source, $row_class, $initial_value) = (shift, shift, shift);
	my $self = {};
	$self->{source} = $source;
	$self->{row_class} = $row_class;
	$self->{initial_value} = $initial_value;

	bless $self, $class;
	
	return $self;
}

sub reduce_n {}

sub reduce_all {}

sub reduced {
	return $_[0]->{initial_value}; 
}

1;


