///////////////////////////////////////////////////////MONOME Functions//////////////////////////////////////////////////////////////////////
(
4.do({
	arg channelIndex;
	var inName;

	///////////////////////////////////////////////////// io section

	if(~players[channelIndex][\inBus].size == 1,{inName = "inPlayer"},{inName = "inPlayerPair"});

	/*--------------------------------------------------------------------*/
	/*****************************inPlayer*********************************/
	/*--------------------------------------------------------------------*/

	// turn inPlayer off
	~channels[channelIndex]["io"][0][0] = {
		if(Ndef((inName ++ channelIndex).asSymbol).isPlaying,{
			Ndef((inName ++ channelIndex).asSymbol).end(fadeTime: ~control[channelIndex]["fadeTime"]);
			"%% off".format(inName,channelIndex).postln
		})
	};

	/**********************************************************************/

	// level 1 inPlayer on -> what are the levels controlling???
	~channels[channelIndex]["io"][0][1] = {
		if(Ndef((inName ++ channelIndex).asSymbol).isPlaying.not,{
			Ndef((inName ++ channelIndex).asSymbol,~synths["i/o synths"][inName]).play(
				out: ~players[channelIndex][\outBus],
				group: ~inGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToHead
			);
			Ndef((inName ++ channelIndex).asSymbol).set(
				\inBus,~players[channelIndex][\inBus][0],
				\compThresh,~players[channelIndex][\compThresh],
				\filtFreqHi,~players[channelIndex][\filtFreqHi],
				\rsHi,~players[channelIndex][\rsHi],
				\filtFreqLo,~players[channelIndex][\filtFreqLo],
				\rsLo,~players[channelIndex][\rsLo],
				\amp,(~control[channelIndex]["volume"].sum) / 12,
				\pan,~players[channelIndex][\pan],
				\sendBus,~players[channelIndex][\sendBus],
			);
			"%% on".format(inName,channelIndex).postln
		},{
			Ndef((inName ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((inName ++ channelIndex).asSymbol).xset()                                                            // what goes here??
		})
	};

	/**********************************************************************/

	~channels[channelIndex]["io"][0][2] = {}; // level 2
	~channels[channelIndex]["io"][0][3] = {}; // level 3
	~channels[channelIndex]["io"][0][4] = {}; // inPlayer mod -> what args is this updating?

	/**********************************************************************/

	// t_trig => output mute
	~channels[channelIndex]["io"][1][5] = {
		if(Ndef((inName ++ channelIndex).asSymbol).isPlaying,{
			Ndef((inName ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((inName ++ channelIndex).asSymbol).xset(\t_trig,1);
			"mute% on".format(channelIndex).postln
		},{
			"%% not playing".format(inName,channelIndex).postln
		}
	)};

	/**********************************************************************/

	// inPlayer volume
	~channels[channelIndex]["io"][1][6] = {
		if(Ndef((inName ++ channelIndex).asSymbol).isPlaying,{
			Ndef((inName ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((inName ++ channelIndex).asSymbol).xset(\amp,(~control[channelIndex]["volume"].sum) / 12)
		},{
			"%% not playing".format(inName,channelIndex).postln
		}
	)};

	/*--------------------------------------------------------------------*/
	/****************************outPlayer*********************************/
	/*--------------------------------------------------------------------*/

	// turn outPlayer off
	~channels[channelIndex]["io"][1][0] = {
		if(Ndef((\outPlayer ++ channelIndex).asSymbol).isPlaying,{
			Ndef((\outPlayer ++ channelIndex).asSymbol).end(fadeTime: ~control[channelIndex]["fadeTime"]);
			"outPlayer% off".format(channelIndex).postln
		})
	};

	/**********************************************************************/

	// outPlayer level 1
	~channels[channelIndex]["io"][1][1] = {
		if(Ndef((\outPlayer ++ channelIndex).asSymbol).isPlaying.not,{
			Ndef((\outPlayer ++ channelIndex).asSymbol,~synths["i/o synths"]["outPlayer"]).play(
				out: ~players[channelIndex][\hardwareOut],
				group: ~outGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToTail
			);
			Ndef((\outPlayer ++ channelIndex).asSymbol).set(
				\inBus,~players[channelIndex][\outBus],
				\amp,(~control[channelIndex]["volume"].sum) / 12,
				\mix,0.001
			);
			"outPlayer% on - lvl 1".format(channelIndex).postln
		},{
			Ndef((\outPlayer ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((\outPlayer ++ channelIndex).asSymbol).xset(\inBus,~players[channelIndex][\outBus],\mix,0.001)
		}
	)};

	/**********************************************************************/

	// outPlayer level 2
	~channels[channelIndex]["io"][1][2] = {
		if(Ndef((\outPlayer ++ channelIndex).asSymbol).isPlaying.not,{
			Ndef((\outPlayer ++ channelIndex).asSymbol,~synths["i/o synths"]["outPlayer"]).play(
				out: ~players[channelIndex][\hardwareOut],
				group: ~outGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToTail
			);
			Ndef((\outPlayer ++ channelIndex).asSymbol).set(
				\inBus,~players[channelIndex][\outBus],
				\amp,(~control[channelIndex]["volume"].sum) / 12,
				\mix,0.05
			);
			"outPlayer% on - lvl 2".format(channelIndex).postln
		},{
			Ndef((\outPlayer ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((\outPlayer ++ channelIndex).asSymbol).xset(\inBus,~players[channelIndex][\outBus],\mix,0.05)
		}
	)};

	/**********************************************************************/

	// outPlayer level 3
	~channels[channelIndex]["io"][1][3] = {
		if(Ndef((\outPlayer ++ channelIndex).asSymbol).isPlaying.not,{
			Ndef((\outPlayer ++ channelIndex).asSymbol,~synths["i/o synths"]["outPlayer"]).play(
				out: ~players[channelIndex][\hardwareOut],
				group: ~outGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToTail
			);
			Ndef((\outPlayer ++ channelIndex).asSymbol).set(
				\inBus,~players[channelIndex][\outBus],
				\amp,(~control[channelIndex]["volume"].sum) / 12,
				\mix,0.1
			);
			"outPlayer% on - lvl 3".format(channelIndex).postln
		},{
			Ndef((\outPlayer ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((\outPlayer ++ channelIndex).asSymbol).xset(\inBus,~players[channelIndex][\outBus],\mix,0.1)
		}
	)};

	/**********************************************************************/

	// outPlayer mod -> change the reverb mix & damp?
	~channels[channelIndex]["io"][1][4] = {};

	/**********************************************************************/

	// t_trig ???? output mute?
	~channels[channelIndex]["io"][1][5] = {
		"t_trig.set argument update".postln;
	};

	/**********************************************************************/

	// outPlayer volume
	~channels[channelIndex]["io"][1][6] = {
		if(Ndef((\outPlayer ++ channelIndex).asSymbol).isPlaying,{
			Ndef((\outPlayer ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef((\outPlayer ++ channelIndex).asSymbol).xset(\amp,(~control[channelIndex]["volume"].sum) / 12)
		},{
			"outPlayer% not playing".format(channelIndex).postln
		}
	)};

	/*--------------------------------------------------------------------*/
	/*****************************analyser*********************************/
	/*--------------------------------------------------------------------*/

	// turn analyser off
	~channels[channelIndex]["io"][2][0] = {
		if(Ndef((\analyser ++ channelIndex).asSymbol).isPlaying,{
			Ndef((\analyser ++ channelIndex).asSymbol).end(fadeTime: ~control[channelIndex]["fadeTime"]);
			"analyser% off".format(channelIndex).postln
		})
	};

	/**********************************************************************/

	// analyser levels/mod/trig/volume???
	~channels[channelIndex]["io"][2][1] = {}; // level 1 - slow impulse arg?
	~channels[channelIndex]["io"][2][2] = {}; // level 2 - medium impulse arg?
	~channels[channelIndex]["io"][2][3] = {}; // level 3 - fast impulse arg?
	~channels[channelIndex]["io"][2][4] = {}; // mod - change impulse arg?
	~channels[channelIndex]["io"][2][5] = {}; // t_trg = ????
	~channels[channelIndex]["io"][2][6] = {}; //

	3.do({
		arg rowIndex;

		/*--------------------------------------------------------------------*/
		/****************************transforms********************************/
		/*--------------------------------------------------------------------*/

		10.do({
			arg colIndex;

			if(~synths["transforms"][rowIndex][colIndex].notNil,{

				var name = ~synths["transforms"][rowIndex][colIndex][\name];
				var func = ~synths["transforms"][rowIndex][colIndex][\func];
				var args = ~synths["transforms"][rowIndex][colIndex][\args];
				var vals = ~synths["transforms"][rowIndex][colIndex][\vals];

				/**********************************************************************/

				// turn transform off
				~channels[channelIndex]["transforms"][rowIndex][colIndex][0] = {
					if(Ndef((name ++ channelIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex).asSymbol).end(fadeTime: ~control[channelIndex]["fadeTime"]);
						"%% off".format(name,channelIndex).postln;
					},{
						"%% not playing".format(name,channelIndex).postln;
					}
				)};

				/**********************************************************************/

				// first level arguments
				~channels[channelIndex]["transforms"][rowIndex][colIndex][1] = {
					if(Ndef((name ++ channelIndex).asSymbol).isPlaying.not,{
						Ndef((name ++ channelIndex).asSymbol,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef((name ++ channelIndex).asSymbol).set(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\t_trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"%% on - lvl 1".format(name,channelIndex).postln;
					},{
						Ndef((name ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex).asSymbol).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\t_trig,0
						)
					}
				)};

				/**********************************************************************/

				// second level arguments
				~channels[channelIndex]["transforms"][rowIndex][colIndex][2] = {
					if(Ndef((name ++ channelIndex).asSymbol).isPlaying.not,{
						Ndef((name ++ channelIndex).asSymbol,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef((name ++ channelIndex).asSymbol).set(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\t_trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"%% on - lvl 2".format(name,channelIndex).postln
					},{
						Ndef((name ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex).asSymbol).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\t_trig,0
						)
					}
				)};

				/**********************************************************************/

				// consider changing this function to incorporate the \analyser inputs...could be randomized?!?!?

				~channels[channelIndex]["transforms"][rowIndex][colIndex][3] = {
					if(Ndef((name ++ channelIndex).asSymbol).isPlaying.not,{
						Ndef((name ++ channelIndex).asSymbol,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef((name ++ channelIndex).asSymbol).set(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\t_trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"%% on - lvl 3".format(name,channelIndex).postln;
					},{
						Ndef((name ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex).asSymbol).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\t_trig,0
						)
					}
				)};

				/**********************************************************************/

				// mod arguments
				~channels[channelIndex]["transforms"][rowIndex][colIndex][4] = {
					if(Ndef((name ++ channelIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex).asSymbol).xset(
							args[0],~control[channelIndex]["dustTrig"] * ~control[channelIndex]["tenFold"] * ~control[channelIndex]["tenth"],
							args[1],~control[channelIndex]["impulseTrig"] * ~control[channelIndex]["tenFold"] * ~control[channelIndex]["tenth"],
							\t_trig,0
						)
					},{
						"%% not playing".format(name,channelIndex).postln;
					}
				)};

				/**********************************************************************/

				// t_trig
				~channels[channelIndex]["transforms"][rowIndex][colIndex][5] = {
					if(Ndef((name ++ channelIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex).asSymbol).set(\t_trig,1);
					},{
						"%% not playing".format(name,channelIndex).postln;
					}
				)};

				/**********************************************************************/

				// set volume
				~channels[channelIndex]["transforms"][rowIndex][colIndex][6] = {
					if(Ndef((name ++ channelIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex).asSymbol).xset(\amp,(~control[channelIndex]["volume"].sum) / 12);
					},{
						"%% not playing".format(name,channelIndex).postln;
					}
				)};

			},{

				// empty slots
				7.do({
					arg levelIndex;

					~channels[channelIndex]["transforms"][rowIndex][colIndex][levelIndex] = {"chan: % row: % col: % not assigned".format(channelIndex,rowIndex, colIndex).postln}

				});
			})
		});

		/*--------------------------------------------------------------------*/
		/*****************************recorders********************************/
		/*--------------------------------------------------------------------*/

		~channels[channelIndex]["recorders"][rowIndex][0] = {
			~buffers[channelIndex][rowIndex].free;                                                              // explore buffer.zero...
			~buffers[channelIndex][rowIndex] = Buffer.alloc(s, s.sampleRate * 12, 1);
			"buf% % freed".format(channelIndex,rowIndex).postln;
		};

		~channels[channelIndex]["recorders"][rowIndex][1] = {
			if(Ndef((\inPlayer ++ channelIndex).asSymbol).isPlaying,{
				Synth(\recorder,[
					\inBus,~players[channelIndex][\sendBus],
					\bufnum,~buffers[channelIndex][rowIndex]
				],
				Ndef((\inPlayer ++ channelIndex).asSymbol).nodeID,
				\addAfter
				);
				"buf% % recording".format(channelIndex,rowIndex).postln;
			},{
				"is %% playing?".format(inName,channelIndex).postln;
			}
		)};

		/*--------------------------------------------------------------------*/
		/***************************bufTransforms******************************/
		/*--------------------------------------------------------------------*/

		4.do({
			arg colIndex;

			if(~synths["bufTransforms"][colIndex].notNil,{

				var name = ~synths["bufTransforms"][colIndex][\name];
				var func = ~synths["bufTransforms"][colIndex][\func];
				var args = ~synths["bufTransforms"][colIndex][\args];
				var vals = ~synths["bufTransforms"][colIndex][\vals];


				/**********************************************************************/

				// turn transform off
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][0] = {
					if(Ndef((name ++ channelIndex ++ rowIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).end(fadeTime: ~control[channelIndex]["fadeTime"]);
						"%% % off".format(name,channelIndex,rowIndex).postln;
					},{
						"%% % not playing".format(name,channelIndex,rowIndex).postln;
					}
				)};

				/**********************************************************************/

				// first level arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][1] = {
					if(Ndef((name ++ channelIndex ++ rowIndex).asSymbol).isPlaying.not,{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).set(
							\inBus,~players[channelIndex][\sendBus],
							\bufnum,~buffers[channelIndex][rowIndex],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\t_trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"%% % on - lvl 1".format(name,channelIndex,rowIndex).postln;
					},{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\t_trig,0
						)
					}
				)};

				/**********************************************************************/

				// second level arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][2] = {
					if(Ndef((name ++ channelIndex ++ rowIndex).asSymbol).isPlaying.not,{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).set(
							\inBus,~players[channelIndex][\sendBus],
							\bufnum,~buffers[channelIndex][rowIndex],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\t_trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"%% % on - lvl 2".format(name,channelIndex,rowIndex).postln;
					},{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\t_trig,0
						)
					}
				)};

				/**********************************************************************/
				// consider changing this function to incorporate the \analyser inputs...could be randomized?!?!?

				// third level arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][3] = {
					if(Ndef((name ++ channelIndex ++ rowIndex).asSymbol).isPlaying.not,{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).set(
							\inBus,~players[channelIndex][\sendBus],
							\bufnum,~buffers[channelIndex][rowIndex],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\t_trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"%% % on - lvl 3".format(name,channelIndex,rowIndex).postln;
					},{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\t_trig,0
						)
					}
				)};

				/**********************************************************************/

				// mod arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][4] = {
					if(Ndef((name ++ channelIndex ++ rowIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).xset(
							args[0],~control[channelIndex]["dustTrig"] * ~control[channelIndex]["tenFold"] * ~control[channelIndex]["tenth"],
							args[1],~control[channelIndex]["impulseTrig"] * ~control[channelIndex]["tenFold"] * ~control[channelIndex]["tenth"],
							\t_trig,0
						)
					},{
						"%% % not playing".format(name,channelIndex,rowIndex).postln;
					}
				)};

				/**********************************************************************/

				// t_trig
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][5] = {
					if(Ndef((name ++ channelIndex ++ rowIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).set(\t_trig,1);
					},{
						"%% % not playing".format(name,channelIndex,rowIndex).postln;
					}
				)};

				/**********************************************************************/

				// set volume
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][6] = {
					if(Ndef((name ++ channelIndex ++ rowIndex).asSymbol).isPlaying,{
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef((name ++ channelIndex ++ rowIndex).asSymbol).xset(\amp,(~control[channelIndex]["volume"].sum) / 12);
					},{
						"%% % not playing".format(name,channelIndex,rowIndex).postln;
					}
				)}
			},{

				// empty slots
				7.do({
					arg levelIndex;

					~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][levelIndex] = {"chan: % row: % col: % not assigned".format(channelIndex,rowIndex, colIndex).postln}

				});
			});
		});
	});
});

"Functions Loaded".postln;
)