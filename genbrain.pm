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
	$input =~ s/&uuml;/u/gi;
	$input =~ s/&ccedil;/c/g;
	$input =~ s/&Ccedil;/C/g;
	$input =~ s/&(ograve|ouml|oacute);/o/gi;
	$input =~ s/&(agrave|auml);/a/gi;
	$input =~ s/&ouml;/o/gi;
	$input =~ s/&(ecirc|egrave|eacute);/e/gi;
	$input =~ s/&#146;/-/gi;
	$input =~ s/&#148;/-/gi;
	my $dom = Mojo::DOM->new($input);
	return $input =~ /metadataShortCut/ ? parse_page($dom) : parsebrain($i, $dom);
}
sub parse_page {
	my $dom = shift;
	my %data = ( list => [] );
	my $image = $dom->find('meta[property="og:image"]')->first->attrs('content');
	my $mp3 = $dom->find('meta[property="og:audio"]')->first->attrs('content');
	my @pd = split /\//, $mp3;
	my $nom = pop@pd;
	$nom =~ s/\.mp3$//g;
	$data{title} = $nom;
	$data{src} = 'http://doscii.nl/dm/thebrain/' . $nom . '.ogg';
	$data{img} = $image;
	# print STDERR "title=$nom\n";

	$dom->find('span.metadataShortCut')->each(sub {
		my $e = shift;
		my $text = $e->text;
		$text =~ s/^(\d{1,2}):(\d{1,2}) //;
		my $tm = [$1, $2];
		my $from = ( $tm->[0] * 60 ) + $tm->[1];
		my ($artist, $title) = split / ?- ?/, $text, 2;
		my ($tiet, $rest) = split / ?- ?/, $title, 2;
		# print STDERR "text=$text\n";
		my %extra;
		push @{ $data{ list } }, [ $tm, { artist => $artist, title => $tiet, from => $from, %extra }];
	});
	return \%data;
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
		# print STDERR "($i)[$t0] { $txt }\n" if $txt =~ /indic/i;
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
	my $pre = 'thebrain';
	if ($i =~ /\D/) { $pre = '' }
	my $data = { title => $i =~ /\D/ ? $i : "thebrain$i", src => 'http://doscii.nl/dm/thebrain/'.$pre . $i . '.ogg' };
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
	$s =~ s/^\D+//g;
	return $s;
}
sub readall {
	my $path = basedir();
	my $sf = $path . '/data.pd';
	my $VAR1;
	my $data = do $sf;
	# unless ($data) { return readall_raw(); }
	return $data;
}
sub readall_raw {
	my $path = basedir();
	my $bdr = "${path}brains";
	opendir(my $dh, $bdr);
	my @ls;
	for my $f (grep -f "$bdr/$_" => readdir($dh)) {
		next unless $f =~ /^(.*?\d+)\.html$/;
		my $fn = $1;
		push @ls, $fn;
	}
	no warnings;
	my @extra = ikz();
	return [ @extra, sort { $a->{title} cmp $b->{title} } grep { $_ && $_->{list} && @{$_->{list}} > 6 } map eval{readbrain($_)} => @ls ];
}

