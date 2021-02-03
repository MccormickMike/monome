
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

/**********************************************************************/


~buf = Buffer.readChannel(s,"/Users/mikemccormick/Desktop/GHOST samples/stereo/ciaccona.aiff",channels:[0])
~buf0 = Buffer.readChannel(s,"/Users/mikemccormick/Desktop/GHOST samples/stereo/exploding-lightbulb copy 2.wav",channels:[0])
var sig = PlayBuf.ar(1,~buf,BufRateScale.kr(~buf),loop:1);

// add compression?


/**********************************************************************/


(
// name: "boomer",
Ndef(\test,{
	var dustTrig = \dustTrig.kr().lincurve(0.0,1,0.1,4);
	var impulseTrig = \impulseTrig.kr().lincurve(0.0,1.0,0.5,12.0);
	var trig = Dust.kr(dustTrig) + Impulse.kr(impulseTrig) + \trig.tr;

	// var sig = In.ar(\inBus.kr,1);  // integrate this shit!! increased input slows down modulation speed?

	// several noise modulators feeding eachother - can go from pitched melodies to noise!


	var env = Env.perc(0.01,(impulseTrig + dustTrig).reciprocal,curve: -3).kr(gate:trig);
	var sig = BrownNoise.ar(30!2);  //clipnoise? Can i make noise from modulated sines?

	sig = (sig * env).tanh;

	sig = Balance2.ar(sig[0],sig[1],\pan.kr(0),\amp.kr(0.5) * 0.25)

}).play
// args: [\dustTrig,\impulseTrig],
// vals: [[0.0,0.5,1.0],[0.0,0.5,1.0]],
)

Ndef(\test).set(\amp,1,\impulseTrig,0.6,\dustTrig,1)
Ndef(\test).set(\trig,1)
Ndef(\test).clear













