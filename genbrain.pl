#!/usr/bin/perl

use genbrain;

use Cwd qw/getcwd/;
use vars qw/$path/;
BEGIN { $path = getcwd() . '/'. $0; $path =~ s{/\./}{/}g; $path =~ s/\/[^\/]+$/\//; unshift @INC, $path; };
use strict;
use warnings;
use autodie qw/open/;
use JSON;
use Mojo::DOM;
use Data::Dumper;

my %opt;
if ($ARGV[0] && $ARGV[0] =~ /^-j$/) {
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
		#print Dumper($data);
		testoutput($data);
	}
}

sub testoutput {
	my $data = shift;
	open(my $fh, '>', $_) for <$path/tst/*txt>;
	for my $b (@{ $data }) {
		tstbrn($b);
	}
}

sub tstbrn {
	my $data = shift;
	my $title = $data->{title};
	open(my $fh, '>', "$path/tst/$title.txt");
	my $i = 0;
	no warnings;
	for my $track (@{ $data->{list}}) {
		my $tm = $track->[0];
		my $info = $track->[1];
		$i++;
		print $fh join("\t", $i, "$tm->[0]:$tm->[1]", "artist=$info->{artist}", "title=$info->{title}"), "\n";
	}
	close($fh);
}
