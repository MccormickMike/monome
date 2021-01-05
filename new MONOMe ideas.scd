

// make an input module/option that plays back buffers?
// Could be useful for OJKOS concerts, solo concerts, etc.

/*****************************************************************/

x = 10.collect({arg i; 2**(i/9)})
y = x.rotate(-2)

[]
(
Pbind(
	\dur, 0.75,
	\freq, Pseq([x,x.scramble].flop * 500,1),
).play
)

PV_BinDelay // See Pluta's Spec_Delay mod


PitchShift
PitchShiftPA

// EXPLORE DEMAND ENVGEN - \gate arg!!!



// some sort of harmony generator/bell thing...
x = Array.fill(8,{10.rand})
~index = x.size.rand;

(
e = (
	next: {~index = ~index + 1 % x.size; x[~index]},
	repeat: {x[~index]},
	last: {~index = ~index - 1 % x.size; x[~index]},
)
);

e[\next].value
e[\repeat].value
e[\last].value

// must explore Demand Ugens also!!!

// Schmidt could be cool for some interesting .kr behaviour, especially with \analyser
// also Timer!!!
// Stepper could be used with \t_trig as a reset? similar behaviour could also come from Phasor?





// \analyser must come after output/processing also?
// add interruptions that can be triggered by buttonhold?



/**********************************************************************/
// third level arguments become (also for bufTransforms with Ndef names adding ++ rowIndex):

