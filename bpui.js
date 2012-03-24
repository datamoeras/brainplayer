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
