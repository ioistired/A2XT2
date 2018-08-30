local timer = 0
local sounded = false
function onTick()

	for  k,v in ipairs(NPC.get(37, -1))  do
		Cam = Camera.get()
		if ((Cam[1].x < v.x + 800 and (Cam[1].x + 800) > v.x)) and (Cam[1].y < v.y + 600 and (Cam[1].y + 600 > v.y)) then
		--v.underwater = false
	--Text.print(v.speedY,100,100)
	--Text.print(v.underwater,200,100)
			if (v.ai1 == 0) then
				--v.ai1 = 1;
				if (timer == 8) then
					v.ai1 = 1
					--v.ai2 = 98;
					timer = 0
				else
					timer = timer + 1
					v.ai1 = 0
				end
				if (v.ai2 < 75) then
					v.ai2 = 92;
					timer = 0
				end
			end
			if (v.ai1 == 3) then
				--v.speedY = v.speedY * 1.13
				v.speedY = -4.5
				sounded = false
			end
	
			if (v.ai1 == 1) then
				--v.speedY = v.speedY * 1.06
				v.speedY = 4.5
				sounded = false
			end

			if (v.ai1 == 0 and sounded == false) then
				playSFX(37)
				sounded = true
			end

			if (v.ai1 == 2 and sounded == false) then
				playSFX(37)
				sounded = true
			end
		end

	end
end
local bosstimer = 0
local cantimer = 0
local bossY = -80240
thunder = {}
helium = {}
function onLoopSection6()

bosstimer = bosstimer + 1
cantimer = cantimer + 1
	if (cantimer == 650) then
		cantimer = 0
		if (player.x <= -79600) then
			helium.npc = NPC.spawn(239, -79232, -80512, 6)
			helium.pal = NPC.spawn(158, -79200, -80528, 6)
			helium.pal.direction = DIR_LEFT
		else
			helium.npc = NPC.spawn(239, -80000, -80512, 6)
			helium.pal = NPC.spawn(158, -80032, -80528, 6)
			helium.pal.direction = DIR_RIGHT
		end
			helium.npc.deathEventName = "HitBoss"
	end

	for  k,v in ipairs(NPC.get(284, -1))  do
		if (v.x <= -79936) then
			v.x = -79936
		end
		if (v.x >= -79296) then
			v.x = -79296
		end
		v.y = v.y - 1
		if (v.y < bossY) then
			v.y = bossY
		end
		if (v.y <= -80544) then
			v:kill()
		end
		if (bosstimer == 130) then
			thunder.npc = NPC.spawn(269, v.x, v.y, 6)
			playSFX(34)
			thunder.npc.speedY = 3.5
			bosstimer = 0
		end

	end
	for  k,v in ipairs(NPC.get(269, -1))  do
		--Text.print(Defines.jumpheight, 100, 100)
		--Text.print(player.y, 200, 200)
		if (v.y >= player.y) then
			if (v.speedY == 3.5 and v.x > player.x + 32) then
				v.speedY = 0
				v.speedX = -5.5
			end
			if (v.speedY == 3.5 and v.x < player.x + 32) then
				v.speedY = 0
				v.speedX = 5.5
			end
		end
	end

	for  k,v in ipairs(NPC.get(210, -1))  do
		if (v.ai1 == 0) then
			v.speedY = -0.5
		end
	end

	for k, v in ipairs(NPC.get(239, 6)) do
		if (v.x >= -79296) then
			v.speedX = -2
		end
		if (v.x <= -79936) then
			v.speedX = 2
		end
	end
end

local setgravity = Defines.gravity
local setjump = Defines.jumpheight

function onEvent(eventname)
	if(eventname == "HitBoss") then
		bossY = bossY - 64
		setjump = setjump + 10
		setgravity = setgravity - 2
		Defines.gravity = setgravity
		Defines.jumpheight = setjump
	end
	if(eventname == "End") then
		cantimer = 999
	end
end