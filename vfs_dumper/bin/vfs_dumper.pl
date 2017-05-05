#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use 5.010;
use FindBin;
use lib "$FindBin::Bin/../lib/";
use VFS;
use JSON;

our $VERSION = 1.0;

binmode STDOUT, ":utf8";

unless (@ARGV == 1) {
	warn "$0 <file>\n";
}

my $buf;
{
	local $/ = undef;
	$buf = <>;
}

print JSON::to_json(VFS::parse($buf));
