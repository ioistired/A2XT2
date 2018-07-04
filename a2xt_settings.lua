GLOBAL_LIVES = 0;

CHARACTER_DEMO = CHARACTER_MARIO;
CHARACTER_IRIS = CHARACTER_LUIGI;
CHARACTER_KOOD = CHARACTER_PEACH;
CHARACTER_RAOCOW = CHARACTER_TOAD;
CHARACTER_SHEATH = CHARACTER_LINK;

CHARACTER_NAME = {
                    [CHARACTER_MARIO] = "Demo",
                    [CHARACTER_LUIGI] = "Iris",
                    [CHARACTER_PEACH] = "Kood",
                    [CHARACTER_TOAD]  = "Raocow",
                    [CHARACTER_LINK]  = "Sheath"
                  }

CHARACTER_CONSTANT = {
                        mario=CHARACTER_MARIO,
                        luigi=CHARACTER_LUIGI,
                        peach=CHARACTER_PEACH,
                        toad=CHARACTER_TOAD,
                        link=CHARACTER_LINK,

                        demo=CHARACTER_MARIO,
                        iris=CHARACTER_LUIGI,
                        kood=CHARACTER_PEACH,
                        raocow=CHARACTER_TOAD,
                        sheath=CHARACTER_LINK
                      }

EMOTE = {
         VICTORY = 1,
         ANGER = 2,
         SHOCK = 3,
         SAD = 4,
         HAPPY = 5,
         NOTAMUSED = 6,
         CONFUSED = 7
        }


local textblox = loadSharedAPI("textblox")
local pm = API.load("playerManager");
pm.overworldCharacters = {CHARACTER_DEMO,CHARACTER_IRIS,CHARACTER_RAOCOW,CHARACTER_KOOD,CHARACTER_SHEATH};

GENERIC_FONT = textblox.FONT_SPRITEDEFAULT4X2;

local settings = {};
 
 
local EP_LIST_PTR = mem(0x00B250FC, FIELD_DWORD)
local currentEpisodeIndex = mem(0x00B2C628, FIELD_WORD)

local savfil = "save"..tostring(mem(0x00B2C62A, FIELD_WORD))..".sav";
local episodePath = tostring(mem(EP_LIST_PTR + ((mem(0x00B2C628, FIELD_WORD) - 1) * 0x18) + 0x4, FIELD_STRING));

function settings.onInitAPI()
	registerEvent(settings, "onStart", "onStart", true);
	registerEvent(settings, "onTick", "onTick", true);
	registerEvent(settings, "onExitLevel", "onExitLevel", false);
end

function settings.onStart()
	GLOBAL_LIVES = mem(0x00B2C5AC, FIELD_FLOAT);
	if(not isOverworld) then
		mem(0x00B2C5AC, FIELD_FLOAT, 50);
	end
end
	
if(not isOverworld) then
	function settings.onTick()
		if(mem(0x00B2C5AC, FIELD_FLOAT) ~= 50) then
			GLOBAL_LIVES = GLOBAL_LIVES + mem(0x00B2C5AC, FIELD_FLOAT) - 50;
			mem(0x00B2C5AC, FIELD_FLOAT, 50);
		end
	end

	function settings.onExitLevel()
		if(player:mem(0x13C, FIELD_BOOL)) then
			GLOBAL_LIVES = GLOBAL_LIVES - 1;
		end
		mem(0x00B2C5AC, FIELD_FLOAT, GLOBAL_LIVES);
	end
end

return settings;