local leveldata = API.load("a2xt_leveldata")

function onStart()	
	Misc.saveGame();
	player.powerup = 2;
end

local exitState = nil;

function onTick()
	if(player:mem(0x13E, FIELD_WORD) > 0) then
		exitState = false;
	elseif(Level.winState() > 0) then
		exitState = true;
	else
		exitState = nil;
	end
end

function onExitLevel()	
	if(SaveData.currentTutorial ~= nil)  then
		if(exitState == false) then
			leveldata.LoadLevel(Level.filename());
		elseif(exitState == true) then
			SaveData.currentTutorial = "Enjl-HideAndLeap.lvl";
			Misc.saveGame();
			leveldata.LoadLevel(SaveData.currentTutorial);
		end
	end
end