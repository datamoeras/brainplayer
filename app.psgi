#!/usr/bin/perl

use strict;
use warnings;

use Plack::Builder;
use List::Util qw/shuffle/;
use CGI::PSGI;
use Cwd qw/getcwd/;
use Data::Dumper;
BEGIN { my $path = getcwd() . '/'. $0; $path =~ s{/\./}{/}g; $path =~ s/app\.psgi$//; unshift @INC, $path; };
use genbrain;
use JSON;
use Encode qw/encode decode/;
use HTML::Entities qw/encode_entities/;
use Data::Dumper;

my $cb = sub {
	my $env = shift;
	return [200, ["Content-Type", 'text/plain'], [Dumper(CGI::PSGI->new($env)->param('code'))]],
};

=over json
var brain = [
	"thebrain108.mp3": [
		info: [],
		list: [
			"0": ["t0":"0", "t1":27000, title:"Generique le Brain",artits:"Frederick S."],
		],
	],
];

=cut
sub search_cloud {
	my $data = shift;
	my %group;
	my $i = 0;
	no warnings;
	for my $b (@{ $data }) {
		my $o = 0;
		for my $t (@{ $b->{list} }) {
			next unless ref($t->[1]);
			my $art = lc($t->[1]{artist});
			if ($art) {
				push @{ $group{$art} }, [$i, $o];
			}
			$o++;
		}
		$i++;
	}
	for my $art (keys %group) {
		delete $group{$art} if @{ $group{ $art } } < 4 && $art !~ /ogosam/i;
		delete $group{$art} if $group{ $art } && @{ $group{ $art } } > 20;
	}
	my $h = '';
	for my $art (shuffle keys %group) {
		my $c = scalar @{ $group{ $art } };
		if ($art =~ /ogosam/i) { $c *= 2 } elsif (rand() > .85) { $c *=2 } elsif (rand() > .92) { $c *=3; }
		if ($c  > 30) { $c = 30 }
		elsif ($c  > 20) { $c /= 2 }
		$art =~ s/['"]//g;
		$h .= qq|<a href="#" style="font-size: ${c}px;" onclick="search_txt('$art');return false;">$art</a>&nbsp;|;
	}
	return $h;
}

sub si {
	my $t = shift;
	my $data = shift;
	my $i = 0;
	no warnings;
	if ($t =~ /^\d+$/) {
		$t = "thebrain$t";
	}
	for (@{ $data }) {
		if ($t eq $_->{title}) {
			return $i;
		}
		$i++;
	}
}
my $page = sub {
	my $env = shift;
	my $onload = qq{random_brain()};
	my $cgi = CGI::PSGI->new($env);
	my $l = $cgi->param('l');
	if ($l || $env->{REQUEST_URI} =~ /\?/) {
		my $data = genbrain::readall();
		my $s = $cgi->param('s');
		my $extra = $s ? ", '$s'" : "";
		if ($l) {
			my $li = si($l, $data);
			if (defined $li) {
				$onload = qq{focus_track($li$extra)};
			} else {
				$onload = '';
			}
		} elsif ($env->{REQUEST_URI} =~ /\?([a-z]+\d+)$/) {
			my $li = si($1, $data);
			if (defined $li) {
				$onload = qq{focus_track($li$extra)};
			} else {
				$onload = '';
			}
		}
	}
	open(my $fh, '<', '/home/raoul/git/jpe/bp.html');
	local $/;
	my $h = <$fh>;
	my $time = time();
	$h =~ s{\$onload\b}{$onload};
	# $h =~ s{\$json\b}{$json};
	$h =~ s{\$time\b}{$time};
	return $h;
};
builder {
	# enable "Static", path => sub { s!^/mp3/!! }, root => '/data/music/thebrain/';
	sub { [200, ["Content-Type", 'text/html'], [$page->(@_)]] }
}
