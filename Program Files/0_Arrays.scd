///////////////////////////////////////////////////////MONOME Arrays//////////////////////////////////////////////////////////////////////

(
var server = Server.default;

//maybe make some sort of check to see if Monome is plugged in? If not, can it be simulated internally (a la modality)?
~monome = MonoM.new("/monome",0);
~monome.useDevice(0);
~monome.ledall(0);

~channels = {
	Dictionary[
		"io" -> (Array.fill2D(3,7,0)), // maybe the size of the innermost arrays changes when I decide what kind of parameters we need...
		"transforms" -> ({Array.fill2D(10,7,{0})} ! 3),
		"recorders" -> (Array.fill2D(3,2,{0})),
		"bufTransforms" -> ({Array.fill2D(4,7,{0})} ! 3)
	]
} ! 4;

~control = {
	Dictionary[
		"levels" -> (Array.fill(4,{0})),
		"volume" -> (Array.fill(4,{0})),
		"buffer" -> (Array.fill(3,{0})),

		"dustTrig" -> 1,
		"previousDustTime" -> 0,
		"impulseTrig" -> 1,
		"previousImpulseTime" -> 0,
		"cleared" -> 0,
		"fadeTime" -> 0.08,
		"squared" -> false,
		"sqrt" -> false,
		"keysHeld" -> (Array.fill(3,0)),
	]
} ! 4;

~buffers = {Array.fill(3,{Buffer.alloc(server, server.sampleRate * 12, 1)})} ! 4;

~busses = {
	Dictionary[
		"ampBus" -> Bus.control(server,1),
		"silenceBus" -> Bus.control(server,1),
		"freqBus" -> Bus.control(server,1),
		"hasFreqBus" -> Bus.control(server,1),
		"onsetsBus" -> Bus.control(server,1),
		"centroidBus" -> Bus.control(server,1),
		"specFlatnessBus" -> Bus.control(server,1),
		"densityBus" -> Bus.control(server,1),
		"meanIOIBus" -> Bus.control(server,1),
		"varianceIOIBus" -> Bus.control(server,1),
	]
} ! 4;

//groups
~inGroup = Group(s,\addToHead);
~outGroup = Group(s,\addToTail);
~transformsGroup = Group(~outGroup,\addBefore);

"Arrays Loaded".postln;
)