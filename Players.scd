///////////////////////////////////////////////////////MONOME Players//////////////////////////////////////////////////////////////////////

(
~players = Dictionary[

	0 -> (
		inBus: [0],
		compThresh: 0.5,

		filtFreqHi: 2000,
		rsHi: 0.25,

		filtFreqLo: 80,
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1),
		outBus: Bus.audio(s,1), // consider: should mono input signals just get sent thru to the output synth and then everything Splayed? SplayAz for multichannel?

		hardwareOut: 0,
	),

	1 -> (
		inBus: [1],
		compThresh: 0.5,

		filtFreqHi: 2000,
		rsHi: 0.25,

		filtFreqLo: 80,
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1),
		outBus: Bus.audio(s,1),

		hardwareOut: 0,
	),

	2 -> (
		inBus: [2],
		compThresh: 0.5,

		filtFreqHi: 2000,
		rsHi: 0.25,

		filtFreqLo: 80,
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1),
		outBus: Bus.audio(s,1),

		hardwareOut: 0,
	),

	3 -> (
		inBus: [3],
		compThresh: 0.5,

		filtFreqHi: 2000,
		rsHi: 0.25,

		filtFreqLo: 80,
		rsLo: 0.25,

		pan: 0,
		sendBus: Bus.audio(s,1),
		outBus: Bus.audio(s,1),

		hardwareOut: 0,
	),
];

"Player Info Loaded".postln

)