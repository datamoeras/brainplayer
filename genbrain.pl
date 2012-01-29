#!/usr/bin/perl

use lib '/home/raoul/jp';
use genbrain;

use strict;
use warnings;
use JSON;
use Mojo::DOM;
use Data::Dumper;

my %opt;
if ($ARGV[0] =~ /^-j$/) {
	shift;
	$opt{json}++;
}
if ($ARGV[0]) {
	print Dumper(genbrain::readbrain($ARGV[0]));
} else {
	my $data = genbrain::readall();
	if ($opt{json}) {
		print JSON->new->encode($data);
	} else {
		print Dumper($data);
	}
}
