local particles = API.load("particles");

local sand = particles.Emitter(0,0,Misc.resolveFile("p_sandstorm.ini"),1)
sand:AttachToCamera(camera);

function onTick()
	for _,v in ipairs(NPC.get{171,266,291}) do
		v.id = 48;
	end
	
	for _,v in ipairs(NPC.get(199)) do
		
		if(v.speedY < 0 and v.y + v.speedY <= -200030 - v.height) then
			v.y = -200030 - v.height
		end
	end
	
	if(player.x > -183296) then
		sand.enabled = false;
	end
end

function onDraw()
	if(player.section == 0) then
		sand:Draw(-80);
	end
end

function onCameraDraw()
	for _,v in ipairs(Block.get{162,163,164}) do
		Graphics.drawImageToSceneWP(Graphics.sprites.block[v.id].img, v.x, v.y, -1)
	end
end