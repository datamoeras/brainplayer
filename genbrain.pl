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
if ($ARGV[0] && $ARGV[0] =~ /^-s$/) {
	shift;
	$opt{save}++;
}
if ($ARGV[0] && $ARGV[0] =~ /^-r$/) {
	shift;
	$opt{read}++;
}
if ($ARGV[0]) {
	my $b = genbrain::readbrain($ARGV[0]);
	tstbrn($b, 1);
} else {
	my $data = genbrain::readall();
	if ($opt{save}) {
		my $sf = $path . 'data.pd';
		open(my $fh, '>', $sf);
		print $fh Dumper($data);
		close($fh);
	} elsif ($opt{read}) {
		my $sf = $path . 'data.pd';
		my $VAR1;
		my $data = do $sf;
		print Dumper($data);
	} elsif ($opt{json}) {
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
	my $stdout = shift;
	my $title = $data->{title};
	my $fh;
	if ($stdout) {
		$fh = *STDOUT{IO};
	} else {
		open($fh, '>', "$path/tst/$title.txt");
	}
	my $i = 0;
	no warnings;
	my $last = 0;
	for my $track (@{ $data->{list}}) {
		my $tm = $track->[0];
		my $info = $track->[1];
		if (! $info->{from}) {
			warn "geen {from} voor $title/$i\n";
		} elsif ($info->{from} < $last) {
			warn "$title/$i gaat terug in de tijd: $last -> $info->{from}\n";
		} else {
			$last = $info->{from};
		}
		if (! $info->{artist} && !$info->{title}) {
			warn "geen {artist} en {title} voor $title/$i\n";
		}
		$i++;
		my $str = join("\t", $i, "$tm->[0]:$tm->[1]", qq|from=$info->{from}|, "artist=$info->{artist}", "title=$info->{title}", qq|href="$info->{href}"|, qq|label="$info->{label}"|). "\n";
		print $fh $str;
	}
	close($fh);
}
