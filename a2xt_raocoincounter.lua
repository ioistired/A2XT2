local pnpc = API.load("pnpc");
local multipoints = API.load("multipoints");
local settings = API.load("a2xt_settings");
local raocoins = API.load("raocoin2");

local rc = {};

rc.currency = raocoins.registerCurrency(274, false, 480, 66);
rc.local_counter = 0;

local localraocoin = Graphics.loadImage(Misc.resolveFile("raocoin.png"));
local raocoin_taken = Graphics.loadImage(Misc.resolveFile("raocoin_taken.png"));

local raocoinnpcs = {};
local raocoin_empty = {};

local midpointLoaded = false;
local levelFinished = false;

function rc.onInitAPI()
	registerEvent(rc, "onNPCKill", "onNPCKill", false);
	registerEvent(rc, "onTick", "onTick", false);
	registerEvent(rc, "onStart", "onStart", true);
	registerEvent(rc, "onDraw", "onDraw", false);
	
	if(GameData.raocoins == nil) then
		GameData.raocoins = {currentLevel = nil};
	end
end

function rc.currency:onCollect(increment, npc)
	rc.local_counter = rc.local_counter + increment;	
	table.insert(raocoin_empty, {x=npc.x, y=npc.y});
	local n = pnpc.wrap(npc);
	n.data.collected = true;
end

function multipoints:onCollected(id)
	 rc.currency:save();
	  
	  GameData.raocoins.currentLevel = tostring(mem(0x00B250B0, FIELD_STRING));--settings.TextSettings:set("CurrentLevel", tostring(mem(0x00B250B0, FIELD_STRING)));
	  Text.dialog(GameData.raocoins.currentLevel);
	  for k,v in ipairs(raocoinnpcs) do
		if(not v.isValid and v.data.collected == true) then
			--settings.Settings:set("Raocoin"..k, 1);
			GameData.raocoins["coin"..k] = true;
		end
	  end
	--settings.Settings:save()
	--settings.TextSettings:save();
end

function rc.onNPCKill(event, npc, reason)
	if(midpointLoaded and npc.id == 192) then
		multipoints.onCollected(npc,0);
	end
end

function multipoints.onLevelStart()
	midpointLoaded = true;
end

function rc.onTick()
    if(mem(0x00B2C59E,FIELD_WORD) ~= 0 and not levelFinished) then --level is ending
      levelFinished = true;
      rc.currency:save();
   end
end

local function extractFilename(path)
	local index = path:find("[\\/][^\\/]*$");
	if(index == nil) then
		return nil;
	else
		return path:sub(index+1):lower();
	end
end

function rc.onStart()
	if(not isOverworld) then
		--Remove previously collected raocoins
		
		--New level, so reset raocoin collection
		if(GameData.raocoins.currentLevel == nil or extractFilename(GameData.raocoins.currentLevel) ~= Level.filename():lower() or tostring(mem(0x00B250B0, FIELD_STRING)) ~= GameData.raocoins.currentLevel) then --settings.TextSettings:get("CurrentLevel")) then
			--[[settings.Settings:set("Raocoin1", 0)
			settings.Settings:set("Raocoin2", 0)
			settings.Settings:set("Raocoin3", 0)
			settings.Settings:set("Raocoin4", 0)
			settings.Settings:set("Raocoin5", 0)
			settings.Settings:save();
			settings.TextSettings:set("CurrentLevel", "none")
			settings.TextSettings:save();
			]]
			
			GameData.raocoins.currentLevel = nil;
			for i = 1,5 do
				GameData.raocoins["coin"..i] = false;
			end
		end
		
		--Populate raocoin list and remove them if necessary
		for k,v in ipairs(NPC.get(274,-1)) do
			raocoinnpcs[k] = pnpc.wrap(v);
			--if(settings.Settings:get("Raocoin"..k) == 1) then
			if(GameData.raocoins["coin"..k]) then
				v:mem(0x3C,FIELD_STRING,""); --Remove from layer (allows hidden raocoins to not be displayed) - work around for kill() not working on hidden NPCs
				rc.local_counter = rc.local_counter + 1;
				table.insert(raocoin_empty, {x=v.x, y=v.y});
				v:kill();
			end
		end
		
		if #raocoinnpcs < 5 then --Search container NPCs such as grass, bubbles and yoshis.
			for k,v in ipairs(NPC.get({283,91,263,96},-1)) do
				if v:mem(0xF0,FIELD_DFLOAT) == 274 then
					table.insert(raocoinnpcs, pnpc.wrap(v));
					--if(settings.Settings:get("Raocoin"..#raocoinnpcs) == 1) then	
					if(GameData.raocoins["coin"..#raocoinnpcs]) then
						rc.local_counter = rc.local_counter + 1;
						
						local yoffset = 0;
						if(v.id == 91) then
							yoffset = -64;
						elseif(v.id == 96) then
							yoffset = -32;
						end
						
						
						table.insert(raocoin_empty, {x=v.x, y=v.y+yoffset});
						v:mem(0xF0,FIELD_DFLOAT,0)
					end
				end
			end
		end
	end
end

function rc.onDraw()
	for k,v in ipairs(raocoin_empty) do
		Graphics.drawImageToSceneWP(raocoin_taken,v.x,v.y,-74)
	end
end

return rc;