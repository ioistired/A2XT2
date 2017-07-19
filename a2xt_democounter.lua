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
		if(not isOverworld) then
			SaveData.deaths[Level.filename()] = 0;
			--[[if (settings.Settings:get(Level.filename() .. "-deaths") == nil) then
					settings.Settings:set(Level.filename() .. "-deaths", 0)
			end]]
		end
		--[[if (settings.Settings:get("totalDeaths") == nil) then
				settings.Settings:set("totalDeaths", 0)
		end]]
		
		GLOBAL_DEMOS = SaveData.deaths._TOTAL;--settings.Settings:get("totalDeaths");
		
        --settings.Settings:save()
end

function dc.GetDemos(level)
	return tonumber((SaveData.deaths[level..".lvl"]) or 0);--tonumber(settings.Settings:get(level .. ".lvl-deaths")) or 0;
end

function dc.onExitLevel()
		if(not isOverworld) then
			if player:mem(0x13C, FIELD_BOOL) then
					SaveData.deaths[Level.filename()] = SaveData.deaths[Level.filename()]+1;
					SaveData.deaths._TOTAL = SaveData.deaths._TOTAL + 1;
					--settings.Settings:set(Level.filename() .. "-deaths", settings.Settings:get(Level.filename() .. "-deaths") + 1)
					--settings.Settings:set("totalDeaths", settings.Settings:get("totalDeaths") + 1)
					--settings.Settings:save()
			end
		end
end

return dc;