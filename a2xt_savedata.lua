local lunajson = API.load("ext/lunajson");
local vectr = API.load("vectr");

local savedata = {}

--Saveable data
local data_save = {};

--Volatile data
local data_game = {};

_G["SaveData"] = savedata;
_G["GameData"] = data_game;

local basesave = Misc.saveGame;

function Misc.saveGame(...)
	basesave(...);
	savedata.flush();
end

local EPISODEPATH = Misc.episodePath();

local function write(filename, data)
	local f = io.open(EPISODEPATH..filename, "w");
	f:write(lunajson.encode(data));
	f:flush();
	f:close();
end

local function read(filename)
	local f = io.open(EPISODEPATH..filename, "r");
	if(f == nil) then return {}; end
	local content = f:read("*all");
    f:close();
	if(content ~= "") then
		return lunajson.decode(content);
	else
		return {};
	end
end

function savedata.flush()
	if(not Defines.player_hasCheated) then
		write("save"..mem(0x00B2C62A, FIELD_WORD).."-ext.json",data_save);
	end
end

local function flushTemp()
	GameData.__TEMP_SAVE_DATA = data_save;
	write("save"..mem(0x00B2C62A, FIELD_WORD)..".tmp", GameData);
end

local function loadTemp()
	local path = "save"..mem(0x00B2C62A, FIELD_WORD)..".tmp";
	if(mem(0x00B2C89C, FIELD_DWORD) ~= -1 and mem(0x00B2C620, FIELD_WORD) ~= -1 and mem(0x00B2C89C, FIELD_WORD) ~= -1) then
		GameData = read(path);
	end
	write(path, {});
end

local function deserialiseData(data)
	for k,v in pairs(data) do
		if(type(v) == "table") then
			local vec = vectr.deserialise(v);
			if(vec) then
				data[k] = vec;
			else
				deserialiseData(v);
			end
		end
	end
end

local function loadData()
	loadTemp();
	if(GameData.__TEMP_SAVE_DATA == nil) then
		data_save = read("save"..mem(0x00B2C62A, FIELD_WORD).."-ext.json");
	else
		data_save = GameData.__TEMP_SAVE_DATA;
		GameData.__TEMP_SAVE_DATA = nil;
	end
	
	deserialiseData(data_save);
	deserialiseData(GameData);
end

loadData();


function savedata.onInitAPI()
	registerEvent(savedata, "onExitLevel", "onExitLevel", false);
end

function savedata.onExitLevel()
	if(not mem(0x00B2C620, FIELD_BOOL))then --Quitting, so don't save temp data
		flushTemp();
	end
end

function savedata.onEnterLevel(filename)
	flushTemp();
end

local savedata_mt = {};
function savedata_mt.__index(tbl, key)
	return data_save[key];
end

function savedata_mt.__newindex(tbl, key, val)
	data_save[key] = val;
end

setmetatable(savedata, savedata_mt);

return savedata;