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

my $count = 0;

my $ctrl_handler = sub {
	if (++$count == 1) {
		print STDERR 'Double Ctrl+C for exit';
		return;
	}
	$average = int ($length / $lines);
	print STDOUT "$length $lines $average";
	exit(0);
};


$SIG{INT} = sub {
	$ctrl_handler->();
};


while (<STDIN>) {
	print {$fh} $_;
	chomp $_;
	$length += scalar split //, $_;
	$lines++;
	$count = 0;
	$SIG{INT} = sub {
		$ctrl_handler->();
	};
}

$average = int ($length / $lines);
print STDOUT "$length $lines $average";

