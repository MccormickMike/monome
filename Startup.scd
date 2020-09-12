///////////////////////////////////////////////////////MONOME Startup//////////////////////////////////////////////////////////////////////

(
var server = Server.default;
Ndef.all.clear;
OSCdef.freeAll;
server.freeAll;

server.waitForBoot({

	"Players.scd".loadRelative;

	server.sync;

	PathName((PathName(thisProcess.nowExecutingPath).parentPath +/+ "Program Files/")).entries.do({
		arg entry, index;

		if(index < 4,{entry.fullPath.load}) // remove when the GUI works!
	});

	"Monome Ready".postln;
	//maybe make a function here that opens the first channel? In case I need to be ready after a reboot during a concert

});
)

// consider using something instead of s for the Server? Could be smart to use an environment variable perhaps?
// what do we do for multichannel outputs??? New synth file? Ndefs => elastic mode?

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// screensaver...could be cooler?!?
(
Tdef(\waves,{
	var value = {Array.fill(16,1.0.rand)} ! 16;
	var offset = 0;
	loop{

		16.do({
			arg i;

			16.do({
				arg j;
				var x = i + offset % 16;
				var y = j + offset % 16;

				~monome.levset(x,y,value[x][y].sin * 15);
				value[x][y] = value[x][y] + 0.008;
				offset = 16.rand;
				0.001.wait;
			});
		});
	};

}).play
);

Tdef(\waves).stop