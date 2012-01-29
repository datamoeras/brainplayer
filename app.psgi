#!/usr/bin/perl

use strict;
use warnings;

use Plack::Builder;
use CGI::PSGI;
use Data::Dumper;
use lib '.';
use genbrain;
use JSON;
use Encode qw/encode decode/;
use HTML::Entities qw/encode_entities/;

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
my $page = sub {
	my $json = encode('latin1', JSON->new->encode(encode_entities(genbrain::readall())));
return qq{
<!DOCTYPE html>
<html>
	<head>
		<title>brain prayer</title>
		<base href="http://www.jezra.net"> 
		<style type="text/css">
		#content
		{
			clear:both;
			width:60%;
		}
		.player_control
		{
			float:left;
			margin-right:5px;
			
		}
		#player
		{
			height:60px;
		}
		#volume_control
		{
			width:10px;
			height:50px;
			border: 2px solid #0a0;
			display:none;
			position:relative;
		}
		#volume_background
		{
			width:10px;
			height:50px;
			background-color:#ddd;
		}
		#volume_bar
		{
			width:10px;
			height:0px;
			background-color:#aca;
			position:absolute;	
		}
		#duration
		{
			width:400px;
			height:15px;
			border: 2px solid #50b;
		}
		#duration_background
		{
			width:400px;
			height:15px;
			background-color:#ddd;

		}
		#duration_bar
		{
			width:0px;
			height:15px;
			background-color:#bbd;

		}
    #main{

      float:right;
      width:80%;
    }
    #skyscraper {
      float:left;
      border:1px solid black;
      padding:5px;
    }
		</style>
		<script type="text/javascript">
		var db = $json;
		var ctl = [];
		function focus_track(i) {
			var div = document.getElementById("track" + i);
			var msg = document.getElementById("cttl");
			var aplayer = document.getElementById("aplayer");
			var tracklist = document.getElementById("tracklist");
			var data = db[i];
			if (data == undefined) return;
			if (aplayer == undefined) return;
			if (msg != undefined) 
				msg.innerHTML = "<center>track " + i + " " + data["title"] + "<br />" + data["src"] + "</center>";
			aplayer.setAttribute("src", data["src"]);
			if (tracklist == undefined) return;
			tracklist.innerHTML = "hier de tracklist dan" + data["list"];
			draw_tracklist(tracklist, i, data["list"]);
			playClicked();
		}
		function seekto(s) {
			document.getElementById("aplayer").currentTime=s; 
		}
		function draw_tracklist(div, i, list) {
			div.innerHTML = "";
			ctl = [];
			for (y in list) {
				var t = list[y];
				var tm = t[0];
				var data = t[1];
				if (data == undefined) continue;
				var ij = parseInt(y) + 1;
				div.innerHTML += '<div froms="' + data["from"] + '" id="tt' + ij + '"><span onclick="seekto(' + data["from"] + ')">[&gt;]</span>' + tm[0] + ":" + tm[1] + '&nbsp;-&nbsp;' + data["title"] + '</div>';
				ctl.push([data["from"], y]);
			}
			
		}
		function show_db_listing() {
			var div = document.getElementById("playlist");
			div.innerHTML = "";
			var i = 0;
			for (track in db) {
				var t = db[track];
				div.innerHTML += '<div id="track' + track + '"><a href="#" onclick="focus_track(' + track + ');return false;">' + t["title"] + '</a></div>';
				i++;
			}
		}
		</script>
		<script type="text/javascript">
		var audio_duration;
		var audio_player; 
		var volume_button; 
		var volume_control;
		function pageLoaded()
		{
			show_db_listing();
			audio_player = document.getElementById("aplayer");
			volume_button = document.getElementById('volume_button');
			volume_control = document.getElementById('volume_control');
			//get the duration
			audio_duration = audio_player.duration;
			//set the volume
			set_volume(0.7);
			focus_track(69);
		}
		function set_volume(new_volume)
		{
			audio_player.volume = new_volume;
			update_volume_bar();
			volume_button.value = "Volume: "+parseInt(new_volume*100);
			
		}
		function update_volume_bar()
		{

			new_top = volume_button.offsetHeight  - volume_control.offsetHeight;
			volume_control.style.top = new_top+"px";
			volume = audio_player.volume;
			//change the size of the volume  bar
			wrapper = document.getElementById("volume_background");
			wrapper_height = wrapper.offsetHeight;
			wrapper_top = wrapper.offsetTop;
			new_height= wrapper_height*volume;
			volume_bar = document.getElementById("volume_bar");
			volume_bar.style.height=new_height+"px";
			new_top =  wrapper_top + (  wrapper_height - new_height  );
			volume_bar.style.top=new_top+"px";
		}
		
		function highlight_current(i, curt) {
			document.getElementById("content").innerHTML = "";
			for (o in ctl) {
				var dt = ctl[o];
				var dv = document.getElementById("tt" + dt[1]);
				if (dv != undefined) dv.style.background = "white";
			}
			var dv = document.getElementById("tt" + i);
			if (dv != undefined) { 
				document.getElementById("content").innerHTML = dv.innerHTML;
				dv.style.background = "red";
			}
		}
		function now_playing(tm) {
			var last = 0;
			for (i in ctl) {
				var dt = ctl[i];
				if (dt[0] <= tm) {
					last = parseInt(dt[1]) + 1;
				}
			}	
			return last;
		}
		function update()
		{
			//get the duration of the player
			dur = audio_player.duration;
			time = audio_player.currentTime;
			var cur = now_playing(time);
			var min = (time - ( time % 60 ) ) / 60;
			var sec = parseInt(time - (min*60));
			var ssec = sec;
			if (ssec < 10) { ssec = "0" + ssec; }
			document.getElementById("msg").innerHTML = min + ':' + ssec + "=&gt;#" + cur;
			highlight_current(cur, time);
			fraction = time/dur;
			percent = (fraction*100);
			wrapper = document.getElementById("duration_background");
			new_width = wrapper.offsetWidth*fraction;
			document.getElementById("duration_bar").style.width=new_width+"px";

		}
		function playClicked()
		{
			//get the state of the player
			element = document.getElementById("playButton");
			if (element == undefined) {
				alert("geen play knop?");
				return;
			}
			if(audio_player.paused)
			{
				audio_player.play();
				newdisplay = "| |";
			}else{
				audio_player.pause();
				newdisplay = ">";
			}
			element.value=newdisplay;
		}
		function trackEnded()
		{
			//reset the playControl to 'play'
			document.getElementById("playButton").value=">";
		}
		function volumeClicked(event)
		{
			control = document.getElementById('volume_control');
			
			if(control.style.display=="block")
			{
				control.style.display="None";
			}else{
				control.style.display="Block";
				update_volume_bar();
			}
		}
		
		function volumeChangeClicked(event)
		{
			//get the position of the event
			clientY = event.clientY;
			offset =  event.currentTarget.offsetTop + event.currentTarget.offsetHeight  - clientY;
			volume = offset/event.currentTarget.offsetHeight;
			set_volume(volume);
			update_volume_bar();
		}
		
		function durationClicked(event)
		{
			//get the position of the event
			clientX = event.clientX;
			left = event.currentTarget.offsetLeft;
			clickoffset = clientX - left;
			percent = clickoffset/event.currentTarget.offsetWidth;
			duration_seek = percent*audio_duration;
			document.getElementById("aplayer").currentTime=duration_seek; 
		}
		</script>
	</head>

		<body onLoad="pageLoaded();">
    <div id='main'>
		<div id='player' style="position:fixed;left: 200px;top: 0px;">
			<input id="playButton" class='player_control' type="button" onClick="playClicked(this);" value=">">
				<div id="duration" class='player_control' >
					<div id="duration_background"  onClick="durationClicked(event);">
						<div id="duration_bar" class="duration_bar"></div>
					</div>
				</div>
				<div id="volume_control" class='player_control' onClick="volumeChangeClicked(event);">
					<div id="volume_background"  >
						<div id="volume_bar"></div>
					</div>
				</div>
				<input type="button" class='player_control'  id='volume_button' onClick="volumeClicked();" value="Vol">
			<audio id='aplayer' src="" onTimeUpdate="update();" onEnded="trackEnded();" preload="auto" autobuffer="yes"></audio>
		</div>
		<div id="current" style="position: fixed; top: 90px;left: 400px;">
			<div id="msg" style="font-family: fixed;" class='output'></div>
			<br />
			<div id="cttl" style="font-family: fixed;height: 80px; width: 500px; color: yellow; background: black; font-decoration: italic"></div>
			<div id="content" style="font-family: fixed;height: 80px; width: 500px; color: yellow; background: black; font-decoration: italic"></div>
			<br />
			<div id="tracklist">
			</div>
		</div>
    </div>
		<div style="position: absolute; font-family: fixed;left: 0px;top: 90px;" id="playlist">
		</div>
</body>
</html>
};
};
my $hello = sub {
	my $env = shift;
	return [200, ["Content-Type", 'text/html'], [$page->()]],
};
#builder { 
#	enable "Static",
#		path => qr/^s/,
#		root => "/home/raoul/jp/s/";
	#mount qr(/) => $hello;
#};
builder {
    enable "Static", path => sub { s!^/mp3/!! }, root => '/data/music/thebrain/';
    $hello;
}
#builder {
#	mount "/cb" => \&cb,
#	mount "/s" => $static,
#	mount "/" => 
#};
