local rng = API.load("rng")
local particles = API.load("particles");

local snow = particles.Emitter(0, 0, Misc.resolveFile("particles/p_snow.ini"), 1)
snow:AttachToCamera(Camera.get()[1]);

function returnBgoCollision()
	for _, b in ipairs(BGO.getIntersecting(player.x + 12, player.y + 12, player.x + player.width - 12, player.y + player.height - 12)) do
		if b.id == 79 then
			return true;
		end
	end
end

function onTick()
	for k,v in ipairs(NPC.get(27,-1)) do
		if player.x < v.x then
			v.speedX = -2;
		else
			v.speedX = 2;
		end
	end
	for k,v in ipairs(NPC.get(155,-1)) do
		if player.x < v.x then
			v.speedX = -6;
		else
			v.speedX = 6;
		end
	end
	
	for k,v in ipairs(NPC.get(152,-1)) do
		if v.speedX == 0 then
			v.speedX = rng.randomInt(-3,3)
		end
	end
	
	for k,v in ipairs(NPC.get(2,-1)) do
		v:mem(0x12A,FIELD_WORD,180)
	end
	
	for k,v in ipairs(NPC.get(268,-1)) do
		v:kill()
	end
end

--TODO: use actual effect configs when they exist
function onDraw()
	for _,v in ipairs(Animation.get{85,86}) do
		v.width = 64;
		v.height = 32;
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

function onCameraDraw()
	snow:Draw();
end