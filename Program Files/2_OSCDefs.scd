///////////////////////////////////////////////////////MONOME OSCDefs//////////////////////////////////////////////////////////////////////

(
OSCdef(\mapper, {arg msg, time, addr, port;
	var col = msg[1];
	var row = msg[2];
	var value = msg[3];

	var channelIndex = (row / 3).floor.asInteger;

	if(value.asBoolean,{

		if(channelIndex <= 3, {
			var channelRowIndex;
			var channelColIndex;
			var intensity = if(~control[channelIndex]["levels"].sum == 0,{0},{[1,2,3,0][~control[channelIndex]["levels"].indexOf(1)]});

			channelRowIndex = row % 3;

			case
			{col == 0}{

				case
				{channelRowIndex == 0}{

					/*--------------------------------------------------------------------*/
					/*****************************inPlayer*********************************/
					/*--------------------------------------------------------------------*/

					case
					{~control[channelIndex]["keysHeld"][0..1] == [0,0]}{

						case
						{~control[channelIndex]["levels"].sum == 0}{"Choose level!".warn}
						{intensity == 0}{~channels[channelIndex]["io"][channelRowIndex][0].value;"intense".postln}
						{intensity == 1}{~channels[channelIndex]["io"][channelRowIndex][1].value}
						{intensity == 2}{~channels[channelIndex]["io"][channelRowIndex][2].value}
						{intensity == 3}{~channels[channelIndex]["io"][channelRowIndex][3].value};
					}
					{~control[channelIndex]["keysHeld"] == [0,1,0]}{~channels[channelIndex]["io"][channelRowIndex][4].value} // mod
					{~control[channelIndex]["keysHeld"] == [0,1,1]}{~channels[channelIndex]["io"][channelRowIndex][5].value} // t_trig
					{~control[channelIndex]["keysHeld"] == [0,1,1]}{~channels[channelIndex]["io"][channelRowIndex][6].value}; // volume

					~monome.levset(col,row,intensity * 4);
				}

				{channelRowIndex == 1}{

					/*--------------------------------------------------------------------*/
					/****************************outPlayer*********************************/
					/*--------------------------------------------------------------------*/

					case
					{~control[channelIndex]["keysHeld"][0..1] == [0,0]}{

						case
						{~control[channelIndex]["levels"].sum == 0}{"Choose level!".warn}
						{intensity == 0}{~channels[channelIndex]["io"][channelRowIndex][0].value}
						{intensity == 1}{~channels[channelIndex]["io"][channelRowIndex][1].value}
						{intensity == 2}{~channels[channelIndex]["io"][channelRowIndex][2].value}
						{intensity == 3}{~channels[channelIndex]["io"][channelRowIndex][3].value};

					}
					{~control[channelIndex]["keysHeld"] == [0,1,0]}{~channels[channelIndex]["io"][channelRowIndex][4].value} // mod
					{~control[channelIndex]["keysHeld"] == [0,1,1]}{~channels[channelIndex]["io"][channelRowIndex][5].value} // t_trig
					{~control[channelIndex]["keysHeld"] == [0,1,1]}{~channels[channelIndex]["io"][channelRowIndex][6].value}; // volume

					~monome.levset(col,row,intensity * 4);
				}

				{channelRowIndex == 2}{

					/*--------------------------------------------------------------------*/
					/*****************************analyser*********************************/
					/*--------------------------------------------------------------------*/

					"something something analysis module".postln;
				}
			}

			/*--------------------------------------------------------------------*/
			/****************************transforms********************************/
			/*--------------------------------------------------------------------*/

			{col >= 1 and: {col <= 10}}{

				channelColIndex = col - 1;

				case
				{~control[channelIndex]["keysHeld"][0..1] == [0,0]}{

					case
					{~control[channelIndex]["levels"].sum == 0}{"Choose level!".warn}
					{intensity == 0}{~channels[channelIndex]["transforms"][channelRowIndex][channelColIndex][0].value}
					{intensity == 1}{~channels[channelIndex]["transforms"][channelRowIndex][channelColIndex][1].value}
					{intensity == 2}{~channels[channelIndex]["transforms"][channelRowIndex][channelColIndex][2].value}
					{intensity == 3}{~channels[channelIndex]["transforms"][channelRowIndex][channelColIndex][3].value};
				}
				{~control[channelIndex]["keysHeld"] == [0,1,0]}{~channels[channelIndex]["transforms"][channelRowIndex][channelColIndex][4].value} // mod
				{~control[channelIndex]["keysHeld"] == [1,1,0]}{~channels[channelIndex]["transforms"][channelRowIndex][channelColIndex][5].value} // t_trig
				{~control[channelIndex]["keysHeld"] == [0,1,1]}{~channels[channelIndex]["transforms"][channelRowIndex][channelColIndex][6].value}; // volume

				~monome.levset(col,row,intensity * 4);
			}

			/*--------------------------------------------------------------------*/
			/*****************************recorders********************************/
			/*--------------------------------------------------------------------*/

			{col == 11}{

				case
				{~control[channelIndex]["levels"].sum == 0}{"Choose level!".warn}
				{intensity == 0}{

					if(~control[channelIndex]["buffer"][channelRowIndex] == 0,{
						"buffer already free".postln;
					},{
						~channels[channelIndex]["recorders"][channelRowIndex][0].value;
						~control[channelIndex]["buffer"][channelRowIndex] = 0;
						~monome.levset(col,row,0)
					});
				}
				{intensity > 0}{

					if(~control[channelIndex]["buffer"][channelRowIndex] == 1,{
						"free buffer first!!".postln;
					},{
						~channels[channelIndex]["recorders"][channelRowIndex][1].value;
						~control[channelIndex]["buffer"][channelRowIndex] = 1;
						{
							12.do({
								~monome.levset(col,row,0);
								0.5.wait;
								~monome.levset(col,row,12);
								0.5.wait
							})
						}.fork
					});
				};
			}

			/*--------------------------------------------------------------------*/
			/***************************bufTransforms******************************/
			/*--------------------------------------------------------------------*/

			{col > 11}{

				channelColIndex = col - 12;

				case
				{~control[channelIndex]["keysHeld"][0..1] == [0,0]}{

					case
					{~control[channelIndex]["levels"].sum == 0}{"Choose level!".warn}
					{intensity == 0}{~channels[channelIndex]["bufTransforms"][channelRowIndex][channelColIndex][0].value}
					{intensity == 1}{~channels[channelIndex]["bufTransforms"][channelRowIndex][channelColIndex][1].value}
					{intensity == 2}{~channels[channelIndex]["bufTransforms"][channelRowIndex][channelColIndex][2].value}
					{intensity == 3}{~channels[channelIndex]["bufTransforms"][channelRowIndex][channelColIndex][3].value};
				}
				{~control[channelIndex]["keysHeld"] == [0,1,0]}{~channels[channelIndex]["bufTransforms"][channelRowIndex][channelColIndex][4].value} // mod
				{~control[channelIndex]["keysHeld"] == [1,1,0]}{~channels[channelIndex]["bufTransforms"][channelRowIndex][channelColIndex][5].value} // t_trig
				{~control[channelIndex]["keysHeld"] == [0,1,1]}{~channels[channelIndex]["bufTransforms"][channelRowIndex][channelColIndex][6].value}; // volume

				~monome.levset(col,row,intensity * 4);
			};
		},

		/*--------------------------------------------------------------------*/
		/**************************control section*****************************/
		/*--------------------------------------------------------------------*/

		{
			var controlIndex = (col / 4).floor.asInteger;
			var channelColIndex = col % 4;
			var channelRowIndex = row - 12;
			var intensity = if(~control[controlIndex]["levels"].sum == 0,{0},{[1,2,3,0][~control[controlIndex]["levels"].indexOf(1)]});

			case
			{channelColIndex == 0}{

				case
				{~control[controlIndex]["levels"].sum == 0}{~control[controlIndex]["levels"][channelRowIndex] = 1}
				{~control[controlIndex]["levels"].sum == 1}{
					~control[controlIndex]["levels"][(~control[controlIndex]["levels"].indexOf(1))] = 0;
					~control[controlIndex]["levels"][channelRowIndex] = 1;
				};

				4.do({arg i; ~monome.levset(controlIndex * 4, 12 + i,(~control[controlIndex]["levels"][i] * 15))}); // set each led

			}
			{channelColIndex == 1}{

				case
				{channelRowIndex == 0}{

					case
					{~control[controlIndex]["cleared"] == 0}{
						var currentTapTime = Main.elapsedTime;
						var bps = currentTapTime - ~control[controlIndex]["previousDustTime"];

						if(bps < 4.0, {
							"dust Freq: %".format(bps.reciprocal).postln;
							~control[controlIndex]["dustTrig"] = (bps.reciprocal).explin(0.25,10.0,0.0,1.0);
							Tdef(("dustTrig" ++ controlIndex).asSymbol,{
								inf.do({
									~monome.levset((controlIndex * 4) + 1,channelRowIndex + 12,15);
									(bps/2).wait;
									~monome.levset((controlIndex * 4) + 1,channelRowIndex + 12,0);
									(bps/2).wait;
								})
							}).play;
						});
						~control[controlIndex]["previousDustTime"] = currentTapTime;
					}
					{~control[controlIndex]["cleared"] == 1}{
						~control[controlIndex]["dustTrig"] = 0;
						Tdef(("dustTrig" ++ controlIndex).asSymbol).stop;
						~monome.levset((controlIndex * 4) + 1,channelRowIndex + 12,0);
						"dustTrig cleared".postln;
					}
				}
				{channelRowIndex == 1}{

					case
					{~control[controlIndex]["cleared"] == 0}{
						var currentTapTime = Main.elapsedTime;
						var bps = currentTapTime - ~control[controlIndex]["previousImpulseTime"];

						if(bps < 4.0, {
							"impulse Freq: %".format(bps.reciprocal).postln;
							~control[controlIndex]["impulseTrig"] = (bps.reciprocal).explin(0.25,10.0,0.0,1.0);
							Tdef(("impulseTrig" ++ controlIndex).asSymbol,{
								inf.do({
									~monome.levset((controlIndex * 4) + 1,channelRowIndex + 12,15);
									(bps/2).wait;
									~monome.levset((controlIndex * 4) + 1,channelRowIndex + 12,0);
									(bps/2).wait;
								})
							}).play;
						});
						~control[controlIndex]["previousImpulseTime"] = currentTapTime;
					}
					{~control[controlIndex]["cleared"] == 1}{
						~control[controlIndex]["impulseTrig"] = 0;
						Tdef(("impulseTrig" ++ controlIndex).asSymbol).stop;
						~monome.levset((controlIndex * 4) + 1,channelRowIndex + 12,0);
						"impulseTrig cleared".postln;
					}
				}
				{channelRowIndex == 2}{

					case
					{~control[controlIndex]["cleared"] == 0}{~control[controlIndex]["cleared"] = 1; "clear".postln; ~monome.levset(col,row,12)}
					{~control[controlIndex]["cleared"] == 1}{~control[controlIndex]["cleared"] = 0; ~monome.levset(col,row,0)};
				}
				{channelRowIndex == 3}{
					if(~control[controlIndex]["keysHeld"][1] == 1,{
						~control[controlIndex]["keysHeld"][0] = value;
						~monome.levset(col,row,value*15);
						"t_trig".postln;
					})
				}
			}
			{channelColIndex == 2}{

				case
				{channelRowIndex == 0}{

					case
					{~control[controlIndex]["levels"].sum == 0}{"Choose level!".warn}
					{intensity == 0}{~control[controlIndex]["fadeTime"] = 0.08; ~monome.levset(col,row,0); "No fadeTime".postln}
					{intensity == 1}{~control[controlIndex]["fadeTime"] = 2; ~monome.levset(col,row,4); "Short fadeTime".postln}
					{intensity == 2}{~control[controlIndex]["fadeTime"] = 4; ~monome.levset(col,row,8); "Medium fadeTime".postln}
					{intensity == 3}{~control[controlIndex]["fadeTime"] = 10; ~monome.levset(col,row,12); "Long fadeTime".postln};

				}
				{channelRowIndex == 1}{

					case
					{~control[controlIndex]["sqrt"] == false}{~control[controlIndex]["sqrt"] = true;~monome.levset(col,row,12);"sqrt".postln}
					{~control[controlIndex]["sqrt"] == true}{~control[controlIndex]["sqrt"] = false;~monome.levset(col,row,0)};

				}
				{channelRowIndex == 2}{

					case
					{~control[controlIndex]["squared"] == false}{~control[controlIndex]["squared"] = true; ~monome.levset(col,row,12); "squared".postln}
					{~control[controlIndex]["squared"] == true}{~control[controlIndex]["squared"] = false; ~monome.levset(col,row,0)};
				}
				{channelRowIndex == 3}{
					~control[controlIndex]["keysHeld"][1] = value;
					~monome.levset(col,row,value*15);
					"mod".postln;
				};
			}
			{channelColIndex == 3}{

				case
				{~control[controlIndex]["keysHeld"][1] == 0}{
					~control[controlIndex]["keysHeld"][2] = 0;
					if(intensity != 0,{

						case
						{channelRowIndex == 0}{~control[controlIndex]["volume"] = [intensity,3,3,3]}
						{channelRowIndex == 1}{~control[controlIndex]["volume"] = [0,intensity,3,3]}
						{channelRowIndex == 2}{~control[controlIndex]["volume"] = [0,0,intensity,3]}
						{channelRowIndex == 3}{~control[controlIndex]["volume"] = [0,0,0,intensity]}
					},{
						if(~control[controlIndex]["levels"].sum == 0,{
							"Choose level!".warn;
						},{
							if(intensity == 0,{
								~control[controlIndex]["volume"].fill(4,{0});
							})
						})
					});

					4.do({arg i; ~monome.levset((controlIndex*4)+3,12 + i,(~control[controlIndex]["volume"][i].value*4))});

				}
				{~control[controlIndex]["keysHeld"][1] == 1}{
					if(channelRowIndex == 3,{
						~control[controlIndex]["keysHeld"][2] = 1;
						"volume Mod".postln
					});
				};
			};
		});
	},{
		var controlIndex = (col / 4).floor.asInteger;
		var channelColIndex = col % 4;
		var channelRowIndex = row - 12;

		if(channelRowIndex == 3,{

			case
			{channelColIndex == 1}{
				~control[controlIndex]["keysHeld"][0] = value;
				~monome.levset(col,row,value*15);
			}
			{channelColIndex == 2}{
				~control[controlIndex]["keysHeld"][1] = value;
				~monome.levset(col,row,value*15);
			}
			{channelColIndex == 3}{
				if(~control[controlIndex]["keysHeld"][1] == 1,{
					~control[controlIndex]["keysHeld"][2] = 0;
				});
			}
		});
	});

}, '/monome/grid/key');

"OSCdefs Loaded".postln;
)