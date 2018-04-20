local timer = 0
local push = 0
local wind = Audio.newMix_Chunk()

function onLoadSection0()
	wind = Audio.SfxOpen("wind.ogg")	
	Audio.SfxPlayCh(17, wind, -1)
end
function onLoadSection2()
	wind = Audio.SfxOpen("wind.ogg")	
	Audio.SfxPlayCh(17, wind, -1)
end
function onLoadSection4()
	wind = Audio.SfxOpen("wind.ogg")	
	Audio.SfxPlayCh(17, wind, -1)
end



function onTick()
	--Text.print(timer,100,100)
	timer = timer + 1
	if (timer == 13)  then
		push = player:mem(0x138,FIELD_FLOAT)
		if (player.section == 0 or  player.section == 4) then	
			push = push - .5

		elseif (player.section == 2) then
			push  = push + .5
		else
			push = push
			Audio.SfxStop(17)
		end 
		player:mem(0x138,FIELD_FLOAT,push)
		timer = 0
	end
end
