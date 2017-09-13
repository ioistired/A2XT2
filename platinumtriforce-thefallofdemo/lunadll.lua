
function onStart()
	_G["ManualTitle"] = "Bonus Stage 1"
	_G["ManualArtist"] = "Toshiaki Sakoda"
	_G["ManualAlbum"] = "Alien Crush"
	if (player.isValid) then
			player.character = CHARACTER_MARIO

	end
end

local timer = 0
local sounded = false
function onLoop()

	for  k,v in pairs(NPC.get(37, -1))  do
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