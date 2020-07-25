///////////////////////////////////////////////////////MONOME Synths//////////////////////////////////////////////////////////////////////

(
SynthDef(\recorder,{
	arg inBus,bufnum,recLevel=1.0, preLevel=0.0;
	var sig;

	sig = In.ar(inBus,1);
	RecordBuf.ar(sig,bufnum,0,recLevel,preLevel,loop:0, doneAction: 2);

}).add;

~synths = Dictionary[


	"i/o synths" -> Dictionary[

		"inPlayer" -> {
			arg inBus,compThresh,filtFreqHi,rsHi,filtFreqLo,rsLo,amp,pan,sendBus,t_trig;
			var sig,mute;

			mute = ToggleFF.kr(t_trig);

			sig = SoundIn.ar(inBus);
			sig = BHiShelf.ar(sig,filtFreqHi.linlin(0.0,1.0,20,20000),rsHi,0);
			sig = BLowShelf.ar(sig,filtFreqLo.linlin(0.0,1.0,20,20000),rsLo,0);
			sig = Compander.ar(sig,sig,compThresh,1,0.5,0.01,0.01);
			Out.ar(sendBus,sig);
			sig = Pan2.ar(sig,pan,amp);
			sig = sig * mute;
		},

		"inPlayerPair" -> {
			arg inBus,compThresh,filtFreqHi,rsHi,filtFreqLo,rsLo,amp,pan,sendBus,t_trig;
			var sig,mute;

			mute = ToggleFF.kr(t_trig);

			sig = Mix(SoundIn.ar([inBus,inBus+1]));
			sig = BHiShelf.ar(sig,filtFreqHi.linlin(0.0,1.0,20,20000),rsHi,0);
			sig = BLowShelf.ar(sig,filtFreqLo.linlin(0.0,1.0,20,20000),rsLo,0);
			sig = Compander.ar(sig,sig,compThresh,1,0.5,0.01,0.01);
			Out.ar(sendBus,sig);
			sig = Pan2.ar(sig,pan,amp); // consider rewriting this and using Balance2.ar instead...
			sig = sig * mute;
		},

		"outPlayer" -> {
			arg inBus,compThresh=0.5,mix=0.1,room=100,damp=0.6,filtFreqHi=0.1,rsHi=0.25,dBHi=(-6),amp=1.0;
			var sig;

			sig = In.ar(inBus,2);
			sig = Compander.ar(sig,sig,compThresh,1,0.5,0.01,0.01);
			sig = FreeVerb.ar(sig,mix,room,damp,amp);
			sig = BHiShelf.ar(sig,filtFreqHi.linlin(0.0,1.0,20,20000),rsHi,dBHi);
		},

		"analyser" -> {},
	],

	"transforms" -> (
		[(
			name: "ringMod",
			func: {
				arg inBus,dev,t_trig,amp=1.0;
				var env,freq,hasFreq,mod,sig;

				sig = In.ar(inBus,1);
				#freq, hasFreq = Pitch.kr(sig, ampThreshold: 0.05, median: 7);
				dev = Select.kr(Trig.kr(t_trig,TRand.kr(0.1,1.0,t_trig)),[dev,TRand.kr(30,2000,t_trig)]); //make this more interesting!
				mod = SinOsc.ar(freq*2*SinOsc.ar(dev).range(0.75,1.25));
				sig = sig*mod;
				sig = Pan2.ar(sig,LFNoise2.kr(0.2,0.7),amp);
			},
			args: [\dev,\dummyArg],
			vals: [[0.01,40,400],[1,1,1]],
		)]

		++

		[(
			name: "fftFreeze",
			func: {
				arg inBus,dustTrig,impulseTrig,t_trig,amp=1.0;
				var chain,trig,env,sig;
				var frames=4096;

				dustTrig = dustTrig.lincurve(0.0,1.0,0.0,3.0);
				impulseTrig = impulseTrig.lincurve(0.0,1.0,0.0,3.0);

				sig = In.ar(inBus,1);
				trig = Dust.kr(dustTrig) + Impulse.kr(impulseTrig) + t_trig;
				trig = Trig.kr(trig,TExpRand.kr(0.1,0.3,trig));
				chain = FFT(LocalBuf(frames), sig, 0.5, 0, 1, frames);
				chain = PV_Freeze(chain,trig);
				sig = IFFT(chain);
				sig = Pan2.ar(sig*trig,TRand.kr(-1.0,1.0,trig),amp);
			},
			args: [\dustTrig,\impulseTrig],
			vals: [[0.0,1.0,0.0],[0.0,0.0,1.0]],
		)]

		++

		[(
			name: "brokenRecord",
			func: {
				arg inBus,t_trig,dustTrig,impulseTrig,amp=0.8;
				var gate,rand,sig,sig1,trig;

				dustTrig = dustTrig.lincurve(0.0,1.0,0.0,3.0);
				impulseTrig = impulseTrig.lincurve(0.0,1.0,0.0,3.0);

				sig = In.ar(inBus,1);
				trig = Dust.kr(dustTrig) + Impulse.kr(impulseTrig) + t_trig;
				gate = EnvGen.ar(Env.sine(0.1),trig);
				rand = TExpRand.kr(0.05,0.3,trig);
				sig = CombC.ar(sig*gate,0.6,rand,Select.kr(Trig1.kr(trig,rand-0.01),[inf,0]));
				sig1 = DelayN.ar(sig,0.6,rand*7/5);
				sig = Pan2.ar(sig,LFNoise2.kr(0.2)) + Pan2.ar(sig1,LFNoise2.kr(0.2));
				sig*amp;
			},
			args: [\dustTrig,\impulseTrig],
			vals: [[0.0,1.0,0.0],[0.0,0.0,1.0]],
		)]

		++

		[(
			name: "percShiftDelay",
			func: {
				arg inBus,freqDev,maxDev,t_trig,amp=1.0;
				var grainSize=1.0,mute,trig,freq,hasFreq,sig;

				freqDev = freqDev.linexp(0.0,1.0,0.5,4.0);
				maxDev = maxDev.lincurve(0.0,1.0,0.0,3.0);

				sig = In.ar(inBus,1);
				mute = ToggleFF.kr(t_trig);
				sig = sig*(1-mute) + LocalIn.ar(1);
				#freq, hasFreq = Pitch.kr(sig, ampThreshold: 0.05, median: 7);
				trig = 1-hasFreq;
				sig = sig*trig;
				sig = PitchShift.ar(sig,grainSize,freqDev,maxDev,grainSize);
				sig = LeakDC.ar(sig);
				LocalOut.ar(sig*(Select.kr(mute,[0.75,1])));
				sig = Pan2.ar(sig,TRand.kr(-1.0,1.0,trig).lag(maxDev),amp);
			},
			args: [\freqDev,\maxDev],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]

		++

		[(
			name: "shiftDelay",
			func: {
				arg inBus,speed,delay,amp=1,t_trig;
				var local,mute,sig;

				speed = speed.linexp(0.0,1.0,0.05,7);
				delay = delay.linexp(0.0,1.0,0.3,1.5);

				sig = In.ar(inBus,1);
				mute = ToggleFF.kr(t_trig);
				local = LocalIn.ar(2);
				sig = DelayC.ar((sig*(1-mute))+local,1.5,LFNoise1.ar(speed!2).range(0.2,delay));
				LocalOut.ar((sig.reverse)*Select.kr(mute,[0.75,1]));
				sig = LeakDC.ar(sig);
				sig = Splay.ar(sig,0.5,amp);
			},
			args: [\speed,\delay],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]

		++

		[nil]
		/*[(
		name: "blstrDelay",
		func: { //rate = dustTrig, speed = impulseTrig, t_trig = t_trig
		arg inBus,t_trig,rate,speed,amp=1.0;
		var sig,trig,chain,gate;

		trig = t_trig;
		rate = Select.kr(rate.round(1),[2/3,6/7,7/8,3/2,7/6,8/7]);
		gate = EnvGen.ar(Env.sine(0.5),trig);
		sig = In.ar(inBus,1);
		sig = (sig*gate) + LocalIn.ar(1);
		sig = PitchShift.ar(sig,0.2,rate,0,0.05);
		sig = DelayC.ar(sig,0.08,speed.clip(0.01,0.08));
		LocalOut.ar(sig);
		sig = LeakDC.ar(sig);
		sig = Pan2.ar(sig,0,amp);
		},
		args: [\rate,\speed],
		vals: [[0,3,5],[0.08,0.05,0.02]],
		)]*/

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
				arg bufnum,rate,impulseTrig,t_trig,amp=1.0;
				var sig,trig,noise,grainDur=1.0,toggle,pointer,bufDur;

				noise = impulseTrig.linexp(0.0,1.0,0.1,0.001);
				rate = rate.linexp(0.0,1.0,0.5,2.0);

				trig = Impulse.kr(impulseTrig.linexp(0.0,1.0,0.3,12.0));
				bufDur = BufDur.kr(bufnum);

				pointer = Rand(0.0,1.0);
				pointer = pointer + LFNoise1.kr(12,noise);
				toggle = ToggleFF.kr(t_trig);
				toggle = Select.kr(toggle,[-1,1]);

				sig = TGrains.ar(2,trig,bufnum,BufRateScale.kr(bufnum) * rate * toggle,pointer * bufDur,grainDur,Latch.kr(LFNoise2.kr(0.1),trig),amp);
			},
			args: [\rate,\impulseTrig],
			vals: [[0.4,0.4,0.4],[1.0,0.1,0.4]],
		)]

		++

		[(
			name: "bufGlitch",
			func: {
				arg bufnum,slowTrig,fastTrig,t_trig=0,amp=1.0;
				var freq,freq2,trig,bufFr,pointer,pointer2,sig;

				freq = slowTrig.linexp(0.0,1.0,0.25,2.5);
				freq2 = fastTrig.linexp(0.0,1.0,5,15);

				trig = ToggleFF.kr(t_trig);
				bufFr = BufFrames.kr(bufnum);
				pointer = Select.kr(trig,[freq,freq2]);
				pointer = LFNoise1.ar(pointer).range(0,bufFr);

				sig = BufRd.ar(1,bufnum,pointer,1);
				sig = BHiShelf.ar(sig,3500,1,-6);
				sig = Pan2.ar(sig,pointer.linlin(0,bufFr,-1.0,1.0),amp)
			},
			args: [\slowTrig,\fastTrig],
			vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
		)]

		++

		[nil]

		++

		[nil]
	),

];


"SynthDefs Loaded".postln;

)

