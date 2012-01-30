#!/usr/bin/perl
use Mojo::DOM;

{
package genbrain;

use strict;
use warnings;
use autodie "open";
use Mojo::DOM;

use Data::Dumper;

sub basedir {
	my $pdp = $INC{'genbrain.pm'};
	my @pd = split /\//, $pdp;
	pop@pd;
	my $path = join('/', @pd) . '/';
	return $path;
}
sub readbrain {
	my $i = shift;
	my $path = basedir();
	my $fn = $path . "brains/$i.html";
	open(my $fh, '<', $fn);
	my $dom = Mojo::DOM->new(join('', <$fh>));
	return parsebrain($i, $dom);
}
sub parselist {
	my $i = shift;
	my $list = shift;
	my @data = ();
	$list =~ s/&#39;//g;
	my $magic1 = chr(146);
	my $tre = qr![\s\t\n]*\d{2}\D[\s\n\t]*(?:'|"|&#146;|#&148;|$magic1)*?\s*!;
	# while ($list =~ s/^(?:.*?)($tre$tre)(.*?(?:.\d{4})?.*?)($tre|$)/$3/m) {
	# while ($list =~ s/^(?:.|\n)*?($tre$tre)(.*?)($tre|$)/$3$4/m) { # generique:

	while ($list =~ s/^(?:.|\n)*?($tre$tre)((?:.*)?(?:\d{4})?(?:\n|.)*?)($tre|$)?/$3/m) { # generique:

		my $t0 = $1;
		my $txt = $2;
		if ($list =~ s/^(.*)($tre$tre)/$2/m) {
			$txt .= $1;
		} else {
			$txt .= $list;
		}
		$t0 =~ s/\s+/ /g;
		$t0 =~ s/^\s*//g;
		$t0 =~ s/\s*$//g;
		$txt =~ s/\n//g;
		$txt =~ s/^\s*-\s*//;
		$txt =~ s/\s*$//;
		$txt =~ s/\s+/ /g;
		# print STDERR "($i)[$t0] { $txt }\n";
		my $song = parsesong($i, $txt);
		my $tm = parsetime($t0);
		my $from = ( $tm->[0] * 60 ) + $tm->[1];
		$song->{from} = $from;
		push @data, [$tm, $song];
	}
	return \@data if @data;
	die "snap niet list[$i]: $list\n";
}
sub parsetime {
	my $txt = shift;
	return [grep /\d{2}/ => split /\D/, $txt];
}
sub parsesong {
	my $i = shift;
	my $txt = shift;
	my %data = (
	);
	$txt =~ s/<br ?\/?>//g;
	$txt =~ s/<\/ ??i>//g;
	if ($txt =~ s/^(.*?)-//) {
		$data{artist} = $1;
		$data{artist} =~ s/<br ?\/?>//g;
	}
	if ($txt =~ s/^(.*?)-//) {
		$data{title} = $1;
		$data{title} =~ s/<br ?\/?>//g;
	}
	$data{rest} = $txt;
	return \%data;
}

sub parsebrain {
	my $i = shift;
	my $dom = shift;
	my $data = { title => "thebrain$i", src => 'http://twc.local/dm/thebrain/thebrain' . $i . '.ogg' };
	$dom->find('td')->each(sub {
		my $e = shift;
		my $html = "$e";
		$html =~ s/^.*?<font[^>]+>//m;
		$html =~ s/^.*?<td[^>]+>//m;
		$html =~ s/^.*?<strong[^>]+>//m;
		$html =~ s/<\/font\s*>.*?$//;
		# $html =~ s/&#39;/:/g;
		# $html =~ s/&#146;/'/g;
		# $html =~ s/&#148;/"/g;
		if ($html =~ m!<img[^>]*src="([^"]*/(?:gifs|archiveplayl)[^"]*)"!) {
			my $src = $1;
			$data->{img} = $src =~ /^http:/ ? $src : /^\// ? "http://thebrain.lautre.net$src" : "http://thebrain.lautre.net/playlists/$src";
			return;
		}
		return unless $html =~ /\n/;
		return unless $html =~ /\d{2}.*\d{2}/;
		$data->{list} = parselist($i, $html);
		# print "THEBRAIN$i ($data->{img})\n" . Dumper($data->{list})."\n\n\n";
	});
	return $data;
}
sub kgi {
	my $s = shift->{title};
	$s =~ s/^thebrain//;
	return $s;
}
sub readall {
	my $path = basedir();
	my $bdr = "${path}brains";
	opendir(my $dh, $bdr);
	my @ls;
	for my $f (grep -f "$bdr/$_" => readdir($dh)) {
		next unless $f =~ /^(\d+)\.html$/;
		push @ls, $1;
	}
	return [ sort { kgi($a) <=> kgi($b) } grep { $_ && $_->{list} && @{$_->{list}} > 6 } map eval{readbrain($_)} => @ls ];
}

}
1;