~channels[channelIndex]["transforms"][rowIndex][colIndex][3] = {
	if(Ndef((name ++ channelIndex).asSymbol).isPlaying.not,
		{
			Ndef((name ++ channelIndex).asSymbol,func).play(
				out: ~players[channelIndex][\outBus],
				group: ~transformsGroup,
				fadeTime: ~control[channelIndex]["fadeTime"]
			);
			Ndef((name ++ channelIndex).asSymbol).set(
				\inBus,~players[channelIndex][\sendBus],
				args[0],vals[0][2], // some value from control Bus?
				args[1],vals[1][2], // some value from control Bus?
				\t_trig,0, // some value from control Bus?
				\amp,(~control[channelIndex]["volume"].sum) / 12
			);
			"%% on - lvl 3".format(name,channelIndex).postln;
		},{
			Ndef((name ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((name ++ channelIndex).asSymbol).xset(
				\inBus,~players[channelIndex][\sendBus],
				args[0],vals[0][2], // some value from control Bus?
				args[1],vals[1][2], // some value from control Bus?
				\t_trig,0 // some value from control Bus?
			)
		}
)};


// t_trig values could be [~busses[channelIndex]["onsetsBus"],~busses[channelIndex]["hasFreqBus"]].choose, for example
// t_trig could be silenceBus for bufTransforms!!!

/*****************************************************************/

(
Ndef(\crush,{
	arg inBus,sRate,bits,t_trig,amp=1.0;
	var env,freq,hasFreq,mod,sig;

	sig = In.ar(inBus,1);

	/*

	t-trig in Select chooses between bitCrush/sRateSquash/both
	LFNoise0 drives the glitchiness...

	*/


	sig = Decimator.ar(sig,s.sampleRate * sRate, 24 * bits);

	sig = Pan2.ar(sig,LFNoise2.kr(0.2,0.7),amp);

}).play
)

// Decimator: t_trig cycles through Select.ar(bitCrush,1/1,sampleRateSquash/both); changing values driven by LFNoise0.ar(rate!2) for max glitchiness


/**********************************************************************/

(
name: "blstrDelay",
func: {
	arg inBus,t_trig,rate,speed,amp=1.0;
	var sig,trig,chain,gate;

	trig = t_trig;
	rate = Select.kr(rate.round(1),[2/3,6/7,7/8,3/2,7/6,8/7]);
	gate = EnvGen.ar(Env.sine(0.5),trig);
	sig = In.ar(inBus,1);
	sig = (sig*gate) + LocalIn.ar(1);
	sig = PitchShift.ar(sig,0.2,rate,0,0.05);
	sig = DelayC.ar(sig,0.08,speed.clip(0.01,0.08)); // consider using CombC??
	LocalOut.ar(sig);
	sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig,0,amp);
},
args: [\rate,\speed],
vals: [[0,3,5],[0.08,0.05,0.02]],
)

/**********************************************************************/

(
name: "freezeBells",
func: {
	arg inBus,outBus,pan=0,amp=0.8;
	var chain,ramp,rate,sig;

	ramp = Line.ar(-1.0,-0.001,ExpRand(8.0,14.0),doneAction: 2);
	sig = In.ar(inBus,1);
	chain = FFT(LocalBuf(1024),sig);
	chain = PV_Freeze(chain,1);
	chain = PV_BrickWall(chain,ramp);
	sig = IFFT(chain);
	sig = Pan2.ar(sig,pan,amp);

},
args: [],
vals: [[],[]],
)
/**********************************************************************/


PV_BinDelay

(
SynthDef("resonNoise2_mod", {
	arg inBus, outBus=0, transferBus=0, noiseVol=0.1, inOutVol=0.1, centerFreq=1000, lfoFreq=0.01, rq = 0.1, onOff=1, gate=1, pauseGate=1;
	var env, in, noiseOut, inOut, pauseEnv, freq;

	in = SoundIn.ar(0);
	freq = max(centerFreq+SinOsc.ar(lfoFreq, 0, centerFreq*0.8), 40);
	inOut = Resonz.ar(in, freq, rq);
	noiseOut = Resonz.ar(WhiteNoise.ar(1), freq, rq);
	env = EnvGen.kr(Env.asr(0,1,0), gate, doneAction:2);
	pauseEnv = EnvGen.kr(Env.asr(0,1,0), pauseGate, doneAction:1);
	noiseOut = Pan2.ar(noiseOut, LFNoise2.kr(lfoFreq+5/20));
	Out.ar(transferBus, inOut*LagUD.kr(onOff, 0.1, 1)*env*pauseEnv*inOutVol);
	Out.ar(outBus, noiseOut*LagUD.kr(onOff, 0.1, 1)*env*pauseEnv*noiseVol);
}).add;
)

x = Synth("resonNoise2_mod")
x.set(\centerFreq,800,\noiseVol,0.7,\inOutVol,0.6,\lfoFreq,0.01)

/**********************************************************************/

( //explore a similar idea with Decimator maybe?
SynthDef("noiseGliss2_mod", {
	arg inBus, outBus=0, pulseRate=400, shift=2, vol=1, gate = 1, pauseGate = 1;
	var in, out0, env, pauseEnv;

	pauseEnv = EnvGen.kr(Env.asr(0.01,1,0.01), pauseGate, doneAction:1);
	env = EnvGen.kr(Env.asr(0.01,1,0.01), gate, doneAction:2);

	in = SoundIn.ar(0);

	out0 = PitchShift.ar(in, 0.2, shift);

	out0 = Latch.ar(out0, Impulse.ar(LFNoise0.kr(0.1).range(1000, 5000)));//downsampled

	out0 = out0*Trig1.ar(Dust.kr(LFNoise0.kr(0.2).range(pulseRate, pulseRate*1.5)), LFNoise0.kr(0.3).range(0.025, 0.05)).lag(0.001);

	out0 = Pan2.ar(out0, SinOsc.ar(LFNoise0.kr(0.2).range(0.25, 1), Rand(0, 2pi)));

	Out.ar(outBus, out0*vol*pauseEnv*env);
}).add;
)

/**********************************************************************/

( //must investigate another time
SynthDef("cycleGripper_mod", {
	arg inBus, outBus=0, trigRateDust=0, trigRateImpulse=1, mode=0, inDelay = 0.02, t_trig = 0, gate = 1, pauseGate = 1;
	var trig, div0, div1, switch0, switch1, source, local, delay, delayTime;
	var triga, div0a, div1a, switch0a, switch1a, env, pauseEnv;

	env = EnvGen.kr(Env.asr(0.01,1,0.01), gate, doneAction:2);
	pauseEnv = EnvGen.kr(Env.asr(0.01,1,0.01), pauseGate, doneAction:1);

	trig = Dust.kr(trigRateDust) + Impulse.kr(trigRateImpulse);

	div0 = PulseDivider.kr(trig, 2, 0);
	div1 = PulseDivider.kr(trig, 2, 1);
	switch0 = SetResetFF.kr(div0,div1);
	switch1 = SetResetFF.kr(div1,div0);

	div0a = Trig.kr(t_trig, 0.01);
	div1a = Trig.kr(TDelay.kr(t_trig, inDelay), 0.01);
	switch0a = SetResetFF.kr(div0a,div1a);
	switch1a = SetResetFF.kr(div1a,div0a);

	switch0 = Select.kr(mode, [switch0, switch0a, 1]);
	switch1 = Select.kr(mode, [switch1, switch1a, 0]);

	source = SoundIn.ar([0,1]);

	delayTime = Select.kr(mode, [TRand.kr(64/44100, 1024/44100, trig), inDelay, inDelay]);

	delay = DelayN.ar(LocalIn.ar(2), 8192/44100, delayTime);

	delay = Compander.ar((switch1*delay), (switch1*delay), 1, 1, 0.5, 0.01, 0.01).distort.clip2(0.8);
	//delay = (delay+PitchShift.ar(delay, 0.02, TRand.kr(0.9, 1.1, switch1), 0.01, 0));

	local = Mix.new([(switch0*source),delay]);

	LocalOut.ar(local.reverse*1.2);

	Out.ar(outBus, local*env*pauseEnv);
}).add;
)
/**********************************************************************/
(
SynthDef(\flanger, {
	arg out=0, in=0, delay=0.1, depth=0.08, rate=0.06, fdbk=0.0, decay=0.0;
	var input, maxdelay, maxrate, dsig, mixed, local;

	maxdelay = 0.013;
	maxrate = 10.0;
	input = SoundIn.ar(0);
	local = LocalIn.ar(1);
	dsig = AllpassL.ar( // the delay (you could use AllpassC (put 0 in decay))
		input + (local * fdbk),
		maxdelay * 2,
		LFPar.kr( // very similar to SinOsc (try to replace it) - Even use LFTri
			rate * maxrate,
			0,
			depth * maxdelay,
			delay * maxdelay),
		decay);
	mixed = input + dsig;
	LocalOut.ar(mixed);
	Out.ar([out, out+1], mixed);
}).add;
)

Synth(\flanger)

/**********************************************************************/

SynthDef(\chorus, {
	arg inbus=10, outbus=0, predelay=0.08, speed=0.05, depth=0.1, ph_diff=0.5;
	var in, sig, modulators, numDelays = 12;

	in = SoundIn.ar(0);
	modulators = Array.fill(numDelays, {arg i;
		������	LFPar.kr(speed * rrand(0.94, 1.06), ph_diff * i, depth, predelay);});�
	sig = DelayC.ar(in, 0.5, modulators);��
	sig = sig.sum; //Mix(sig);
	Out.ar(outbus, sig!2); // output in stereo

}).load(s)

Synth(\chorus)


/**********************************************************************/

//tweak this!!! Change the reverb for sure...maybe this can have RandComb or some other FFT stuff?
(
// for fun: a noisegater with a bit of reverb (controlled by mouseY)
// better use headphones - danger of feedback!
{
	var in, compander;
	var predelay=0.048, combdecay=3.7, allpassdecay=0.21, revVol=0.21;
	in = SoundIn.ar(0);
	compander = Compander.ar(in, in, MouseX.kr(0.005, 1, 1), 10, 1, 0.01, 0.01);
	z = DelayN.ar(compander, 0.1, predelay);
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, rrand(0.03, 0.05), MouseY.kr(1,20, 1)) }));
	6.do({ y = AllpassN.ar(y, 0.050, rrand(0.03, 0.05), allpassdecay) });
	y!2
}.play
)

