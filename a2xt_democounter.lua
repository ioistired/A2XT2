_G["GLOBAL_DEMOS"] = 0;

local settings = API.load("a2xt_settings");

local dc = {};

function dc.onInitAPI()
	registerEvent(dc, "onStart", "onStart", false);
	registerEvent(dc, "onExitLevel", "onExitLevel", true);
	
	if(SaveData.deaths == nil) then
		SaveData.deaths = {};
	end
		
	if(SaveData.deaths._TOTAL == nil) then
		SaveData.deaths._TOTAL = 0;
	end
end

function dc.onStart()
		if(not isOverworld and SaveData.deaths[Level.filename()] == nil) then
			SaveData.deaths[Level.filename()] = 0;
		end
		
		_G.GLOBAL_DEMOS = SaveData.deaths._TOTAL;
end

function dc.GetDemos(level)
	return SaveData.deaths[level..".lvl"] or 0;
end

function dc.onExitLevel()
		if(not isOverworld) then
			if player:mem(0x13C, FIELD_BOOL) then
					SaveData.deaths[Level.filename()] = SaveData.deaths[Level.filename()]+1;
					SaveData.deaths._TOTAL = SaveData.deaths._TOTAL + 1;
			end
		end
end

return dc;