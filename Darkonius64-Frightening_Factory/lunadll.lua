local multipoints = loadSharedAPI("multipoints") 

checkpoint1 = multipoints.addLuaCheckpoint(-995868, -100960, 5);
checkpoint2 = multipoints.addLuaCheckpoint(-995868, -100960, 5,nil,nil,cutscene);
checkpoint2.visible = false

function onEvent(eventname)
	if(eventname == "wake up!") then 
		checkpoint2.collect()
	end
end

function onLoadSection4()
	if (checkpoint2.collected == true) then
		triggerEvent("start")
	end
end

function onStart()
	if (player.isValid) then
		if(player.character ~= CHARACTER_MARIO and player.character ~= CHARACTER_LUIGI) then
			player.character = CHARACTER_LUIGI
		end
	end
end