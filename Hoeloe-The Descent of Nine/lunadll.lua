local multipoints = API.load("multipoints");
local eventu = API.load("eventu");
local pnpc = API.load("pnpc");
local rng = API.load("rng");


local checkpoints = {};
checkpoints[1] = multipoints.addLuaCheckpoint(-200064,-200384,0,-200064,-200384,function() triggerEvent("Luna 1") end);
checkpoints[2] = multipoints.addLuaCheckpoint(-200064,-200384,0,-200064,-200384,function() triggerEvent("Luna 2") end);
checkpoints[3] = multipoints.addLuaCheckpoint(-200064,-200384,0,-200064,-200384,function() triggerEvent("Luna 2") triggerEvent("Luna 3") end);
checkpoints[4] = multipoints.addLuaCheckpoint(20608,19712,11);
checkpoints[5] = multipoints.addLuaCheckpoint(-79872,-80224,6,-79872,-80224,function() triggerEvent("Luna 4") end);
checkpoints[6] = multipoints.addLuaCheckpoint(-79872,-80224,6,-79872,-80224,function() triggerEvent("Luna 5") end);
checkpoints[7] = multipoints.addLuaCheckpoint(-79872,-80224,6,-79872,-80224,function() triggerEvent("Luna 6") triggerEvent("Luna 5") end);
checkpoints[8] = multipoints.addLuaCheckpoint(140160,139808,17);

local fakeLeekTimer = 0;

local heresyLift = Layer(18);
local heresyLiftTimer;
local heresyEventTimer;
local heresySaw1;
local heresySaw2;
local heresySaw3;

local fraudPlatform1 = Layer(29);
local fraudPlatform1Accel = true;

for k,v in ipairs(checkpoints) do
	if(k ~= 4) then
		v.visible = false;
		v.silent = true;
		v.power = 0;
	end
end

function onLoadSection3()
	checkpoints[1].collect();
end

function onLoadSection4()
	checkpoints[2].collect();
end

function onLoadSection5()
	checkpoints[3].collect();
end

function onLoadSection7()
	checkpoints[5].collect();
end

function onLoadSection8()
	checkpoints[6].collect();
end

function onLoadSection15()
	checkpoints[7].collect();
end

function onLoadSection17()
	checkpoints[8].collect();
end

function multipoints.onLevelStart()
	--Remove this if and when lives don't give game overs
	NPC.spawn(187,player.x,player.y,player.section)
	if(player.character == CHARACTER_PEACH or player.character == CHARACTER_LINK) then
		player.character = CHARACTER_MARIO;
	end
	
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