///////////////////////////////////////////////////////MONOME Arrays//////////////////////////////////////////////////////////////////////

(
//maybe make some sort of check to see if Monome is plugged in? If not, can it be simulated internally (a la modality)?
~monome = MonoM.new("/monome",0);
~monome.useDevice(0);
~monome.ledall(0);

~channels = {
	Dictionary[
		"io" -> (Array.fill2D(3,7,0)), // maybe the size of the innermost arrays changes when I decide what kind of parameters we need...
		"transforms" -> ({Array.fill2D(10,7,0)} ! 3),
		"recorders" -> (Array.fill2D(3,2,0)),
		"bufTransforms" -> ({Array.fill2D(4,7,0)} ! 3)
	]
} ! 4;

~control = {
	Dictionary[
		"levels" -> (Array.fill(4,0)),
		"volume" -> (Array.fill(4,0)),
		"buffer" -> (Array.fill(3,0)),

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

~buffers = {Array.fill(3,{Buffer.alloc(s, s.sampleRate * 12, 1)})} ! 4;

/*~busses = {
Dictionary[
"ampBus" -> Bus.control(s,1),
"silenceBus" -> Bus.control(s,1),
"freqBus" -> Bus.control(s,1),
"hasFreqBus" -> Bus.control(s,1),
"onsetsBus" -> Bus.control(s,1),
"centroidBus" -> Bus.control(s,1),
"specFlatnessBus" -> Bus.control(s,1),
"densityBus" -> Bus.control(s,1),
"meanIOIBus" -> Bus.control(s,1),
"varianceIOIBus" -> Bus.control(s,1),
]
} ! 4;*/

//make an array of player pan arguments - closely source bonded processes should use those values in multiplayer/multichannel settings
//when adding multichannel, can change all Ndef symbol names to be concatenative
// if(~multichannel == true;{"ringMod" ++ "Multi"}) etc.

//groups
~inGroup = Group(s,\addToHead);
~outGroup = Group(s,\addToTail);
~transformsGroup = Group(~outGroup,\addBefore);


"Arrays Loaded".postln;
)