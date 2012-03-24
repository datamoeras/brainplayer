		(function(db){
		})(db);
		$(document).ready(function(){
			$("#main").animate({opacity: 1}, 4000, function(){});
		});
		var ctl = [];
		var db;
		var ci;
		var cti;
		var track_duration;
		var audio_player; 
		var pb_1 = 'play';
		var pb_0 = 'pause';
		function bp_loaded()
		{
			audio_player = document.getElementById("aplayer");
			show_db_listing();
		}
		function focus_track(i, os) {
			if (os == undefined) os = 0;
			var tracklist = $("#tracklist");
			var data = db[i];
			if (data == undefined || tracklist == undefined) return;
			$("#status_current_mix").html(data["title"]);
			$("#stat_radio_title").html(data["title"]);
			if (! $("#plst").is(":focus") && $("#plst").val() != 'random')
				$("#plst").val(i);
			$("title").html(data["title"] + '@doscii');
			var src = data["src"];
			if (src == undefined) src = '';
			if (navigator.userAgent.indexOf("Firefox")==-1 || ( /Safari/.test(navigator.userAgent))) {
				src = src.replace(new RegExp('ogg$', 'i'), 'mp3');
			}
			audio_player.setAttribute("src", src);
			$("#href_as").href = src.replace(/\.ogg$/, '.mp3');;
			tracklist.html("hier de tracklist dan" + data["list"]);
			draw_tracklist(tracklist, i, data["list"]);
			playClicked();
			ci = i;
			if (os > 0)
				window.setTimeout(function(){ seekto(os); }, 200);

			// document.getElementById("pochette").src = "data:image/gif;base64,R0lGODlhHwA0ALMAAP//////AP8A//8AAAD//wD/AAAA/wAAAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAgALAAAAAAfADQAAAT/EMkpj704081r+WBYHF1JHSCKfqR5Zlaawm23huqoi3V5yyzRyDX5BY1DYlGI7CkRSJ6SdsuxaDYmcIczNXXWrusblE61zaeHx1RDA/DAIA6fx50+u3xf58vxGwd9enOEfIAVdHp9inSAB4aRcYWTToJ7koOTh0WNnpufASSQm5mYpZWClJqsp5oWjHSyi7KMsKt1pgOLlBaGcru4hcGxA7CNwbS5u35wvqDAy8zRxbfNs9O1p8e0vNnXdtaZyXbCe8+t5rrH0NratOiu8uqp8u7325fhVPz6zqqH+sF4RcoWhjIZql0CdUHICG6y4q0SmE5cu3uSIIYCN+vfPD/0Kl69SQeypJ4aC7t1/GTpo65zNlCRPOnlokpnRAC+nIMokEx5PTkIxFAiAgA7";
			if (data["img"] != '') 
				$("#tracklist").css({'background-image': "url('" + data["img"] + "')"});
				// document.getElementById("pochette").src = data["img"];
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
			$(div).html('');
			ctl = [];
			for (y in list) {
				if (list[y][1] == null) continue;
				var t = list[y];
				var ij = parseInt(y) - 1;
				var ei = parseInt(y) + 1;
				$(div).append('<div class="track" froms="' + t[1]["from"] + '" id="tt' + ij + '" onclick="seekto(' + t[1]["from"] + ')"><span class="tracknum">' + ei + '</span><span><nobr>&nbsp;' + t[0][0] + ":" + t[0][1] + '&nbsp;-&nbsp;' + t[1]["artist"] + '&nbsp;-&nbsp;' + t[1]["title"] + '</nobr></div>');
				ctl.push([t[1]["from"], y]);
			}
		}
		function plst_change() {
			focus_track($('option:selected', $("#plst")).val());
		}
		function show_db_listing() {
			var sel = $("#plst").html('').change(plst_change).append('<option value="random"><i>random</i></option>');
			for (track in db) {
				sel.append('<option value="'+track+'">' + db[track]["title"] + '</option>');
			}
		}
		function Xshow_db_listing() {
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
		function highlight_current(i, curt) {
			$("#content").html('');
			$("#tt" + ctl.length).removeClass("track_current");
			for (o in ctl) $("#tt"+(parseInt(ctl[o][1])-1)).removeClass("track_current").addClass("track");
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
				if (art == null) art = '';
				art = art.replace(/[\'\"]/, '', 'g');
				$("#href_ut").href = 'http://www.youtube.com/results?search_query=' + art;
				// $("#content").html(bt + '<input id="button_love" class="player_control" type="button" onClick="search_txt('+ "'" + art + "'" + ')");" style="" value="+" ></input>' + tdata["artist"]+"<br/>"+ '<input id="button_love" class="player_control" type="button" onClick="click_love();" style="" value="&hearts;" ></input>'+ tdata["title"]);
				// if (tdata["year"] == undefined) tdata["year"] = '';
				// if (tdata["label"] != undefined) $("#content").append('<br /><span style="font-size:12px;">' + tdata["label"]+" "+tdata["year"] + lnk + "</span>");
				$("#tt"+i).removeClass("track").addClass("track_current");
				update_stat("track_artist", tdata["artist"]);
				update_stat("track_title", tdata["title"]);
				//update_wiki(art, tdata["title"]);
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
		var duration_width = 400;
		function update_stat(n, v) {
			$("#stat_" + n).val(v);
		}
		function update() {
			dur = audio_player.duration;
			time = audio_player.currentTime;
			$("#href_cur").href = "/player?l=" + $("#stat_radio_title").html() + "&s=" + time;
			var cur = now_playing(time);
			$("#stat_track_nr").html(cur+2);
			if (cti != cur && cti != ati) { einde_track(); }
			cti = cur;
			track_duration = ctrack_dur(cur+1);
			var min = (time - ( time % 60 ) ) / 60;
			var sec = parseInt(time - (min*60));
			var ssec = sec;
			if (ssec < 10) { ssec = "0" + ssec; }
			highlight_current(cur, time);
			var toff = toffset_current(time);
			var tmin = (toff - ( toff % 60 ) ) / 60;
			var tsec = parseInt(toff - (tmin*60));
			var tssec = tsec;
			if (tssec < 10) { tssec = "0" + tssec; }
			$("#stat_radio_ms").html(min + ":" + ssec);
			$("#stat_track_ms").html(tmin + ":" + tssec);
			$("#duration_bar").css({width:(duration_width*(time/dur)) + 'px'});
			$("#t_duration_bar").css({width:(duration_width*(toff/track_duration)) + 'px'});
		}
		var searchres = [];
		var searchplayi = 0;
		function einde_track() {
			if (! searchmode_enabled()) return;
			if (searchres == null || searchres.length == 0) return;
			if ((new Date).getTime() < ati + 10000) return;
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
		function t_durationClicked(event) {
			clientX = event.clientX;
			left = event.currentTarget.offsetLeft + 130;
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
		function durationClicked(event) {
			clientX = event.clientX;
			left = event.currentTarget.offsetLeft + 130;
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
			for (dbi in db) {
				var brain = db[dbi];
				for (tri in brain["list"]) {
					var song = brain["list"][tri];
					if (song != undefined && song[1] != undefined) {
						var str = song[1]["artist"];
						str += " " + song[1]["title"];
						if (str.match(re) && (enable_radioclash() || brain["title"].match(/thebrain/))) {
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
			div.innerHTML = "<b>search /" + txt + "/</b><br/><br/>";
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
			focus_track(parseInt(ci)+1);
		}

