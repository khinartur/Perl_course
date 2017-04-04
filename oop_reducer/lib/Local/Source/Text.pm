package Local::Source::Text;

use strict;
use warnings;

our $VERSION = '1.00';

our @ISA = qw(Local::Source);

use Local::Source;

sub new {
	my $class = shift;
	my %params = @_;
	my $text = $params{text};
	my $delimeter = defined $params{delimeter} ? $params{delimeter} : "\n";

	my @array = split $delimeter, $text;
	bless \@array, $class; 
}

1;