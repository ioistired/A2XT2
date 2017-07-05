_G["GLOBAL_DEMOS"] = 0;

local settings = API.load("a2xt_settings");

local dc = {};

function dc.onInitAPI()
	registerEvent(dc, "onStart", "onStart", false);
	registerEvent(dc, "onExitLevel", "onExitLevel", false);
end

function dc.onStart()
		if(not isOverworld) then
			if (settings.Settings:get(Level.filename() .. "-deaths") == nil) then
					settings.Settings:set(Level.filename() .. "-deaths", 0)
			end
		end
		
		if (settings.Settings:get("totalDeaths") == nil) then
				settings.Settings:set("totalDeaths", 0)
		end	
		
		GLOBAL_DEMOS = settings.Settings:get("totalDeaths");
		
        settings.Settings:save()
end

function dc.GetDemos(level)
	return tonumber(settings.Settings:get(level .. ".lvl-deaths")) or 0;
end

function dc.onExitLevel()
		if(not isOverworld) then
			if player:mem(0x13C, FIELD_BOOL) then
					settings.Settings:set(Level.filename() .. "-deaths", settings.Settings:get(Level.filename() .. "-deaths") + 1)
					settings.Settings:set("totalDeaths", settings.Settings:get("totalDeaths") + 1)
					settings.Settings:save()
			end
		end
end

return dc;