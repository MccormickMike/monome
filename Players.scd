///////////////////////////////////////////////////////MONOME Players//////////////////////////////////////////////////////////////////////

(
~players = Dictionary[

	0 -> (
		inBus: [0],
		compThresh: 0.5,

		filtFreqHi: 2000.linlin(20,20000,0.0,1.0),
		rsHi: 0.25,

		filtFreqLo: 80.linlin(20,20000,0.0,1.0),
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1), // I think this causes routing issues...must check!
		outBus: Bus.audio(s,1),

		hardwareOut: 0,
	),

	1 -> (
		inBus: [0],
		compThresh: 0.5,

		filtFreqHi: 2000.linlin(20,20000,0.0,1.0),
		rsHi: 0.25,

		filtFreqLo: 80.linlin(20,20000,0.0,1.0),
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1),
		outBus: Bus.audio(s,1),

		hardwareOut: 2,
	),

	2 -> (
		inBus: [0],
		compThresh: 0.5,

		filtFreqHi: 2000.linlin(20,20000,0.0,1.0),
		rsHi: 0.25,

		filtFreqLo: 80.linlin(20,20000,0.0,1.0),
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1),
		outBus: Bus.audio(s,1),

		hardwareOut: 4,
	),

	3 -> (
		inBus: [2],
		compThresh: 0.5,

		filtFreqHi: 2000.linlin(20,20000,0.0,1.0),
		rsHi: 0.25,

		filtFreqLo: 80.linlin(20,20000,0.0,1.0),
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1),
		outBus: Bus.audio(s,1),

		hardwareOut: 6,
	),
];

"Player Info Loaded".postln;
)