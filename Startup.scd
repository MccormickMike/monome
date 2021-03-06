///////////////////////////////////////////////////////MONOME Startup//////////////////////////////////////////////////////////////////////

(
var server = Server.default;
Ndef.all.clear;
OSCdef.freeAll;
server.freeAll;

server.waitForBoot({

	"Players.scd".loadRelative;

	server.sync;

	PathName((PathName(thisProcess.nowExecutingPath).parentPath +/+ "Program Files/")).entries.do({ |entry, index|

		if(index < 4,{entry.fullPath.load}) // remove when the GUI works!
	});

	"Monome Ready".postln;
	//maybe make a function here that opens the first channel? In case I need to be ready after a reboot during a concert

});
)

// what do we do for multichannel outputs??? New synth file? Ndefs => elastic mode?

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// screensaver...could be cooler?!?
(
Tdef(\waves,{
	var value = {Array.fill(16,1.0.rand)} ! 16;
	var offset = 0;
	loop{

		16.do({ |i|
			var x = i + offset % 16;
			16.do({ |j|
				var y = j + offset % 16;

				~monome.levset(x,y,value[x][y].sin * 15);
				value[x][y] = value[x][y] *  4.rrand(12);
				offset = 1;
				0.0003.wait;
			});
		});
	};

}).play
);

Tdef(\waves).stop
~monome.ledall(0);
