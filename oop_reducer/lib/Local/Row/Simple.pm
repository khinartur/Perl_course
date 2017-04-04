package Local::Row::Simple;

use strict;
use warnings;

our $VERSION = '1.00';

our @ISA = qw(Local::Row);

use Local::Row;

sub new {
	my $class = shift;
	my $log_string = shift;

	my @pairs = split /,/, $log_string;
	foreach (@pairs) {
		return undef unless $_ =~ m/^([^:,]+):\s*(\d+)\s*$/;
	}

	my $self = $class->Local::Row::new($log_string);

	return $self;
}

sub get {
	my $self = shift;
	my ($name, $default) = (shift, shift);
	my @pairs = split /,/, $self->{str};

	foreach my $str_to_parse (@pairs) {
		my ($key, $value) = $str_to_parse =~ m/^([^:,]+):\s*(\d+)\s*$/;
		return $value if $name eq $key;
	}
	
	return $default;
}

1;