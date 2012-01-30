#!/usr/bin/perl
use Mojo::DOM;
use 5.10.0;
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
	my $path = join('/', @pd);
	$path .= '/' if $path;
	return $path;
}
sub readbrain {
	my $i = shift;
	my $path = basedir();
	my $fn = $path . "brains/$i.html";
	open(my $fh, '<', $fn);
	my $input = join('', <$fh>);
	$input =~ s/&iuml;/i/gi;
	$input =~ s/&euml;/e/gi;
	$input =~ s/&auml;/a/gi;
	$input =~ s/&ouml;/o/gi;
	$input =~ s/&(egrave|eacute);/e/gi;
	$input =~ s/&#146;/-/gi;
	$input =~ s/&#148;/-/gi;
	my $dom = Mojo::DOM->new($input);
	return parsebrain($i, $dom);
}
sub parselist {
	my $i = shift;
	my $list = shift;
	my @data = ();
	$list =~ s/(&#39;|&quot;)//g;
	my $magic1 = chr(146);
	my $tre = qr![\s\t\n]*\d{2}\D[\s\n\t]*(?:'|"|&#146;|#&148;|&[a-z0-9]+;|$magic1)*?\s*!i;
	# while ($list =~ s/^(?:.*?)($tre$tre)(.*?(?:.\d{4})?.*?)($tre|$)/$3/m) {
	# while ($list =~ s/^(?:.|\n)*?($tre$tre)(.*?)($tre|$)/$3$4/m) { # generique:

	$list =~ s/([a-z]) *\n/$1 /gmi;
	while ($list =~ s/^(?:.|\n)*?($tre$tre)((?:.*)?(?:\d{4}|\/)*(?:\n|.)*?)($tre|$)?/$3/m) { # generique:

		my $t0 = $1;
		my $txt = $2;
		print STDERR "($i)[$t0] { $txt }\n" if $txt =~ /indic/i;
		if ($list =~ s/^(.*)($tre$tre)/$2/m) {
			$txt .= $1;
		} else {
			$txt .= $list;
		}
		$t0 =~ s/\s+/ /g;
		$t0 =~ s/^\s*//g;
		$t0 =~ s/\s*$//g;
		$txt =~ s/\n//g;
		$txt =~ s/^\s*-\s*//g;
		$txt =~ s/\s*$//g;
		$txt =~ s/\s+/ /g;
		# print STDERR "($i)[$t0] { $txt }\n" if $txt =~ /LIA/;
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
	my $orig = $txt;
	# print STDERR "txt=$txt\n" if $txt =~ /LIA/;
	$txt =~ s/<br ?\/?>//g;
	$txt =~ s/<\/?font[^>]*>//g;
	$txt =~ s/<\/ ?i>//g;
	$txt =~ s/^\s*-\s*//g;
	while ($txt =~ s/<a href="([^"]*?)">//) {
		$data{href} = $1;
		$txt =~ s{</ ?a ?>}{}g;
	}
	my @dat = split /\s*-\s*/, $txt;
	if (@dat) { $data{artist} = shift@dat }
	if (@dat) { $data{title} = shift@dat }
	if (@dat > 1) { $data{label} = shift@dat }
	if (@dat) { $data{year} = shift@dat }
	unless ($data{title} || $data{artist}) {
		# die "geen artist en title voor \n$orig\n$txt\n";
	}
	$data{$_} =~ s/^(\s|&nbsp;)*//g for keys %data;
	$data{$_} =~ s/(\s|&nbsp;)*$//g for keys %data;
	$data{$_} //= '' for qw/artist title label year/;
	$data{$_} =~ s/&amp;\s*$//gi for keys %data;
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
		$html =~ s/<\/strong\s*>\s*//;
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
