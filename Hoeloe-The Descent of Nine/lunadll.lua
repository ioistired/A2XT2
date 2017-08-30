local cps = API.load("checkpoints");
local eventu = API.load("eventu");
local pnpc = API.load("pnpc");
local rng = API.load("rng");
local textblox = API.load("textblox");

local font = textblox.Font (textblox.FONTTYPE_SPRITE, {ini = "font.ini", image = Graphics.loadImage("font.png")})
local pr_sign =    {
			scaleMode = textblox.SCALE_AUTO, 
			startSound = "sound\\message.ogg",
			closeSound = "sound\\zelda-fairy.ogg",  --zelda-dash, zelda-stab, zelda-fairy
			width = 250,
			height = 150,
			autosizeRatio = 1/10,
			bind = textblox.BIND_SCREEN,
			font = font,
			instant = true,
			autoTime = false, 
			pauseGame = true, 
			inputClose = true,
			inputProgress = true,
			stayOnscreen = true,
			showNextIcon = false,
			
			textScale=0.5;
			textOffY=8;
			speed=0;
			
			boxAnchorX = textblox.HALIGN_MID, 
			boxAnchorY = textblox.VALIGN_MID, 
			textAnchorX = textblox.HALIGN_TOP, 
			textAnchorY = textblox.VALIGN_TOP,
			boxColor = 0xFFFFFFFF,--0x264269FF,
			boxTex = Graphics.loadImage("text_fill.png"),
			textColor = 0x000000FF,
			borderTable =  
							{	thick = 16, 
								col = 0xFFFFFFFF,
								ulImg   = Graphics.loadImage("text_ul.png"),
		                        uImg    = Graphics.loadImage("text_uc.png"),
		                        urImg   = Graphics.loadImage("text_ur.png"),
		                        rImg    = Graphics.loadImage("text_cr.png"),
		                        drImg   = Graphics.loadImage("text_br.png"),
		                        dImg    = Graphics.loadImage("text_bc.png"),
		                        dlImg   = Graphics.loadImage("text_bl.png"),
		                        lImg    = Graphics.loadImage("text_cl.png")
							
							},
			xMargin = 8,
			yMargin = 16
					   }
					   
textblox.npcPresets[151] = 99;
 textblox.presetProps[99] = pr_sign;


local checkpoints = {};
checkpoints[1] = cps.create{x = -200064, y = -200384, section = 0, actions = function() triggerEvent("Luna 1") end};
checkpoints[2] = cps.create{x = -200064, y = -200384, section = 0, actions = function() triggerEvent("Luna 2") end};
checkpoints[3] = cps.create{x = -200064, y = -200384, section = 0, actions = function() triggerEvent("Luna 2") triggerEvent("Luna 3") end};
checkpoints[4] = cps.create{x = -79872, y = -80224, section = 6, actions = function() triggerEvent("Luna 2") triggerEvent("Luna 3") triggerEvent("Luna 4") end};
checkpoints[5] = cps.create{x = -79872, y = -80224, section = 6, actions = function() triggerEvent("Luna 2") triggerEvent("Luna 3") triggerEvent("Luna 5") end};
checkpoints[6] = cps.create{x = -79872, y = -80224, section = 6, actions = function() triggerEvent("Luna 2") triggerEvent("Luna 3") triggerEvent("Luna 5") triggerEvent("Luna 6") end};
checkpoints[7] = cps.create{x = -79872, y = -80224, section = 6, actions = function() triggerEvent("Luna 2") triggerEvent("Luna 3") triggerEvent("Luna 5") triggerEvent("Luna 7") end};

local fakeLeekTimer = 0;

local heresyLift = Layer(18);
local heresyLiftTimer;
local heresyEventTimer;
local heresySaw1;
local heresySaw2;
local heresySaw3;

local fraudPlatform1 = Layer(29);
local fraudPlatform1Accel = true;

function onLoadSection3()
	checkpoints[1]:collect();
end

function onLoadSection4()
	checkpoints[2]:collect();
end

function onLoadSection5()
	checkpoints[3]:collect();
end

