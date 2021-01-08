///////////////////////////////////////////////////////MONOME Synths//////////////////////////////////////////////////////////////////////

(
SynthDef(\recorder,{
	var sig = In.ar(\inBus.kr,1);
	RecordBuf.ar(sig,\bufnum.kr,0,\recLevel.kr(1),\preLevel.kr(1),loop:0, doneAction: 2);

}).add;

~synths = Dictionary[

	"i/o synths" -> Dictionary[

		"inPlayer" -> {
			var filtFreqHi = \filtFreqHi.kr;
			var filtFreqLo = \filtFreqLo.kr;
			var mute = ToggleFF.kr(\trig.tr);

			var sig = SoundIn.ar(\inBus.kr);
			sig = BHiShelf.ar(sig,filtFreqHi.linlin(0.0,1.0,20,20000),\rsHi.kr,0);
			sig = BLowShelf.ar(sig,filtFreqLo.linlin(0.0,1.0,20,20000),\rsLo.kr,0);
			sig = Compander.ar(sig,sig,\compThresh.kr,1,0.5,0.01,0.01);
			Out.ar(\sendBus.kr,sig);
			sig = Pan2.ar(sig * mute,\pan.kr,\amp.kr);
		},

		"inPlayerPair" -> {
			var filtFreqHi = \filtFreqHi.kr;
			var filtFreqLo = \filtFreqLo.kr;
			var inBus = \inBus.kr;
			var mute = ToggleFF.kr(\trig.tr);

			var sig = Mix(SoundIn.ar([inBus,inBus+1]));
			sig = BHiShelf.ar(sig,filtFreqHi.linlin(0.0,1.0,20,20000),\rsHi.kr,0);
			sig = BLowShelf.ar(sig,filtFreqLo.linlin(0.0,1.0,20,20000),\rsLo.kr,0);
			sig = Compander.ar(sig,sig,\compThresh.kr,1,0.5,0.01,0.01);
			Out.ar(\sendBus.kr,sig);
			sig = Pan2.ar(sig * mute,\pan.kr,\amp.kr);      // consider rewriting this and using Balance2.ar instead...
		},

		"outPlayer" -> {
			var sig = In.ar(\inBus.kr,2);
			sig = Compander.ar(sig,sig,\compThresh.kr(0.5),1,0.5,0.01,0.01);
			sig = FreeVerb.ar(sig,\mix.kr(0.1),\room.kr(100),\damp.kr(0.6),\amp.kr(1));    // get this shit out of here and put it somewhere else!
			sig = BHiShelf.ar(sig,\filtFreqHi.kr(0.1).linlin(0.0,1.0,20,20000),\rsHi.kr(0.25),\dBHi.kr(-6));
		},

		"analyser" -> { |chan|   //what is this?? Besides me trying to be clever....

			var sig = In.ar(\inBus.kr,1);
			var trig = Impulse.kr(\trigFreq.kr(4));
			var chain = FFT(LocalBuf(\frames.kr(1024)),sig);
			var specs,busVars;

			var amp = Amplitude.kr(sig);
			var silence = DetectSilence.ar(sig + Impulse.ar(0),0.01);
			var onsets = Onsets.kr(chain,\thresh.kr(0.2), \rcomplex);
			var centroid = SpecCentroid.kr(chain);
			var specFlatness = SpecFlatness.kr(chain);

			var freq, hasFreq, density, meanIOI, varianceIOI;

			# freq, hasFreq = Pitch.kr(LPF.ar(sig,2000) , ampThreshold: 0.01, median: 7);
			# density, meanIOI, varianceIOI = OnsetStatistics.kr(onsets,1.0);  // should this be scaled related to trigFreq?

			//do I need meanIOI and varianceIOI??

			specs = [amp,silence,onsets,centroid.explin(20,20000,0.0,1.0),specFlatness,freq.explin(20,20000,0.0,1.0),hasFreq,density,meanIOI,varianceIOI];

			SendReply.kr(trig, '/analysis', specs);
			busVars = thisFunction.def.varNames[5..];

			specs.collect({ |spec, index|
				var busName;

				busName = busVars[index].asString ++ "Bus";

				Out.kr(~busses[chan.source.values[1]][busName],spec)

			});
		},
	],

	"transforms" -> (
		[(
			name: "ringer",
			func: {
				var freq,hasFreq;
				var sig = In.ar(\inBus.kr,1);
				var modFreq = \modFreq.kr().lincurve(0.0,1,0.1,15);
				var dev = \dev.kr().lincurve(0.0,1.0,0.001,2900,5);
				var mod = Select.kr(ToggleFF.kr(\trig.tr),[dev,LFNoise0.kr(modFreq).range(0.001,4000)]);

				#freq, hasFreq = Pitch.kr(sig, ampThreshold: 0.05, median: 7);
				sig = sig * (SinOsc.ar(freq * 2 * SinOsc.kr(mod).range(0.5,2)));
				sig = Pan2.ar(sig,LFNoise2.kr(0.1,0.5),\amp.kr(0.5));
			},
			args: [\dev, \modFreq],
			vals: [[0,0.6,0.9],[0,0.2,0.7]],
		)]

		++

		[(
			name: "fftFreeze",
			func: {
				var frames = \frames.kr(4096);

				var dustTrig = \dustTrig.kr().lincurve(0.0,1.0,0.0,3.0);
				var impulseTrig = \impulseTrig.kr().lincurve(0.0,1.0,0.0,3.0);

				var sig = In.ar(\inBus.kr,1);
				var chain = FFT(LocalBuf(frames), sig, 0.5, 0, 1, frames);
				var trig = Dust.kr(dustTrig) + Impulse.kr(impulseTrig) + \trig.tr;
				trig = Trig.kr(trig,TExpRand.kr(0.1,0.3,trig));
				chain = PV_Freeze(chain,trig);
				sig = IFFT(chain);
				sig = Pan2.ar(sig * trig,TRand.kr(-1.0,1.0,trig),\amp.kr(1));
			},
			args: [\dustTrig,\impulseTrig],
			vals: [[0.0,1.0,0.0],[0.0,0.0,1.0]],
		)]

		++

		[(
			name: "brokenRecord",
			func: {
				var sig1;

				var dustTrig = \dustTrig.kr().lincurve(0.0,1.0,0.0,3.0);
				var impulseTrig = \impulseTrig.kr().lincurve(0.0,1.0,0.0,3.0);

				var sig = In.ar(\inBus.kr,1);
				var trig = Dust.kr(dustTrig) + Impulse.kr(impulseTrig) + \trig.tr;
				var gate = EnvGen.ar(Env.sine(0.1),trig);
				var rand = TExpRand.kr(0.05,0.3,trig);
				sig = CombC.ar(sig*gate,0.6,rand,Select.kr(Trig1.kr(trig,rand-0.01),[inf,0]));
				sig1 = DelayN.ar(sig,0.6,rand*7/5);
				sig = Pan2.ar(sig,LFNoise2.kr(0.2)) + Pan2.ar(sig1,LFNoise2.kr(0.2));
				sig * \amp.kr(0.8);
			},
			args: [\dustTrig,\impulseTrig],
			vals: [[0.0,1.0,0.0],[0.0,0.0,1.0]],
		)]

		++

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

		++

		[(
			name: "shiftDelay",
			func: {
				var speed = \speed.kr().linexp(0.0,1.0,0.05,7);
				var delay = \delay.kr().linexp(0.0,1.0,0.3,1.5);

				var sig = In.ar(\inBus.kr,1);
				var mute = ToggleFF.kr(\trig.tr);
				var local = LocalIn.ar(2);
				sig = DelayC.ar((sig*(1-mute))+local,1.5,LFNoise1.ar(speed!2).range(0.2,delay));
				LocalOut.ar((sig.reverse)*Select.kr(mute,[0.75,1]));
				sig = LeakDC.ar(sig);
				sig = Splay.ar(sig,0.5,\amp.kr(1));
			},
			args: [\speed,\delay],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]

		++

		[nil]

		++

		[nil]

		++

		[nil]

		++

		[nil]

		++

		[nil]

		++

		(nil!10)

		++

		(nil!10)

	).reshape(3,10),

	"bufTransforms" -> (
		[(
			name: "tGrainz",
			func: {
				var bufnum = \bufnum.kr;
				var impulseTrig = \impulseTrig.kr;
				var noise = impulseTrig.lincurve(0.0,1.0,0.1,0.001,10);
				var rate = \rate.kr().linexp(0.0,1.0,0.5,2.0);

				var trig = Impulse.kr(impulseTrig.linexp(0.0,1.0,0.1,12.0)) + \trig.tr;
				var bufDur = BufDur.kr(bufnum);

				var pointer = Rand(0.0,1.0) + LFNoise1.kr(12,noise);

				TGrains.ar(2,trig,bufnum,BufRateScale.kr(bufnum) * rate,pointer * bufDur,1.0,Latch.kr(LFNoise2.kr(0.1),trig),\amp.kr(1));
			},
			args: [\rate,\impulseTrig],
			vals: [[0.4,0.4,0.4],[1.0,0.0,0.35]],
		)]

		++

		[(
			name: "bufGlitch",
			func: {
				var bufnum = \bufnum.kr;

				var freq = \slowTrig.kr().linexp(0.0,1.0,0.25,2.5);
				var freq2 = \fastTrig.kr().linexp(0.0,1.0,5,15);

				var trig = ToggleFF.kr(\trig.tr);
				var bufFr = BufFrames.kr(bufnum);
				var pointer = LFNoise1.ar(Select.kr(trig,[freq,freq2])).range(0,bufFr);

				var	sig = BufRd.ar(1,bufnum,pointer,1);
				sig = BHiShelf.ar(sig,3500,1,-6);
				sig = Pan2.ar(sig,pointer.linlin(0,bufFr,-1.0,1.0),\amp.kr(1))
			},
			args: [\slowTrig,\fastTrig],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]

		++

		[(
			name: "bufBells",
			func: {
				var bufnum = \bufnum.kr;
				var	trig = \trig.tr;
				var speed = \sweep.kr().linlin(0.0,1.0,2,10);
				var rate = \rate.kr().linexp(0.0,1.0,0.25,2.0);
				var sig = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum) * rate,loop:1);
				var ramp = Env.perc(0.001,speed,-1,2).kr(gate:trig);
				var pan = TRand.kr(-1.0,1.0,trig);

				var chain = FFT(LocalBuf(1024),sig);
				chain = PV_Freeze(chain,SetResetFF.kr(TDelay.kr(trig,0.1),trig));
				chain = PV_BrickWall(chain,ramp);
				sig = IFFT(chain);
				sig = Pan2.ar(sig,ramp * pan,\amp.kr(1));
			},
			args: [\sweep,\rate],
			vals: [[0,0.25,1],[1/3,2/3,1]],
		)]

		++

		[nil]
	),

];


"SynthDefs Loaded".postln;

)

