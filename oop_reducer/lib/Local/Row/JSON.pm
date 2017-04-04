package Local::Row::JSON;

use strict;
use warnings;

our $VERSION = '1.00';

our @ISA = qw(Local::Row);

use Local::Row;

sub new {
	my $class = shift;
	my $log_string = shift;

	return undef unless $log_string =~ m/^\{"([^:"]+)":\s*(\d+)\s*\}$/;

	my $self = $class->Local::Row::new($log_string);

	return $self;
}

sub get {
	my $self = shift;
	my ($name, $default) = (shift, shift);

	my ($key, $value) = $self->{str} =~ m/^\{"([^:"]+)":\s*(\d+)\s*\}$/;
	
	return $value if $name eq $key;
	return $default;
}

1;