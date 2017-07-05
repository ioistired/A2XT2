local rng = loadSharedAPI("rng")
local multipoints = loadSharedAPI("multipoints")
local particles = loadSharedAPI("particles");

local snow = particles.Emitter(0, 0, Misc.resolveFile("particles/p_snow.ini"), 1)
snow:AttachToCamera(Camera.get()[1]);

multipoints.addLuaCheckpoint(-139360, -140288, 3);
multipoints.addLuaCheckpoint(-59808, -60160, 7);

function returnBgoCollision()
	for _, b in pairs(BGO.getIntersecting(player.x + 12, player.y + 12, player.x + player.width - 12, player.y + player.height - 12)) do
		if b.id == 79 then
			return true;
		end
	end
end

function onLoop()
	for k,v in pairs(NPC.get(27,-1)) do
		if player.x < v.x then
			v.speedX = -2;
		else
			v.speedX = 2;
		end
	end
	for k,v in pairs(NPC.get(155,-1)) do
		if player.x < v.x then
			v.speedX = -6;
		else
			v.speedX = 6;
		end
	end
	
	for k,v in pairs(NPC.get(152,-1)) do
		if v.speedX == 0 then
			v.speedX = rng.randomInt(-3,3)
		end
	end
	
	for k,v in pairs(NPC.get(2,-1)) do
		v:mem(0x12A,FIELD_WORD,180)
	end
	
	for k,v in pairs(NPC.get(268,-1)) do
		v:kill()
	end
end

function onEvent(eventname)
	local check = returnBgoCollision()
	if eventname == "flash" and check ~= true then
		player:harm()
	end
end

function onLoadSection1()
	snow.enabled = false;
	snow:KillParticles();
end

function onLoadSection2()
	snow.enabled = false;
	snow:KillParticles();
end

function onLoadSection3()
	snow.enabled = true;
end

function onLoadSection4()	
	snow.enabled = false;
	snow:KillParticles();
end

function onLoadSection5()
	snow.enabled = true;
end

function onLoadSection7()
	triggerEvent("flash warning")
	snow.enabled = false;
	snow:KillParticles();
end

function onCameraUpdate()
	snow:Draw();
end