local checkpoints = API.load("checkpoints") 

local checkpoint2 = checkpoints.create{x=-99568, y=-100964,section = 5};

function onEvent(eventname)
	if(eventname == "wake up!") then 
		checkpoint2:collect()
	end
end

function onLoadSection4()
	if (checkpoint2.collected) then
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