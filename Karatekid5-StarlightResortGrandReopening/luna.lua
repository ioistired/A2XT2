function onTick()
	for k,v in pairs(NPC.get(30, player.section)) do
		if(v.speedY < -2) then
		v.speedY = -3
		end
	end   
end 

function onEvent(eventName)
   if (eventName =="First Detonator") then
		Audio.playSFX("katamari.ogg");
        Audio.MusicVolume(12)
	end
   if (eventName =="Second Detonator") then
		Audio.playSFX("katamari.ogg");
        Audio.MusicVolume(12)
	end
	if (eventName =="SwitchFailed") then
		Audio.MusicVolume(51)
	end
end
