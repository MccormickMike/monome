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
			sig = Pan2.ar(sig * mute,\pan.kr,\amp.kr);
		},

		"outPlayer" -> {
			var sig = In.ar(\inBus.kr,2);
			var wet = HPF.ar(sig,450); //new
			sig = Compander.ar(sig,sig,\compThresh.kr(0.8),1,1/3,0.1,0.1); // map these to something?

			wet = FreeVerb.ar(wet,1,0.9,0.9);
			wet = LPF.ar(wet,2000);
			wet = HPF.ar(wet,450);
			wet = wet * \mix.kr(0.1);

			sig = (sig + wet) * \amp.kr(1);
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
			args: [\dev,\modFreq],
			vals: [[0,0.6,0.9],[0,0.2,0.7]],
		)]

		++

		[(
			name: "crusher",
			func: {
				var sRate = \sRate.kr().linlin(0,1,0.02,0.1);
				var bits = \bits.kr().linlin(0,1,0.05,0.2);
				var sig = In.ar(\inBus.kr,1);
				var cycle = Stepper.kr(\trig.tr,0,0,2,1,1);
				var bitsAmpScale = bits.linlin(0.05,0.2,0.3,1);

				sRate = Select.kr(cycle,[sRate,1,sRate]);
				bits = Select.kr(cycle,[1,bits,bits]);
				sig = Decimator.ar(sig,SampleRate.ir * sRate, 24 * bits);
				sig = Pan2.ar(sig,LFNoise2.kr(0.1,0.7),\amp.kr(1) * bitsAmpScale);
			},
			args: [\sRate,\bits],
			vals: [[1,0.5,0],[1,0.5,0]],
		)]

		++

		[(
			name: "grinder",
			func: {
				var sig = In.ar(\inBus.kr,1);
				var rand = Array.rand(16,40,600);
				var rate = \trigRate.kr().lincurve(0.0,1.0,0.5,300,7);
				var gain = \gain.kr(lag:1).linlin(0,1,2,20);
				var freq = Duty.kr(Dbrown(0.7,1.0,0.02,inf) * rate.reciprocal!2,\trig.tr,Dshuf(rand,inf));
				var noise = LFNoise2.kr(2).range(0.8,1.2);

				sig = Amplitude.kr(sig) > 0.2;                                        // maybe this needs to be tuned? could be higher possibly...
				freq = Select.kr(sig,[freq,Latch.kr(freq,sig) * noise]);
				sig = SinOsc.ar(freq,mul: gain);
				sig = RLPF.ar(sig,freq * 2,0.01);
				sig = Pan2.ar(sig.sum.tanh,0,\amp.kr(0.5) * 0.15);                   // probably need to scale this sucker down...
			},
			args: [\trigRate,\gain],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]

		++

		[(
			name: "freezer",
			func: {
				var dustTrig = \dustTrig.kr().lincurve(0.0,1.0,0.0,3.0);
				var impulseTrig = \impulseTrig.kr().lincurve(0.0,1.0,0.0,3.0);
				var sig = In.ar(\inBus.kr,1);
				var chain = FFT(LocalBuf(4096), sig);
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
				sig = CombC.ar(sig * gate,0.6,rand,Select.kr(Trig1.kr(trig,rand-0.01),[inf,0]));
				sig1 = DelayN.ar(sig,0.6,rand*7/5);
				sig = Pan2.ar(sig,LFNoise2.kr(0.2)) + Pan2.ar(sig1,LFNoise2.kr(0.2));
				sig * \amp.kr(0.8);
			},
			args: [\dustTrig,\impulseTrig],
			vals: [[0.0,1.0,0.0],[0.0,0.0,1.0]],
		)]

		++

		[(
			name: "fbSwell",
			func: {
				var amp;
				var sig = In.ar(\inBus.kr,1);
				var rate = \trigRate.kr().lincurve(0,1,0.5,6,3);
				var coef = \coef.kr().linlin(0,1,1.001,1.4,3);
				var trig = Impulse.kr(rate * LFNoise2.kr(0.3).range(0.8,1.1)) + \trig.tr;
				var env = Env.sine(\win.kr(0.2),).kr(gate:trig);
				var delay = TRand.kr(0.01,0.05,trig);

				sig = (sig * env) + LocalIn.ar(2);
				amp = Amplitude.kr(sig) > 0.65;                                    //gotta check this shit too!
				sig = DelayC.ar(sig,0.05,delay);
				LocalOut.ar(sig.reverse * coef * (1 - Trig.kr(amp,0.1)));
				sig = LeakDC.ar(HPF.ar(sig.sum,80));
				sig = Pan2.ar(sig,\pan.kr(0),\amp.kr(1) * 0.3);
			},
			args: [\trigRate,\coef],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]

		++

		[(
			name: "percShifter",
			func: {
				var freqDev = \freqDev.kr().linexp(0.0,1.0,0.5,2.0);
				var maxDev = \maxDev.kr().lincurve(0.0,1.0,0.25,2.0);
				var sig = In.ar(\inBus.kr,1);
				var mute = ToggleFF.kr(\trig.tr);
				var pitch = Pitch.kr(sig,ampThreshold: 0.2, median: 7);
				var trig = 1 - pitch[1];

				sig = sig * trig;
				sig = sig * (1 - mute) + LocalIn.ar(2);
				sig = PitchShift.ar(sig,1.0,freqDev,maxDev,1.0);
				sig = LeakDC.ar(sig);
				LocalOut.ar(sig.reverse * (Select.kr(mute,[0.75,1])));
				sig = Balance2.ar(sig[0],sig[1],0,\amp.kr(1));
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

		(nil!10)

		++

		(nil!10)

	).reshape(3,10),

	"bufTransforms" -> (
		[(
			name: "grainer",
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
				var	trig = \trig.tr(1);
				var speed = \sweep.kr().linlin(0.0,1.0,2,10);
				var rate = \rate.kr().linexp(0.0,1.0,0.5,2.0);
				var ramp = Env.perc(0.001,speed,-1,0).kr(gate:trig);
				var pan = TRand.kr(-1.0,1.0,trig);
				var sig = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum) * rate,1,startPos: BufFrames.kr(bufnum) * TRand.kr(0,1,1),loop:1);

				sig = FFT(LocalBuf(4096),sig);
				sig = PV_Freeze(sig,1);
				sig = PV_BrickWall(sig,ramp);
				sig = IFFT(sig);
				sig = Pan2.ar(sig,ramp.linlin(-1,0.001,pan,pan.neg),\amp.kr(1));
			},
			args: [\sweep,\rate],
			vals: [[0,0,1],[0,0.5,1]],
		)]

		++

		[(
			name: "bufRepeater",
			func: {
				var bufnum = \bufnum.kr;
				var trigRate = \trigRate.kr().linlin(0,1,0.3,10);
				var gain = \gain.kr().linlin(0,1,1,5);

				var trig = Impulse.kr(trigRate) + \trig.tr;
				var normRand = TRand.kr(0,1,trig);
				var impulse = Impulse.kr(TRand.kr(20,120,trig));
				var dur = (normRand * 0.05) + 0.01;
				var rate = normRand + 0.5;
				var pan = (normRand * 2) - 1;

				var sig = GrainBuf.ar(2,impulse,dur,bufnum,BufRateScale.kr(bufnum) * rate,normRand,2,pan,-1,mul: \amp.kr(1) * gain);
				sig = HPF.ar(sig,50).clip2(0.05);
			},
			args: [\trigRate,\gain],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]
	),

];


"SynthDefs Loaded".postln;

)

