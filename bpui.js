		var ctl = [];
		var ci;
		var cti;
		var audio_duration;
		var track_duration;
		var audio_player; 
		var volume_button; 
		var volume_control;
		var pb_1 = 'play';
		var pb_0 = 'pause';
		function focus_track(i, os) {
			if (os == undefined) os = 0;
			var div = document.getElementById("track" + i);
			var msg = document.getElementById("cttl");
			var aplayer = document.getElementById("aplayer");
			var tracklist = document.getElementById("tracklist");
			var data = db[i];
			if (data == undefined) return;
			if (aplayer == undefined) return;
			if (msg != undefined) {
				var tit = data["title"];
				if (tit == undefined) tit = '';
				if (tit.match(/thisisrad/)) tit = "<nobr>" + tit + "<nobr>"
				msg.innerHTML = tit;
			}
			var src = data["src"];
			if (src == undefined) src = '';
			if (navigator.userAgent.indexOf("Firefox")==-1 || ( /Safari/.test(navigator.userAgent))) {
				src = src.replace(new RegExp('ogg$', 'i'), 'mp3');
			}
			// if (src.match(/thebrain\d+.mp3/)) src = src.replace('http://doscii.nl/dm/thebrain/','http://thebrainradio.com/mp3/');
			// if (src.match(/thisisradioclash.*mp3\$/)) src = src.replace('http://doscii.nl/dm/thebrain/','http://www.thisisradioclash.org/mp3/');

			aplayer.setAttribute("src", src);
			document.getElementById("href_as").setAttribute("href", src);
			if (tracklist == undefined) return;
			tracklist.innerHTML = "hier de tracklist dan" + data["list"];
			draw_tracklist(tracklist, i, data["list"]);
			playClicked();
			audio_duration = document.getElementById("aplayer").duration;
			ci = i;
			if (os > 0)
				window.setTimeout(function(){ seekto(os); }, 200);

			document.getElementById("pochette").src = "data:image/gif;base64,R0lGODlhHwA0ALMAAP//////AP8A//8AAAD//wD/AAAA/wAAAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAgALAAAAAAfADQAAAT/EMkpj704081r+WBYHF1JHSCKfqR5Zlaawm23huqoi3V5yyzRyDX5BY1DYlGI7CkRSJ6SdsuxaDYmcIczNXXWrusblE61zaeHx1RDA/DAIA6fx50+u3xf58vxGwd9enOEfIAVdHp9inSAB4aRcYWTToJ7koOTh0WNnpufASSQm5mYpZWClJqsp5oWjHSyi7KMsKt1pgOLlBaGcru4hcGxA7CNwbS5u35wvqDAy8zRxbfNs9O1p8e0vNnXdtaZyXbCe8+t5rrH0NratOiu8uqp8u7325fhVPz6zqqH+sF4RcoWhjIZql0CdUHICG6y4q0SmE5cu3uSIIYCN+vfPD/0Kl69SQeypJ4aC7t1/GTpo65zNlCRPOnlokpnRAC+nIMokEx5PTkIxFAiAgA7";
			if (data["img"] != '')
				document.getElementById("pochette").src = data["img"];
		}
		function seekto(s) {
			var pl = document.getElementById("aplayer");
			if (pl == null) return;
			try {
				pl.currentTime=s; 
			} catch (e) {
				window.setTimeout(function(){ seekto(s); }, 300);
			};
		}
		function draw_tracklist(div, i, list) {
			div.innerHTML = "";
			ctl = [];
			for (y in list) {
				var t = list[y];
				var tm = t[0];
				var data = t[1];
				if (data == undefined) continue;
				var ij = parseInt(y) - 1;
				var ei = parseInt(y) + 1;
				div.innerHTML += '<div froms="' + data["from"] + '" id="tt' + ij + '" style="cursor:pointer;cursor:hand"><nobr onclick="seekto(' + data["from"] + ')">' + ei + '&nbsp;' + tm[0] + ":" + tm[1] + '&nbsp;-&nbsp;' + data["artist"] + '&nbsp;-&nbsp;' + data["title"] + '</nobr></div>';
				ctl.push([data["from"], y]);
				/*
				div.innerHTML += '<div style="" froms="' + data["from"] + '" id="tt' + ij + '" onclick="seekto(' + data["from"] + ')">';
				div.innerHTML +=     '' + ei + '&nbsp;' + tm[0] + ":" + tm[1] + '&nbsp;';
				div.innerHTML +=     '' + data["artist"] + '&nbsp;';
				div.innerHTML +=     '' + data["title"] + '';
				div.innerHTML += '</div>';
				*/
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
		function random_brain() {
			var brain_offset = 6;
			focus_track(Math.floor(Math.random()*( enable_radioclash ? ( db.length - brain_offset) : 33)) + ( enable_radioclash ? 0 : 6 ));
		}
		function set_volume(new_volume)
		{
			audio_player.volume = new_volume;
			update_volume_bar();
			if (volume_button) 
				volume_button.value = "Volume: "+parseInt(new_volume*100);
			var control = document.getElementById('volume_control');
			if (control) 
				control.style.display='none';
			if (volume_button) 
				but.style.display='inline';
			
		}
		function update_volume_bar()
		{

			if (volume_button) {
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
		}
		
		function highlight_current(i, curt) {
			document.getElementById("content").innerHTML = "";
			var dv = document.getElementById("tt" + ctl.length);
			if (dv != undefined) {
				dv.style.background = "white";
				dv.style.fontWeight = 100;
			}
			for (o in ctl) {
				var dt = ctl[o];
				var dv = document.getElementById("tt" + (parseInt(dt[1])-1));
				if (dv != undefined) {
					dv.style.background = "white";
					dv.style.color = "black";
					dv.style.fontWeight = 100;
				}
			}
			var data = db[ci];
			if (data == undefined) return;
			var track = data["list"][i+1];
			if (track == undefined) return;
			var tdata = track[1];
			var dv = document.getElementById("tt" + i);
			if (dv != undefined && tdata != undefined) { 
				var bt = '';
				var lnk = '';
				if (tdata["href"] != '' && tdata["href"] != undefined) {
					var hr = tdata["href"];
					if (hr.length > 42) { hr = hr.substring(0, 42); }
					lnk = '<br /><a href="' + tdata["href"] + '">' + hr + '</a>';
				}
				var art = tdata["artist"];
				art = art.replace("'", 'g');
				art = art.replace('"', 'g');
				document.getElementById("href_ut").innerHTML = '<a style="background:#ccc;" href="http://www.youtube.com/results?search_query=' + tdata["artist"] + '"> ut </a>';
				document.getElementById("content").innerHTML = bt +
					'<input id="button_love" class="player_control" type="button" onClick="search_txt('+ "'" + art + "'" + ')");" style="" value="+" ></input>' +
					tdata["artist"]+"<br/>"+
					'<input id="button_love" class="player_control" type="button" onClick="click_love();" style="" value="&hearts;" ></input>'+ 
					tdata["title"];
				if (tdata["year"] == undefined) tdata["year"] = '';
				if (tdata["label"] != undefined) document.getElementById("content").innerHTML += '<br /><span style="font-size:12px;">' + tdata["label"]+" "+tdata["year"] + lnk + "</span>";
				dv.style.background = "yellow";
				dv.style.color = "#f0f";
				dv.style.fontWeight = 900;
				update_wiki(art, tdata["title"]);
			}
		}
		var lastwiki;
		function wikiname(str) {
			str = str.replace(/ /g, '_');
			str = str.replace(/&(amp;)?/g, '%26');
			str = str.toLowerCase();
			str = str.replace(/^(.)/g, function($1){return $1.toUpperCase()});
			str = str.replace(/(\s[a-z])/g, function($1){return $1.toUpperCase()});
			return str;
		}
		function update_wiki(artist, title) {
			var art = wikiname(artist);
			var wikisrc = 'http://en.wikipedia.org/wiki/Special:Search/' + art;
			if (lastwiki != wikisrc) {
				document.getElementById("wiki").src = wikisrc;
				lastwiki = wikisrc;
			}
		}
		function toffset_current(tm) {
			var off = 0;
			for (i in ctl) {
				var dt = ctl[i];
				if (dt[0] <= tm) {
					off = tm - dt[0];
				}
			}	
			return off;
		}
		function now_playing(tm) {
			var last = 0;
			for (i in ctl) {
				var dt = ctl[i];
				if (dt[0] <= tm) {
					last = parseInt(dt[1]) - 1;
				}
			}	
			return last;
		}
		function ctrack_off(i) {
			if (c < 1) return 0;
			var c = ctl[i+1];
			var cf = c[0];
			return cf;
		}
		function ctrack_dur(i) {
			if (i < 1) return 0;
			var c = ctl[i];
			var n = ctl[i+1];
			if (n == undefined) return 0;
			var cf = c[0];
			var nf = n[0];
			return nf - cf;
		}
		var ati = 0;
		function update() {
			dur = audio_player.duration;
			time = audio_player.currentTime;
			var cur = now_playing(time);
			if (cti != cur && cti != ati) { einde_track(); }
			cti = cur;
			track_duration = ctrack_dur(cur+1);
			var min = (time - ( time % 60 ) ) / 60;
			var sec = parseInt(time - (min*60));
			var ssec = sec;
			if (ssec < 10) { ssec = "0" + ssec; }
			document.getElementById("msg").innerHTML = min + ':' + ssec + "=&gt;#" + (cur+2);
			highlight_current(cur, time);
			var toff = toffset_current(time);
			var tmin = (toff - ( toff % 60 ) ) / 60;
			var tsec = parseInt(toff - (tmin*60));
			var tssec = tsec;
			if (tssec < 10) { tssec = "0" + tssec; }
			document.getElementById("msg").innerHTML += " " + tmin + ":" + tssec;
			tdur = track_duration;
			var fraction = time/dur;
			var tfraction = toff/tdur;
			var wrapper = document.getElementById("duration_background");
			var twrapper = document.getElementById("t_duration_background");
			var new_width = wrapper.offsetWidth*fraction;
			var tnew_width = twrapper.offsetWidth*tfraction;
			document.getElementById("duration_bar").style.width=new_width+"px";
			document.getElementById("t_duration_bar").style.width=tnew_width+"px";

		}
		var searchres = [];
		var searchplayi = 0;
		function einde_track() {
			if (! searchmode_enabled()) return;
			if (searchres == null || searchres.length == 0) return;
			if ((new Date).getTime() < ati + 10000) return;
			// alert("ati=" + ati + ", nu=" + (new Date).getTime());
			searchplayi++;
			ati = (new Date).getTime();
			if (searchres[searchplayi] == null) searchplayi=0;
			focus_track(searchres[searchplayi][0], searchres[searchplayi][1]);
		}
		function playClicked() {
			element = document.getElementById("playButton");
			if (element == undefined) {
				return;
			}
			if(audio_player.paused || element.value == pb_1) {
				try { audio_player.play(); } catch (e) { };
				newdisplay = pb_0;
			}else{
				try { audio_player.pause(); } catch (e) { };
				newdisplay = pb_1;
			}
			element.value=newdisplay;
		}
		function trackEnded()
		{
			document.getElementById("playButton").value=pb_1;
			var nxt = parseInt(ci)+1;
			if (db[nxt] == undefined) nxt = 0;
			// alert("eind van " + ci + ", skip naar " + nxt);
			focus_track(nxt);
		}
		function volumeClicked(event)
		{
			var control = document.getElementById('volume_control');
			var but = document.getElementById('volume_button');
			if (control == undefined) return;
			
			if(control.style.display!="none")
			{
				control.style.display="None";
				but.style.display='';
			}else{
				control.style.display="Block";
				but.style.display='none';
				update_volume_bar();
			}
		}
		
		function volumeChangeClicked(event)
		{
			var but = document.getElementById('volume_button');
			if (but == undefined) return;
			offset =  event.currentTarget.offsetHeight - event.clientY;
			// alert("clientY=" + clientY + ",offsetTop=" + event.currentTarget.offsetTop + " => " + offset);
			volume = offset/event.currentTarget.offsetHeight;
			// alert("vol=" + volume);
			set_volume(volume);
			update_volume_bar();
			// volumeClicked();
		}
		
		function t_durationClicked(event)
		{
			//get the position of the event
			clientX = event.clientX;
			left = event.currentTarget.offsetLeft + 220;
			clickoffset = clientX - left;
			percent = clickoffset/event.currentTarget.offsetWidth;
			// alert("track_duration=" + track_duration);
			var coff = ctrack_off(cti);
			duration_seek = percent*track_duration;
			var tot = coff + duration_seek;
			// alert(" seek to " + coff + " + ( " + percent + " * " + track_duration + " ) => " + tot);
			if (tot > 0 && tot < dur) {
				document.getElementById("aplayer").currentTime=tot;
			}
		}
		function durationClicked(event)
		{
			//get the position of the event
			clientX = event.clientX;
			left = event.currentTarget.offsetLeft + 220;
			clickoffset = clientX - left;
			// alert("clientX=" + clientX + " - offsetLeft=" + left + " => " + clickoffset);
			percent = clickoffset/event.currentTarget.offsetWidth;
			dur = audio_player.duration;
			duration_seek = percent*dur;
			// alert("percent=" + percent + " * dur=" + dur + " => " + duration_seek);
			if (duration_seek > 0 && duration_seek < dur) {
				audio_player.currentTime=duration_seek; 
			}
		}
		function enable_radioclash() {
			var el = document.getElementById("enable_radioclash");
			return el.checked;
		}
		function search_db(txt) {
			var res = [];
			var re = new RegExp(txt, 'i');
			var cnt = 0;
			var clash = enable_radioclash();
			// alert(clash);
			for (dbi in db) {
				var brain = db[dbi];
				for (tri in brain["list"]) {
					var song = brain["list"][tri];
					if (song != undefined && song[1] != undefined) {
						var str = song[1]["artist"];
						str += " " + song[1]["title"];
						if (str.match(re) && (clash || brain["title"].match(/thebrain/))) {
							res.push([brain, song, dbi, tri]);
							cnt++;
							if (cnt > 50) return res;
						}
					}
				}
			}
			return res;
		}

		function search_txt(txt) {
			var div = document.getElementById("searchres");
			div.innerHTML = "<b>search(" + txt + ")</b><br/><br/>";
			var res = search_db(txt);
			searchplayi=0;
			ati = (new Date).getTime();
			searchres = [];
			for (i in res) {
				var ths = res[i];
				var brain = ths[0];
				var song = ths[1];
				var bri = ths[2];
				var tri = ths[3];
				var trn = parseInt(ths[3]) + 1;
				var offset = parseInt(song[1]["from"])+2;
				var ttl = song[1]["artist"] + " " + song[1]["title"];
				ttl = ttl.replace(txt, '<font style="font-weight:900;color:#f0f">' + txt + '</font>');
				div.innerHTML += '<span onclick="ati = (new Date).getTime();searchplayi=' + i + ';focus_track(' + bri + ', ' + (parseInt(song[1]["from"])+2) + ')">' + brain["title"] + "&nbsp;" + "#" + trn + "&nbsp;" + ttl + "</span><br/>";
				searchres[i]=[ths[2],offset];
			}
		}
		function searchmode_enabled() {
			var e = document.getElementById("searchmode");
			return e.checked;
		}
		function click_prev() {
			focus_track(ci-1);
		}
		function click_share() {
			alert("share it");
		}
		function click_love() {
			// alert("love it");
		}
		function click_next() {
			focus_track(ci+1);
		}
