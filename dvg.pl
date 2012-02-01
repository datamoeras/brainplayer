#!/usr/bin/perl
use Mojo::DOM;
use 5.10.0;

use strict;
use warnings;
use autodie "open";

open(my $fh, '/home/raoul/jp/brains/radioclash10.html');
my $html = join('', <$fh>);

sub parse_page {
	my $dom = shift;
	my %data = ( list => [] );
	my $title = $dom->find('span.nomEmission font')->first->text;
	$data{title} = $title;

	$dom->find('span.metadataShortCut')->each(sub {
		my $e = shift;
		my $text = $e->text;
		$text =~ s/^(\d{1,2}):(\d{1,2}) //;
		my $tm = [$1, $2];
		my $from = ( $tm->[0] * 60 ) + $tm->[1];
		my ($artist, $title) = split / ?- ?/, $text, 2;
		my %extra;
		push @{ $data{ list } }, [ $tm, { artist => $artist, title => $title, from => $from, %extra }];
	});
	return \%data;
}
my $dom = Mojo::DOM->new($html);
use Data::Dumper;
die Dumper(parse_page($dom));
