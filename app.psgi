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
	my $data = genbrain::readall();
	my $json = encode('latin1', JSON->new->encode($data));
	my $cloud = encode('latin1', search_cloud($data));
	my $onload = qq{random_brain()};
	my $cgi = CGI::PSGI->new($env);
	my $l = $cgi->param('l');
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
	
return qq{
<!DOCTYPE html>
<html>
	<head>
		<link rel="shortcut icon" type="image/png" href="http://www.musiques-incongrues.net/forum/themes/vanilla/styles/scene/favicon.png"/>
		<title>brain prayer</title>
		<link rel="stylesheet" type="text/css" href="/git/jpe/bpui.css" >
		<script type="text/javascript">
		var db = $json;
		</script>
		<script type="text/javascript" src="/git/jpe/bpui.js" > </script>
		<script type="text/javascript">
		function pageLoaded()
		{
			show_db_listing();
			volume_button = document.getElementById('volume_button');
			audio_player = document.getElementById("aplayer");
			volume_control = document.getElementById('volume_control');
			set_volume(1.0);
			$onload;
		}
		</script>
		<base target="_blank">
	</head>
	<body onLoad="pageLoaded();">
	<div id='main' style="z-index: 19;height: 100%;">
		<h3 style="text-align: left; color:#f0f"><a href="http://github.com/datamoeras/brainplayer">GPL</a>&nbsp;<a href="http://www.musiques-incongrues.net/forum/discussions/" target="_blank">&#8734;&nbsp;MUSIQUES&nbsp;INCONGRUES</a></h3><br />
		<div id='player' style="position:fixed;left: 220px;width: 400px;top: 4px;">
				<div id="duration" class"player_control" >
					<div id="duration_background"  onClick="durationClicked(event);">
						<div id="duration_bar" class="duration_bar"></div>
					</div>
				</div>
				<input id="playButton" class="player_control" type="button" onClick="playClicked(this);" value="play" ></input>
				<input id="button_rand" class="player_control" type="button" onClick="random_brain();" value="rnd" ></input>
				<input id="button_prev" class="player_control" type="button" onClick="click_prev();" value="&laquo;" ></input>
				<input id="button_next" class="player_control" type="button" onClick="click_next();" value="&raquo;" ></input>
				<a style="background: #ccc" href="#" target="_blank" title="Right click" id="href_as">save</a>
				<span class="asy player_control"><a href="#" target="_blank" title="Youtube" id="href_ut">ut</a></span>
				<!--
				<div id="volume_control" class='player_control' onClick="volumeChangeClicked(event);" style="display:none">
					<div id="volume_background"  >
						<div id="volume_bar"></div>
					</div>
				</div>
				<input type="button" class='player_control'  id='volume_button' onClick="volumeClicked();" value="Vol">
				-->
			<audio id='aplayer' src="" onTimeUpdate="update();" onEnded="trackEnded();" preload="metadata" autobuffer="yes"></audio>
		</div>
		<div id="searchframe" style="z-index: 3;background: #fff; position:fixed;left: 200px;left: 450px;top: 4px;">
			<input type="checkbox" id="enable_radioclash" />radioclash<br />
			<input type="checkbox" id="searchmode" />searchmodeplaylist<br />
			<input id="searchfld" value="" onkeyup="if(event.keyCode==13){search_txt(this.value)};return false" onchange="search_txt(this.value)"/><br />
			<div id="searchres" width="300px; overflow:none">
			</div>
		</div>
		<div id="current" style="position: fixed; top: 40px;left: 220px; bottom: 0px;">
			<div id="msg" style="height: 1.2em;display: none;" class='output'></div>
			<br />
			<div id="cttl" style="height: 1.2em; width: 220px; color: black; font-decoration: italic; font-weight: 900; font-size: 14px;text-align:center;"></div>
			<div id="t_duration" class"'player_control" >
				<div id="t_duration_background"  onClick="t_durationClicked(event);">
					<div id="t_duration_bar" class="duration_bar"></div>
				</div>
			</div>
			<div id="content" style="height: 4.8em; width: 600px; color: black; font-decoration: italic;font-weight: 900; font-size: 14px;"></div>
			<br />
			<div id="tracklist" style="width: 450px; overflow: auto;">
			</div>
			<!--<div id="scloud" style="width: 450px; overflow: auto;z-index: 8;">$cloud</div>-->
			<iframe id="wiki" style="width: 100%; height: 60%;" frameborder="0" /></iframe>
		</div>
	</div>
	<div style="position: absolute; left: 0px;top: 0px;z-index: 1; width: 220px; overflow: none;" id="playlist"></div>
	<img style="position: fixed; z-index: 1; opacity: .7; bottom: 0px;right: 0px;" id="pochette" src="" onClick="this.src=''">
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-29478248-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</body>
</html>
};
};
builder {
	# enable "Static", path => sub { s!^/mp3/!! }, root => '/data/music/thebrain/';
	sub { [200, ["Content-Type", 'text/html'], [$page->(@_)]] }
}