sub ikz {
my @ik = (
{ title => 'ibrahimkazoo3', img => 'http://a2.ec-images.myspacecdn.com/images02/130/fa44da7c324e481e91bf2d0345d282d5/l.jpg', src => 'http://doscii.nl/dm/thebrain/ibrahimkazoo3.ogg', list => 
[
[qq[00:00 Monica M. and the swing rioters - Going up the country
]],[qq[03:34 the George King organ sounds (J.jaenner) - Caramba
]],[qq[06:00 Circle versus square - BFG
]],[qq[13:25 Frank Zappa - Drafted again
]],[qq[16:27 Hassan K. - Surfin santoor
]],[qq[18:34 Felix Kubin - Hissi hissi
]],[qq[26:04 Frederik schikowski - Ich meine nein
]],[qq[26:55 Lady data - Cheri separartion biere
]],[qq[31:32 Logosamphia - (bonus track 'Les sonates du neopolka')
]],[qq[34:28 Holger Czukay - Good morning story
]],[qq[38:18 Micachu & the shapes - Sweetheart
]],[qq[39:06 The residents - What have my chickens done now
]],[qq[43:26 Radio Myanmar (Burma) - Commercial for "american vision"
]],[qq[44:04 Vladimir Bozar n ze sherif orkestar - Le grand rabbi (la revanche d'un juif japonaise)
]],[qq[46:04 Glafouk - Violet (Trou)
]],[qq[49:18 Leonard nimoy vs monty python - Music to consume spam by (ibrahim kazoo mix)
]],[qq[51:49 Logosamphia - Chip monk
]],[qq[55:36 Irrlicht project - Savague
]],[qq[58:17 ADSR - Bit nation (Interlude)
]],[qq[61:26 Candie hank - Do you need love
]],[qq[64:14 Anita tijoux - 1977
]],[qq[67:00 Anklepants aka Reecard farche - Speak your little facehead
]],[qq[71:56 Cheveu - Superhero
]],[qq[75:15 Monica M and the swing rioters - La montagne
]],[qq[78:04 Cachicamoconcaspa - Thriller
]],[qq[81:54 50 Hertz - Svlt din son till lydnad
]],[qq[86:56 Wong chi wa - unknown
]
]
],
},
{ title => 'ibrahimkazoo4', img => 'http://a4.ec-images.myspacecdn.com/images02/145/27ac70d0b0e341fa9504536fb30326d0/l.png', src => 'http://doscii.nl/dm/thebrain/ibrahimkazoo4.ogg', list => 
[
[qw[00:01 sadra...your being called
]],[qq[00:04 Logosamphia - Kazoo intro
]],[qq[00:29 Barbapapa dutch version
]],[qq[00:53 Gregaldur - Mayotte choupi
]],[qq[03:27 Unknown artist - unknown title
]],[qq[06:10 Mziuri - unknown title
]],[qq[08:14 Ronny Bhikharie - Ja re ja re panchi
]],[qq[11:33 Capacocha - That aint my revolution
]],[qq[15:34 Khristianity - Fresh tank engine of Bel-air
]],[qq[16:22 Passenger of shit - Stapletapewurmsonmypenis
]],[qq[19:43 FFF - War is in the dance
]],[qq[23:34 Unknown artist - Sat tee touy
]],[qq[25:50 Kans hasan baba - Pesare shoja
]],[qq[30:23 Milligram retreat - Neue stadt (live @ Disko Resistencia)
]],[qq[34:04 N.Sokolov - Safari
]],[qq[36:39 Harry Thuman - Sphinx
]],[qq[41:45 Visitors - V-I-S-I-T-O-R-S
]],[qq[46:10 Zuiikin English - How dare you say such a thing to me...
]],[qq[49:56 Positive Noise - Hypnosis
]],[qq[53:42 Logosamphia - Les mongole c'est geniale
]],[qq[58:55 Artificial Organs - This & that
]],[qq[62:42 Flash System - Sadhu
]],[qq[67:35 They must be russians - Dont try to cure yourself
]],[qq[70:23 Bottroper Hammerchor - Jup Putta
]],[qq[73:20 Bakterielle Infektion - Chem
]],[qq[76:06 Knifehandchop - Hooked on Ebonics
]],[qq[80:14 VOCODER - Radio
]],[qq[85:10 Les Snuls Frap Parade - Alexandrie Ah!
]],[qq[86:00 Holger Czukay - Lets get hot
]],[qq[90:52 Chantana - Changwah Disco
]],[qq[93:07 Dara Puspita - Mari Mari
]],[qq[96:22 Logic System - Plan
]],[qq[99:20 Mekanik kommando - Crow
]],[qq[103:08 Lunapark Ensemble - Flim (aphex twin cover)
]],[qq[105:55 Wha-ha-ha - Nojari
]
]
]
},
{ title => 'ibrahimkazoo5', src => 'http://doscii.nl/dm/thebrain/ibrahimkazoo5.ogg', img => 'http://a2.ec-images.myspacecdn.com/images02/146/3091f6e0b1f44879afdb85a3c6b239ef/l.png', list => 
[
[qq[00:00 Ibrahim Kazoo intro
]],[qq[00:27 Girls at our best - Warm girls
]],[qq[04:24 Cassandra Complex - Moscow Idaho
]],[qq[07:32 Boris Tihomirov - Electronic alarmclock
]],[qq[09:36 Astral Sounds - Spectra
]],[qq[12:09 Free the robots - Clocks and daggers
]],[qq[15:21 DAF - Ich und die wirklichkeit
]],[qq[19:08 Birth control - Tell me
]],[qq[22:51 Gershon Kingsley - Rebirth
]],[qq[25:31 Andi Arroganti - Alle leute fallen um
]],[qq[29:04 Co.fee - Asante
]],[qq[31:48 The Glaslamp killer - Turk Mex
]],[qq[34:30 Jean jacques-Perrey - Chicken on the rocks
]],[qq[36:34 Andi Arroganti - Benzin in Berlin
]],[qq[39:35 BISS - Robot with a rose
]],[qq[44:05 Graig Sibley - You see art, I see clay
]],[qq[47:49 Janko Nilovic - La geurre des bouffons
]],[qq[50:00 Keine ahnung - Plastik
]],[qq[54:24 Klapto - Mister Game
]],[qq[60:50 La Femme - Anti taxi
]],[qq[64:48 Igor Ivanov - Kto tebe skazal
]],[qq[66:10 Zodiac - Rock on ice
]],[qq[68:37 The gaslamp killer - Shattering inner journeys
]],[qq[74:41 Plexiglas - Tanz!
]],[qq[77:28 Mathematiques Modernes - Disco rough
]],[qq[81:55 Soviet electro-exotica band - Unknown title
]],[qq[83:15 La Femme - La femme resort
]],[qq[87:42 Mekanik Kommando - Stop and play
]],[qq[91:29 Nanacy Nova - The force
]],[qq[95:46 Modele mechanique - Dark of the moon
]],[qq[98:41 Nemb - The middle room
]],[qq[102:44 Oppenheimer Analysis - Martyr
]],[qq[107:39 The 11th Hour - Mr. Death
]],[qq[109:29 The Moog Cookbook - Buddy Holly
]],[qq[113:39 Polyphonic Size - Nagasaki mon amour
]],[qq[117:38 Unknown artist - unknown title
]],[qq[118:10 Unknown artist - Weird soviet psych-folk
]],[qq[118:51 Proxyon Laserdance - Shotgun Warriors (Fan cover)
]],[qq[123:04 The Moog Cookbook - Come out and play
]],[qq[127:49 Space - Running in the city
]],[qq[131:24 Rockets - Future game
]],[qq[135:53 Daily Fauli - Out of sync
]],[qq[138:41 Partrizia Pelligrino - Automaticamore
]],[qq[142:10 Transvolta - Disco Computer
]],[qq[145:15 The red army choir - From the virgin earth
]
]
]
},
);
for my $k (@ik) {
	for (@{ $k->{list} }) {
		next unless $_->[0] =~ s/^(\d+:\d+) //;
		my $t0 = $1;
		my $tt = $_->[0];
		$tt =~ s/\n//g;
		$tt =~ s/^(.*?)\s*-\s*//;
		my $at = $1;
		my $tm = parsetime($t0);
		my $from = ( $tm->[0] * 60 ) + $tm->[1];
		my $song = { from => $from, title => $tt, artist => $at };
		unshift @{$_}, $song;
		unshift @{$_}, $tm;
		pop@{$_};
	}
}
# die Dumper(@ik);
return @ik;
}
}
1;
