package myconst;

use strict;
use warnings;
use Scalar::Util 'looks_like_number';
use List::Util qw/pairs/;

=encoding utf8

=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS
package aaa;

use myconst math => {
        PI => 3.14,
        E => 2.7,
    },
    ZERO => 0,
    EMPTY_STRING => '';

package bbb;

use aaa qw/:math PI ZERO/;

print ZERO;             # 0
print PI;               # 3.14
=cut

sub import {
	shift @_;
	my @constants = @_;
	my $package = caller;

	{
		no strict 'refs';
		push @{"${package}::ISA"}, 'Exporter';
		%{"${package}".'::EXPORT_TAGS'} = (all => []);
	}

	unless ((scalar @constants) & 1) {
		foreach my $pair ( pairs @constants ) {
	   		my ( $name, $const ) = @$pair;

	   		unless (ref $const) {

	   			if (ref $const || !$const || !$name) {
					die "invalid args checked";
				}
				else {

					{
						no strict 'refs';
						*{"$package::$name"} = sub () { $const };
						push @{"${package}::EXPORT_OK"}, $name;
						push ${"${package}".'::EXPORT_TAGS'}{all}, $name;
					}	
				}	
			} 
			else {

				{
					no strict 'refs';
					${"${package}".'::EXPORT_TAGS'}{$name} = [];
				}

				while (my ($k, $v) = each %$const) {

					if (ref $v || !$v || !$k) {
						die "invalid args checked";
					}
					else {

						{
							no strict 'refs';
							*{"$package::$k"} = sub () { $v };
							push @{"${package}::EXPORT_OK"}, $k;
							push ${"${package}".'::EXPORT_TAGS'}{all}, $k;
							push ${"${package}".'::EXPORT_TAGS'}{$name}, $k;
						}
						
					}
				}
			}
		}
	}
	else {
		die "invalid args checked";
	}

}

1;