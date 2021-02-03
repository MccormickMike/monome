///////////////////////////////////////////////////////MONOME Functions//////////////////////////////////////////////////////////////////////
(
4.do({ |channelIndex|
	var inName;
	var modFunc = {|trigRate|
		case
		{~control[channelIndex]["sqrt"] == ~control[channelIndex]["squared"]}{trigRate}
		{~control[channelIndex]["sqrt"]}{trigRate.sqrt}
		{~control[channelIndex]["squared"]}{trigRate.squared}
		// could add a postln here for a bit of help?
	};

	/*

	consider adding: if(Ndef((inName ++ channelIndex).asSymbol).isPlaying.not,{raise an error when transforms are activated?})

	*/

	///////////////////////////////////////////////////// io section

	if(~players[channelIndex][\inBus].size == 1,{inName = "inPlayer"},{inName = "inPlayerPair"});

	/*--------------------------------------------------------------------*/
	/*                            inPlayer                                */
	/*--------------------------------------------------------------------*/

	// turn inPlayer off
	~channels[channelIndex]["io"][0][0] = {
		var synthKey = (inName ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying,{
			Ndef(synthKey).end(fadeTime: ~control[channelIndex]["fadeTime"]);
			"% off".format(synthKey).postln
		})
	};

	/**********************************************************************/

	// level 1 inPlayer on -> what are the levels controlling???
	~channels[channelIndex]["io"][0][1] = {
		var synthKey = (inName ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying.not,{
			Ndef(synthKey,~synths["i/o synths"][inName]).play(
				out: ~players[channelIndex][\outBus],
				group: ~inGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToHead
			);
			Ndef(synthKey).set(
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
			"% on".format(synthKey).postln
		},{
			Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef(synthKey).xset()                                                      // what goes here??
		})
	};

	/**********************************************************************/

	~channels[channelIndex]["io"][0][2] = {}; // level 2
	~channels[channelIndex]["io"][0][3] = {}; // level 3
	~channels[channelIndex]["io"][0][4] = {}; // inPlayer mod -> what args is this updating?

	/**********************************************************************/

	// t_trig => output mute
	~channels[channelIndex]["io"][0][5] = {
		var synthKey = (inName ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying,{
			Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef(synthKey).set(\trig,1);
			"mute% on".format(channelIndex).postln
		},{
			"% not playing".format(synthKey).postln
		})
	};

	/**********************************************************************/

	// inPlayer volume
	~channels[channelIndex]["io"][0][6] = {
		var synthKey = (inName ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying,{
			Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef(synthKey).xset(\amp,(~control[channelIndex]["volume"].sum) / 12)
		},{
			"% not playing".format(synthKey).postln
		})
	};

	/*--------------------------------------------------------------------*/
	/*                           outPlayer                                */
	/*--------------------------------------------------------------------*/

	// turn outPlayer off
	~channels[channelIndex]["io"][1][0] = {
		var synthKey = ("outPlayer" ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying,{
			Ndef(synthKey).end(fadeTime: ~control[channelIndex]["fadeTime"]);
			"% off".format(synthKey).postln
		})
	};

	/**********************************************************************/

	// outPlayer level 1
	~channels[channelIndex]["io"][1][1] = {
		var synthKey = ("outPlayer" ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying.not,{
			Ndef(synthKey,~synths["i/o synths"]["outPlayer"]).play(
				out: ~players[channelIndex][\hardwareOut],
				group: ~outGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToTail
			);
			Ndef(synthKey).set(
				\inBus,~players[channelIndex][\outBus],
				\amp,(~control[channelIndex]["volume"].sum) / 12,
				\mix,0
			);
			"% on - lvl 1".format(synthKey).postln
		},{
			Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef(synthKey).xset(\inBus,~players[channelIndex][\outBus],\mix,0)
		})
	};

	/**********************************************************************/

	// outPlayer level 2
	~channels[channelIndex]["io"][1][2] = {
		var synthKey = ("outPlayer" ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying.not,{
			Ndef(synthKey,~synths["i/o synths"]["outPlayer"]).play(
				out: ~players[channelIndex][\hardwareOut],
				group: ~outGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToTail
			);
			Ndef(synthKey).set(
				\inBus,~players[channelIndex][\outBus],
				\amp,(~control[channelIndex]["volume"].sum) / 12,
				\mix,0.1
			);
			"% on - lvl 2".format(synthKey).postln
		},{
			Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef(synthKey).xset(\inBus,~players[channelIndex][\outBus],\mix,0.1)
		})
	};

	/**********************************************************************/

	// outPlayer level 3
	~channels[channelIndex]["io"][1][3] = {
		var synthKey = ("outPlayer" ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying.not,{
			Ndef(synthKey,~synths["i/o synths"]["outPlayer"]).play(
				out: ~players[channelIndex][\hardwareOut],
				group: ~outGroup,
				fadeTime: ~control[channelIndex]["fadeTime"],
				addAction: \addToTail
			);
			Ndef(synthKey).set(
				\inBus,~players[channelIndex][\outBus],
				\amp,(~control[channelIndex]["volume"].sum) / 12,
				\mix,0.6
			);
			"% on - lvl 3".format(synthKey).postln
		},{
			Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef(synthKey).xset(\inBus,~players[channelIndex][\outBus],\mix,0.6)
		})
	};

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
		var synthKey = ("outPlayer" ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying,{
			Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
			Ndef(synthKey).xset(\amp,(~control[channelIndex]["volume"].sum) / 12)
		},{
			"% not playing".format(synthKey).postln
		})
	};

	/*--------------------------------------------------------------------*/
	/*                            analyser                                */
	/*--------------------------------------------------------------------*/

	// turn analyser off
	~channels[channelIndex]["io"][2][0] = {
		var synthKey = ("analyser" ++ channelIndex).asSymbol;

		if(Ndef(synthKey).isPlaying,{
			Ndef(synthKey).end(fadeTime: ~control[channelIndex]["fadeTime"]);
			"% off".format(synthKey).postln
		})
	};

	/**********************************************************************/

	// analyser levels/mod/trig/volume???
	~channels[channelIndex]["io"][2][1] = {}; // level 1 - slow impulse arg?
	~channels[channelIndex]["io"][2][2] = {}; // level 2 - medium impulse arg?
	~channels[channelIndex]["io"][2][3] = {}; // level 3 - fast impulse arg?
	~channels[channelIndex]["io"][2][4] = {}; // mod - change impulse arg?
	~channels[channelIndex]["io"][2][5] = {}; // t_trig = ????
	~channels[channelIndex]["io"][2][6] = {}; // volume...??? or impulse speed / trigFreq

	3.do({ |rowIndex|

		/*--------------------------------------------------------------------*/
		/*                           transforms                               */
		/*--------------------------------------------------------------------*/

		10.do({ |colIndex|

			if(~synths["transforms"][rowIndex][colIndex].notNil,{

				var name = ~synths["transforms"][rowIndex][colIndex][\name];
				var func = ~synths["transforms"][rowIndex][colIndex][\func];
				var args = ~synths["transforms"][rowIndex][colIndex][\args];
				var vals = ~synths["transforms"][rowIndex][colIndex][\vals];

				/**********************************************************************/

				// turn transform off
				~channels[channelIndex]["transforms"][rowIndex][colIndex][0] = {
					var synthKey = (name ++ channelIndex).asSymbol;                      //move this up to the ~synth vars

					if(Ndef(synthKey).isPlaying,{
						Ndef(synthKey).end(fadeTime: ~control[channelIndex]["fadeTime"]);
						"% off".format(synthKey).postln;
					},{
						"% not playing".format(synthKey).postln;
					})
				};

				/**********************************************************************/

				// first level arguments
				~channels[channelIndex]["transforms"][rowIndex][colIndex][1] = {
					var synthKey = (name ++ channelIndex).asSymbol;

					if(Ndef(synthKey).isPlaying.not,{
						Ndef(synthKey,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef(synthKey).set(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"% on - lvl 1".format(synthKey).postln;
					},{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\trig,0
						)
					})
				};

				/**********************************************************************/

				// second level arguments
				~channels[channelIndex]["transforms"][rowIndex][colIndex][2] = {
					var synthKey = (name ++ channelIndex).asSymbol;

					if(Ndef(synthKey).isPlaying.not,{
						Ndef(synthKey,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef(synthKey).set(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"% on - lvl 2".format(synthKey).postln
					},{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\trig,0
						)
					})
				};

				/**********************************************************************/

				// consider changing this function to incorporate the \analyser inputs...could be randomized?!?!?
				// if(\analyser.isPlaying,{random mapping},{standard mapping})


				~channels[channelIndex]["transforms"][rowIndex][colIndex][3] = {
					var synthKey = (name ++ channelIndex).asSymbol;

					if(Ndef(synthKey).isPlaying.not,{
						Ndef(synthKey,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef(synthKey).set(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"% on - lvl 3".format(synthKey).postln;
					},{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\trig,0
						)
					})
				};

				/**********************************************************************/

				// mod arguments
				~channels[channelIndex]["transforms"][rowIndex][colIndex][4] = {
					var synthKey = (name ++ channelIndex).asSymbol;

					if(Ndef(synthKey).isPlaying,{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							args[0],modFunc.(~control[channelIndex]["dustTrig"]),
							args[1],modFunc.(~control[channelIndex]["impulseTrig"]),
							\trig,0
						)
					},{
						"% not playing".format(synthKey).postln;
					})
				};

				/**********************************************************************/

				// t_trig
				~channels[channelIndex]["transforms"][rowIndex][colIndex][5] = {
					var synthKey = (name ++ channelIndex).asSymbol;

					if(Ndef(synthKey).isPlaying,{
						// original
						// Ndef(synthKey).set(\trig,1);

						// new
						Ndef(synthKey).set(
							args[0],modFunc.(~control[channelIndex]["dustTrig"]),
							args[1],modFunc.(~control[channelIndex]["impulseTrig"]),
							\trig,1,
						)
					},{
						"% not playing".format(synthKey).postln;
					})
				};

				/**********************************************************************/

				// set volume
				~channels[channelIndex]["transforms"][rowIndex][colIndex][6] = {
					var synthKey = (name ++ channelIndex).asSymbol;

					if(Ndef(synthKey).isPlaying,{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(\amp,(~control[channelIndex]["volume"].sum) / 12);
					},{
						"% not playing".format(synthKey).postln;
					})
				};

			},{

				// empty slots
				7.do({ |levelIndex|

					~channels[channelIndex]["transforms"][rowIndex][colIndex][levelIndex] = {"chan: % row: % col: % not assigned".format(channelIndex,rowIndex, colIndex).postln}

				});
			})
		});

		/*--------------------------------------------------------------------*/
		/*                            recorders                               */
		/*--------------------------------------------------------------------*/

		~channels[channelIndex]["recorders"][rowIndex][0] = {
			~buffers[channelIndex][rowIndex].free;                                             // explore buffer.zero...
			~buffers[channelIndex][rowIndex] = Buffer.alloc(s, s.sampleRate * 12, 1);          // avoid using s!! is it used elsewhere in this file?
			"buf% % freed".format(channelIndex,rowIndex).postln;
		};

		~channels[channelIndex]["recorders"][rowIndex][1] = {
			var inKey = (inName ++ channelIndex).asSymbol;

			if(Ndef(inKey).isPlaying,{
				Synth(\recorder,[
					\inBus,~players[channelIndex][\sendBus],
					\bufnum,~buffers[channelIndex][rowIndex]
				],
				Ndef(inKey).nodeID,
				\addAfter
				);
				"buf% % recording".format(channelIndex,rowIndex).postln;
			},{
				"is % playing?".format(inKey).postln;
			})
		};

		/*--------------------------------------------------------------------*/
		/*                          bufTransforms                             */
		/*--------------------------------------------------------------------*/

		4.do({ |colIndex|

			if(~synths["bufTransforms"][colIndex].notNil,{

				var name = ~synths["bufTransforms"][colIndex][\name];
				var func = ~synths["bufTransforms"][colIndex][\func];
				var args = ~synths["bufTransforms"][colIndex][\args];
				var vals = ~synths["bufTransforms"][colIndex][\vals];

				/**********************************************************************/

				// turn transform off
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][0] = {
					var synthKey = (name ++ channelIndex ++ rowIndex).asSymbol;                //move this up to the ~synth vars

					if(Ndef(synthKey).isPlaying,{
						Ndef(synthKey).end(fadeTime: ~control[channelIndex]["fadeTime"]);
						"% off".format(synthKey).postln;
					},{
						"% not playing".format(synthKey).postln;
					})
				};

				/**********************************************************************/

				// first level arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][1] = {
					var synthKey = (name ++ channelIndex ++ rowIndex).asSymbol;

					if(Ndef(synthKey).isPlaying.not,{
						Ndef(synthKey,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef(synthKey).set(
							\inBus,~players[channelIndex][\sendBus],
							\bufnum,~buffers[channelIndex][rowIndex],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"% on - lvl 1".format(synthKey).postln;
					},{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][0],
							args[1],vals[1][0],
							\trig,0
						)
					})
				};

				/**********************************************************************/

				// second level arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][2] = {
					var synthKey = (name ++ channelIndex ++ rowIndex).asSymbol;

					if(Ndef(synthKey).isPlaying.not,{
						Ndef(synthKey,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef(synthKey).set(
							\inBus,~players[channelIndex][\sendBus],
							\bufnum,~buffers[channelIndex][rowIndex],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"% on - lvl 2".format(synthKey).postln;
					},{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][1],
							args[1],vals[1][1],
							\trig,0
						)
					})
				};

				/**********************************************************************/
				// consider changing this function to incorporate the \analyser inputs...could be randomized?!?!?

				// third level arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][3] = {
					var synthKey = (name ++ channelIndex ++ rowIndex).asSymbol;

					if(Ndef(synthKey).isPlaying.not,{
						Ndef(synthKey,func).play(
							out: ~players[channelIndex][\outBus],
							group: ~transformsGroup,
							fadeTime: ~control[channelIndex]["fadeTime"]
						);
						Ndef(synthKey).set(
							\inBus,~players[channelIndex][\sendBus],
							\bufnum,~buffers[channelIndex][rowIndex],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\trig,0,
							\amp,(~control[channelIndex]["volume"].sum) / 12
						);
						"% on - lvl 3".format(synthKey).postln;
					},{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							\inBus,~players[channelIndex][\sendBus],
							args[0],vals[0][2],
							args[1],vals[1][2],
							\trig,0
						)
					})
				};

				/**********************************************************************/

				// mod arguments
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][4] = {
					var synthKey = (name ++ channelIndex ++ rowIndex).asSymbol;

					if(Ndef(synthKey).isPlaying,{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(
							args[0],modFunc.(~control[channelIndex]["dustTrig"]),
							args[1],modFunc.(~control[channelIndex]["impulseTrig"]),
							\trig,0
						)
					},{
						"% not playing".format(synthKey).postln;
					})
				};

				/**********************************************************************/

				// t_trig
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][5] = {
					var synthKey = (name ++ channelIndex ++ rowIndex).asSymbol;

					if(Ndef(synthKey).isPlaying,{
						// original
						// Ndef(synthKey).set(\trig,1);

						// new
						Ndef(synthKey).set(
							args[0],modFunc.(~control[channelIndex]["dustTrig"]),
							args[1],modFunc.(~control[channelIndex]["impulseTrig"]),
							\trig,1
						)
					},{
						"% not playing".format(synthKey).postln;
					})
				};

				/**********************************************************************/

				// set volume
				~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][6] = {
					var synthKey = (name ++ channelIndex ++ rowIndex).asSymbol;

					if(Ndef(synthKey).isPlaying,{
						Ndef(synthKey).fadeTime = ~control[channelIndex]["fadeTime"];
						Ndef(synthKey).xset(\amp,(~control[channelIndex]["volume"].sum) / 12);
					},{
						"% not playing".format(synthKey).postln;
					})
				}
			},{

				// empty slots
				7.do({ |levelIndex|

					~channels[channelIndex]["bufTransforms"][rowIndex][colIndex][levelIndex] = {"chan: % row: % col: % not assigned".format(channelIndex,rowIndex, colIndex).postln}

				});
			});
		});
	});
});

"Functions Loaded".postln;
)