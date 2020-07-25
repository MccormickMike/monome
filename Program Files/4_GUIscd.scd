///////////////////////////////////////////////////////MONOME GUI//////////////////////////////////////////////////////////////////////

(
(
~info = {
	arg synth = nil;
	var name,arg0,arg1;
	var moduleW, scale;
	var levels = Array.fill(4,{Button()});
	var triggers = Array.fill(4,{Button()});
	var modifiers = Array.fill(4,{Button()});
	var volume = Array.fill(4,{Button()});

	var levLayout = VLayout();
	var trigLayout = VLayout();
	var modLayout = VLayout();
	var volLayout = VLayout();

	var wineCol = Color.new255(94, 11, 94);
	var textCol = Color.new255(220,222,190);


	if(synth.isNil,{
		name = "nil";
		arg0 = "dust \ntrig";
		arg1 = "dust \ntrig";
	},{
		name = synth.name;
		arg0 = synth.args[0].asString;
		arg1 = synth.args[1].asString;

	});

	moduleW = Window(name,200@200);
	scale = moduleW.bounds.height/10;



	[1,2,3,0].do({ // is this the order???
		arg i;

		levLayout.add(
			levels[i]
			.states_([["lev %".format(i)]])
			.minHeight_(scale*2),
			align: \center
		)
	});

	4.do({
		arg i;
		var string = [arg0,arg1,"clear \ntrig","t_trig"];

		trigLayout.add(
			triggers[i]
			.states_([[string[i]]])
			.minHeight_(scale*2),
			align: \center
		)
	});

	4.do({
		arg i;
		var string = ["fadeTime","tenFold","tenth","mod"];

		modLayout.add(
			modifiers[i]
			.states_([[string[i]]])
			.minHeight_(scale*2),
			align: \center
		)
	});

	4.reverseDo({
		arg i;

		volLayout.add(
			volume[i]
			.states_([["vol %".format(i)]])
			.minHeight_(scale*2),
			align: \center
		)
	});

	moduleW.layout_(
		HLayout(
			levLayout,
			trigLayout,
			modLayout,
			volLayout
		)

	);

	moduleW.background_(wineCol);
	moduleW.front;
	moduleW.onClose({
		"closed".postln;
	});
});


(
~mainW = {
	var screenB = Window.availableBounds;
	var monomeW = Window("monome",Rect(0,0,screenB.width/2,screenB.height));
	var mixerView, monomeView;
	var labels, lineSeparator;
	var buttIO = {Array.fill(3,{Button()})}!4;
	var buttMod = {Array.fill2D(3,10,{Button()})}!4;
	var buttRec = {Array.fill(3,{Button()})}!4;
	var buttBuf = {Array.fill2D(4,4,{Button()})}!4;

	var colIO = {VLayout()}!4;
	var rowMod = {Array.fill(3,{HLayout()})}!4;
	var colRec = {VLayout()}!4;
	var rowBuf = {Array.fill(3,{HLayout()})}!4;

	var wineCol = Color.new255(94, 11, 94);
	var textCol = Color.new255(220,222,190);

	QtGUI.palette = QPalette.system;

	////////////

	buttIO.size.do({
		arg i;

		buttIO[i].size.do({
			arg j;

			colIO[i].add(
				buttIO[i][j]
				.states_([["i/o\n"++ i ++ " " ++ j]])
				.font_(Font("Menlo", 12,true))
			)
		})

	});

	buttMod.size.do({
		arg i;

		buttMod[i].size.do({
			arg j;

			buttMod[i][j].size.do({
				arg k;

				if(~synths["transforms"][j][k].notNil,{

					rowMod[i][j].add(
						buttMod[i][j][k]
						.states_([[~synths["transforms"][j][k].name ++ "\n" ++ i]])
						.font_(Font("Menlo", 12,true))
						.action_({~info.value(~synths["transforms"][j][k])})
					)
				},{
					rowMod[i][j].add(
						buttMod[i][j][k]
						.states_([["mod\n"++ i ++ " "  ++ j ++ " " ++ k]])
						.font_(Font("Menlo", 12,true))
					)
				})
			})
		})
	});

	buttRec.size.do({
		arg i;

		buttRec[i].size.do({
			arg j;

			colRec[i].add(
				buttRec[i][j]
				.states_([["rec\n"++i ++ " " ++ j]])
				.font_(Font("Menlo", 12,true))
			)
		})
	});

	buttBuf.size.do({
		arg i;

		buttBuf[i].size.do({
			arg j;

			buttBuf[i][j].size.do({
				arg k;

				rowBuf[i][j].add(
					buttBuf[i][j][k]
					.states_([["buf\n"++ i ++ " "  ++ j ++ " " ++ k]])
					.font_(Font("Menlo", 12,true))
				)
			})
		})

	});

	monomeView = 4.collect({
		arg channelIndex;
		HLayout(
			colIO[channelIndex],
			VLayout(
				rowMod[channelIndex][0],
				rowMod[channelIndex][1],
				rowMod[channelIndex][2],
			),
			colRec[channelIndex],
			VLayout(
				rowBuf[channelIndex][0],
				rowBuf[channelIndex][1],
				rowBuf[channelIndex][2],
			),
		)
	});

	mixerView = 4.collect({
		arg channelIndex;

		var knobs = 2.collect({
			arg i;
			2.collect({
				arg j;
				Array.fill(4,{
					arg k;
					Knob()
					.value_(0.5)
					.color_([wineCol,Color.black,textCol,textCol])
					.maxWidth_(screenB.width/64)
					.action_({knobValues[i][j][k].value_(knobs[i][j][k].value)})
				});
			})
		});

		var knobValues = knobs.size.collect({
			arg i;

			knobs[i].size.collect({
				arg j;

				knobs[i][j].size.collect({
					arg k;

					NumberBox()
					.value_(knobs[i][j][k].value)
					.align_(\center)
					.maxWidth_(screenB.width/48)
					.action_({knobs[i][j][k].value_(knobValues[i][j][k].value)})
				})
			})
		});

		var knobLabels = knobs.size.collect({
			arg i;

			knobs[i].size.collect({
				arg j;
				var string = [["thresh","midFreq","midGain","midQ",],["loFreq","loGain","hiFreq","hiGain"]];

				knobs[i][j].size.collect({
					arg k;

					StaticText()
					.string_(string[j][k])
					.stringColor_(textCol)
					.align_(\center)
					.font_(Font("Menlo", 10,false))
				})
			})
		});

		var sliders = Array.fill(2,{
			arg i;
			Slider()
			.maxWidth_(screenB.width/36)
			.action_({numBox[i].value_(sliders[i].value)})
			.background_(wineCol)
		});

		var numBox = Array.fill(2,{
			arg i;
			NumberBox()
			.maxWidth_(screenB.width/48)
			.step_(0.01)
			.scroll_step_(0.01)
			.action_({sliders[i].value_(numBox[i].value)})
			.align_(\center)
		});
		var levels = Array.fill(2,{
			LevelIndicator()
			.style_(\led)
			.value_(1)
			.stepWidth_(3)
			.background_(wineCol)
			.maxWidth_(screenB.width/48)
		});

		var knobChannel = {Array.fill(2,{VLayout()})}!2;
		knobs.size.do({
			arg i;

			knobs[i].size.do({
				arg j;

				knobs[i][j].size.do({
					arg k;

					knobChannel[i][j].add(knobLabels[i][j][k], align: \bottom);
					knobChannel[i][j].add(
						VLayout(
							knobs[i][j][k],
							knobValues[i][j][k],
						),
						align: \center);
				})
			})
		});

		HLayout(
			knobChannel[0][0]
			.spacing_(0),
			knobChannel[0][1]
			.spacing_(0),
			VLayout(
				sliders[0],
				numBox[0],
			),
			levels[0],
			knobChannel[1][0]
			.spacing_(0),
			knobChannel[1][1]
			.spacing_(0),
			VLayout(
				sliders[1],
				numBox[1],
			).margins_(2),
			levels[1],
		)
		.spacing_(2)
		.margins_([2,2])
	});

	/*

	-make new ControlSpec for the EZsliders = be able to boost the signal a bit!
	-eventually make it so that inactive channels are grayed out?

	*/

	labels = 2.collect({
		arg alignIndex;
		4.collect({
			arg channelIndex;
			var align = [\left,\center];

			StaticText()
			.string_("channel %".format(channelIndex))
			.align_(align[alignIndex])
			.font_(Font("Menlo", 15,true))
			.stringColor_(textCol)
			.maxWidth_(screenB.width/10)
		})
	});

	lineSeparator = {VLayout()}!3;
	lineSeparator.size.do({
		arg i;

		24.do({
			arg j;

			lineSeparator[i].add(
				StaticText()
				.string_("|")
				.align_(\center)
				.font_(Font("Menlo", 10,true))
				.stringColor_(textCol),
				align: \center,
			)
		});
	});


	//make the window!
	monomeW.background_(wineCol);
	monomeW.layout_(
		VLayout(
			StaticText()
			.string_("MONOME")
			.align_(\center)
			.font_(Font("Menlo", 20,true))
			.stringColor_(textCol),
			labels[0][0],
			monomeView[0],
			labels[0][1],
			monomeView[1],
			labels[0][2],
			monomeView[2],
			labels[0][3],
			monomeView[3],
			HLayout(
				labels[1][0],
				labels[1][1],
				labels[1][2],
				labels[1][3],
			)
			.margins_([2,2]),
			HLayout(
				mixerView[0],
				lineSeparator[0],
				mixerView[1],
				lineSeparator[1],
				mixerView[2],
				lineSeparator[2],
				mixerView[3],
			)
			.margins_([2,0])
		)
		.spacing_(2)
		.margins_(4,2)
	);

	monomeW.front;

	monomeW.onClose({
		Ndef.all.clear;
		OSCdef.freeAll;
		s.freeAll;
	})
});

~mainW.value;

)

// if Ndef(\inPlayerWHATEVER).isPlaying, the GUI controls do Ndef(\inPlayerWHATEVER).set
// otherwise they change the values in the Monome_PlayersNEW file