/**********************************************************************/

(
// sustainer - Audio In
{
	var in, compander;
	in = SoundIn.ar(0);
	compander = Compander.ar(in,in,MouseX.kr(0.001, 1, 1), 0.1, 1, 0.01, 0.01);
	compander ! 2 // stereo
}.play
)
/**********************************************************************/
(
Ndef(\randCombDelay,{
	arg inBus=0,dustTrig,impulseTrig,t_trig,amp=0.7;
	var in,chain,frames=4096,wipe=0.91,trig,sig;

	trig = Dust.kr(dustTrig) + Impulse.kr(impulseTrig) + t_trig;
	in = SoundIn.ar(inBus);
	in = DelayC.ar(in,3.0,3.0*LFNoise2.kr(0.2).range(0.25,1.0));
	chain = FFT(LocalBuf(frames),in);
	chain = PV_RandComb(chain,wipe,trig);
	sig = IFFT(chain);
	sig = AllpassC.ar(sig,0.5,0.5,1.5);
	sig = Pan2.ar(sig,Latch.kr(LFNoise2.kr(0.3),trig),amp);

}).play;
)

Ndef(\randCombDelay).fadeTime = 3
Ndef(\randCombDelay).xset(\dustTrig,0,\impulseTrig,0,\t_trig,1)
/**********************************************************************/
(
Ndef(\twinkle,{ //freq can be controlled by tap tempos and also a Trand
	arg inBus,freq=0.1,amp=0.8;
	var sig,bufnum;

	sig = SoundIn.ar(inBus);
	sig = Ringz.ar(sig,LFNoise0.ar(freq+(0.1,0.2..0.8)).range(40,3000),2.0,0.1);
	sig = Splay.ar(sig.scramble,1,amp*0.1);

}).play
)

Ndef(\twinkle).clear

b = ~voice
/**********************************************************************/
(
x = { var trig, rate, framesInBuffer;
	rate = XLine.ar(0.1,200,20);
	trig = Impulse.ar(rate);
	framesInBuffer = BufFrames.kr(b.bufnum);
	x = Phasor.ar(trig, BufRateScale.kr(b.bufnum), 0, framesInBuffer,
		[framesInBuffer/(LFNoise0.kr(8)), MouseY.kr(0, framesInBuffer)]);
	BufRd.ar(2, b.bufnum, x);
}.play;
)
