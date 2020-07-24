///////////////////////////////////////////////////////MONOME Startup//////////////////////////////////////////////////////////////////////

(
Ndef.all.clear;
OSCdef.freeAll;
s.freeAll;

s.waitForBoot({

	(PathName(thisProcess.nowExecutingPath).parentPath +/+ "Monome_ArraysNEW.scd").load;

	s.sync;

	(PathName(thisProcess.nowExecutingPath).parentPath +/+ "Monome_OSCDefsNEW.scd").load;

	s.sync;

	(PathName(thisProcess.nowExecutingPath).parentPath +/+ "Monome_SynthDefsNEW.scd").load;

	s.sync;

	(PathName(thisProcess.nowExecutingPath).parentPath +/+ "Monome_PlayersNEW.scd").load;

	s.sync;

	(PathName(thisProcess.nowExecutingPath).parentPath +/+ "Monome_FunctionsNEW.scd").load;

	s.sync;

	// (PathName(thisProcess.nowExecutingPath).parentPath +/+ "Monome_GUINEW.scd").load;

	"Monome Ready".postln;
	//maybe make a function here that opens the first channel? In case I need to be ready after a reboot during a concert

});
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//screensaver...

(
Tdef(\waves,{
	var count = Array.fill2D(16,16,{
		arg i,j;

		var rand = {0.75.rand}!4;

		case
		{i % 2 == 0 and: {j % 3 == 0}}{rand[0]}
		{i % 5 == 0 and: {j % 7 == 0}}{rand[1]}
		{i % 7 == 0 and: {j % 5 == 0}}{rand[2]}
		{i % 3 == 0 and: {j % 2 == 0}}{rand[3]}
		{1.0.rand}
	});
	var offset = 0;

	loop{

		16.do({
			arg i;

			16.do({
				arg j;

				~monome.levset(i +(offset %15),j-(offset %15),count[i][j].sin * 15);
				count[i][j] = count[i][j] + 0.1;
				offset = offset + (j/(i+1));
			});
		});

		0.05.wait;
	};

}).play
)

Tdef(\waves).stop