
~window = Buffer.sendCollection(s,Env.perc.discretize);

// maybe just use WhiteNoise as an input?

(
Ndef(\comber,{
	var bufnum = \bufnum.kr(~buf);
	var sig = PlayBuf.ar(1,~buf,BufRateScale.kr(~buf),loop:1);

	var decay = \trigRate.kr();
	var trig = Dust.kr(decay.linlin(0,1,1,4)) + \trig.tr;
	var pan = TRand.kr(-1.0,1.0,trig);
	var grainSize = \grainSize.kr().linlin(0,1,0.05,1);
	sig = GrainIn.ar(2,trig,grainSize,sig,pan,~window);

	sig = CombC.ar(sig,0.1,TRand.kr(0.002,0.01,trig),decay.linlin(0,1,1,10),0.5); // 20-200

	// sig.clip2(0.2);

}).play;
)

Ndef(\comber).set(\trigRate,0,\grainSize,1)
Ndef(\comber).set(\trig,1)

// Decimator goes here also - bit crusher don't need no input! :)

/**********************************************************************/


/**********************************************************************/


~buf = Buffer.readChannel(s,"/Users/mikemccormick/Desktop/GHOST samples/stereo/ciaccona.aiff",channels:[0])
var sig = PlayBuf.ar(1,~buf,BufRateScale.kr(~buf),loop:1);

// add compression?

[(
	name: "percShiftDelay",
	func: {
		var trig,freq,hasFreq;

		var freqDev = \freqDev.kr().linexp(0.0,1.0,0.5,4.0);
		var maxDev = \maxDev.kr().lincurve(0.0,1.0,0.0,3.0);

		var sig = In.ar(\inBus.kr,1);
		var mute = ToggleFF.kr(\trig.tr);
		sig = sig * (1 - mute) + LocalIn.ar(1);
		#freq, hasFreq = Pitch.kr(sig, ampThreshold: 0.05, median: 7);
		trig = 1-hasFreq;
		sig = sig*trig;
		sig = PitchShift.ar(sig,1.0,freqDev,maxDev,1.0);
		sig = LeakDC.ar(sig);
		LocalOut.ar(sig*(Select.kr(mute,[0.75,1])));
		sig = Pan2.ar(sig,TRand.kr(-1.0,1.0,trig).lag(maxDev),\amp.kr(1));
	},
	args: [\freqDev,\maxDev],
	vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
)]