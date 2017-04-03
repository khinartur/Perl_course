#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Scalar::Util qw(openhandle);

my $file = '';
GetOptions('file=s' => \$file) or die 'Usage: perl stdin.pl --file <yourfile>';

die 'Usage: perl stdin.pl --file <yourfile>' unless $file;

print "Get ready\n";

open(my $fh, '>', $file);

my ($length, $lines, $average);

$SIG{INT} = \&first_ctrl_c;

while (<STDIN>) {
	print {$fh} $_;
	chomp $_;
	$length += scalar split //, $_;
	$lines++;
	$SIG{INT} = \&first_ctrl_c;
}

$average = int ($length / $lines);
print STDOUT "$length $lines $average";	

sub first_ctrl_c {
	print STDERR 'Double Ctrl+C for exit';
	$SIG{INT} = 'DEFAULT';
}