function onLoadSection7()
	checkpoints[4]:collect();
end

function onLoadSection8()
	checkpoints[5]:collect();
end

function onLoadSection15()
	checkpoints[6]:collect();
end

function onLoadSection17()
	checkpoints[7]:collect();
end

local function resumeTimer(t)
	if(t ~= nil) then eventu.resumeTimer(t) end
end

local function pauseTimer(t)
	if(t ~= nil) then eventu.pauseTimer(t) end
end

function onLoop()
		if(player:mem(0x122,FIELD_WORD) == 0 or player:mem(0x122,FIELD_WORD) == 7 or player:mem(0x122,FIELD_WORD) == 500) then
			resumeTimer(heresyLiftTimer);
			resumeTimer(heresyEventTimer);
		else			
			pauseTimer(heresyLiftTimer);
			pauseTimer(heresyEventTimer);
		end
		if(player.section == 15) then
			if(player:mem(0x122,FIELD_WORD) == 0 or player:mem(0x122,FIELD_WORD) == 7 or player:mem(0x122,FIELD_WORD) == 500) then
				if(fraudPlatform1Accel) then
					fraudPlatform1.speedX = fraudPlatform1.speedX - 0.01;
					if(fraudPlatform1.speedX <= -2) then
						fraudPlatform1Accel = false;
					end
				else
					fraudPlatform1.speedX = fraudPlatform1.speedX + 0.01;
					if(fraudPlatform1.speedX >= 2) then
						fraudPlatform1Accel = true;
					end
				end
			end
		end
		
		for _,v in ipairs(NPC.get(258,-1)) do
			if(player.section == v:mem(0x146, FIELD_WORD)) then
				v.speedY = 1*math.cos(fakeLeekTimer*0.05);
				fakeLeekTimer = fakeLeekTimer + 1;
				if(rng.randomInt(5) == 0) then
					Animation.spawn(80,v.x + rng.random(-10,42), v.y + rng.random(32));
				end
			end
		end
end

--To anyone looking at this, don't use this as an example of eventu, this code is ew.
function onEvent(event)
	if(event == "Heresy Lift Start") then
		heresyLift.speedY = 1;
		heresyLiftTimer = eventu.setFrameTimer(96*(32/heresyLift.speedY), function() heresyLift.speedY = 0; end);
		heresyEventTimer = eventu.setFrameTimer(25*(32/heresyLift.speedY), 
			function() 
				heresySaw1 = pnpc.wrap(NPC.spawn(179, -59552, -59456, 7));
				heresyEventTimer = eventu.setFrameTimer(11*(32/heresyLift.speedY), 
					function() 
						heresySaw1:kill();
						heresyEventTimer = eventu.setFrameTimer(39*(32/heresyLift.speedY), 
									function() 
										heresySaw1 = pnpc.wrap(NPC.spawn(179, -59760, -57840, 7));
										heresyEventTimer = eventu.setFrameTimer(5*(32/heresyLift.speedY), 
										function() 
											heresySaw2 = pnpc.wrap(NPC.spawn(179, -59680, -57680, 7));
											heresyEventTimer = eventu.setFrameTimer(4*(32/heresyLift.speedY), 
											function() 
												heresySaw3 = pnpc.wrap(NPC.spawn(179, -59520, -57568, 7));
												heresyEventTimer = eventu.setFrameTimer(2*(32/heresyLift.speedY), 
												function() 
													heresySaw1:kill()
													heresyEventTimer = eventu.setFrameTimer(5*(32/heresyLift.speedY), 
													function() 
														heresySaw2:kill()
														heresyEventTimer = eventu.setFrameTimer(4*(32/heresyLift.speedY), 
														function() 
															heresySaw3:kill()
														end);
													end);
												end);
											end);
										end);
										--heresySaw3 = pnpc.wrap(NPC.spawn(179, -59456, -57792, 7));
										--heresyEventTimer = eventu.setFrameTimer(11*(32/heresyLift.speedY), function() heresySaw1:kill() heresySaw2:kill() heresySaw3:kill() end);
									end);						
					end);
			end);
	end
end