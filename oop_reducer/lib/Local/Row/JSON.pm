package Local::Row::JSON;

use strict;
use warnings;

our $VERSION = '1.00';

our @ISA = qw(Local::Row);

use Local::Row;

sub new {
	my $class = $_[0];
	my $log_string = $_[1];

	return undef unless $log_string =~ m/^\{"([^:"]+)":\s*(\d+)\s*\}$/;

	my $self = Local::Row->new($log_string);
	bless $self, $class;

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