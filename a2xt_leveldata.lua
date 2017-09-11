local lunajson = API.load("ext/lunajson")

for i = 0,9 do
	if(SaveData["world"..i] == nil) then
		SaveData["world"..i] = {town = {}};
	end
end

local leveldata = {};
local LEVEL = 0;
local TOWN = 1;
local EOW = 2;

leveldata.TYPE_LEVEL = LEVEL;
leveldata.TYPE_TOWN = TOWN;
leveldata.TYPE_EOW = EOW;

local typemap = {level = LEVEL, town = TOWN, eow = EOW};

local LEEK = 6;
local TAPE = 7;
local JAR = 4;
local CASH = 2;
local KEY = 3;
local ROULETTE = 1;

function isTownLevel()
	local d = leveldata.GetData();
	if(d) then
		return d.Type == leveldata.TYPE_TOWN;
	else
		return false;
	end
end

leveldata.EXIT_LEEK = LEEK;
leveldata.EXIT_TAPE = TAPE;
leveldata.EXIT_JAR = JAR;
leveldata.EXIT_CASH = CASH;
leveldata.EXIT_KEY = KEY;
leveldata.EXIT_ROULETTE = ROULETTE;

local exits = {leek = LEEK, tape = TAPE, jar = JAR, cash = CASH, key = KEY, roulette = ROULETTE};

local lvl = {};

local D = CHARACTER_DEMO;
local I = CHARACTER_IRIS;
local R = CHARACTER_RAOCOW;
local K = CHARACTER_KOOD;
local S = CHARACTER_SHEATH;
local B = CHARACTER_UNCLEBROADSWORD;

local defaultChars = {D,I,R,K,S};

local SACK = -1;
local CATNIP = -2;
local BEET = PLAYER_BIG;
local FIRE = PLAYER_FIREFLOWER;
local ICE = PLAYER_ICE;
local LEAF = PLAYER_LEAF;
local ONION = PLAYER_TANOOKIE;
local GOURD = PLAYER_HAMMER;

local filterTypes = {
sack = SACK, 
boot = SACK, 
catnip = CATNIP, 
yoshi = CATNIP, 
beet = PLAYER_BIG,
big = PLAYER_BIG,
fire = PLAYER_FIREFLOWER,
ice = PLAYER_ICE,
leaf = PLAYER_LEAF,
onion = PLAYER_TANOOKIE,
tanuki = PLAYER_TANOOKIE,
tanooki = PLAYER_TANOOKIE,
tanookie = PLAYER_TANOOKIE,
gourd = PLAYER_HAMMER,
hammer = PLAYER_HAMMER};

local groupFilters = {
mounts = {SACK, CATNIP},
powers = {FIRE, ICE, LEAF, ONION, GOURD},
tier1 = {ICE, LEAF, ONION, GOURD},
tier2 = {ONION, GOURD}
}

local filterMap =
{
[9] = filterTypes.big,
[14] = filterTypes.fire,
[34] = filterTypes.leaf,
[169] = filterTypes.tanuki,
[170] = filterTypes.hammer,
[182] = filterTypes.fire,
[183] = filterTypes.fire,
[184] = filterTypes.big,
[185] = filterTypes.big,
[249] = filterTypes.big,
[250] = filterTypes.big,
[264] = filterTypes.ice,
[277] = filterTypes.ice
}

--local savedata = Data(Data.DATA_WORLD, "LevelData", true)
local winState = 0;

local completion = {};

local worlds = {};

local keywords = {"name","author","type","exit","secret","raocoins","chars","filters","peng"}

local function split(s, x)
	local r = {};
	i = 1;
	for v in string.gmatch(s,"([^"..x.."]+)") do
		r[i] = v;
		i = i + 1;
	end
	return r;
end

local function trim(s)
	return s:match("^%s*(.-)%s*$");
end

local function parseType(s)
	s = string.lower(s);
	return typemap[s];
end

local function parseExit(s)
	s = string.lower(s);
	return exits[s];
end

local function parseBool(s)
	s = string.lower(s);
	
	if(s == "true" or s == "t") then
		return true;
	elseif(s == "false" or s == "f") then
		return false;
	else
		return tonumber(s) == 0;
	end
end

local function parseCharFilter(s)
	s = string.lower(s);
	local tbl = {};
	local addchar = function(c)
		if(c == "d") then
			table.insert(tbl, CHARACTER_DEMO);
		elseif(c == "i") then
			table.insert(tbl, CHARACTER_IRIS);
		elseif(c == "r") then
			table.insert(tbl, CHARACTER_RAOCOW);
		elseif(c == "k") then
			table.insert(tbl, CHARACTER_KOOD);
		elseif(c == "s") then
			table.insert(tbl, CHARACTER_SHEATH);
		elseif(c == "b") then
			table.insert(tbl, CHARACTER_UNCLEBROADSWORD);
		else
			Misc.warn("Unrecognised character filter '"..c.."' in "..s);
		end
	end	
	s:gsub(".", addchar);
	if(#tbl == 0) then
		tbl = defaultChars;
	end
	return tbl;
end

local function parseObjFilter(s)
	return filterTypes[s];
end

local function cleanupList(l)
	if(l == nil or l == {}) then
		return l;
	end
	local map = {};
	for _,v in ipairs(l) do
		if(map[v] == nil) then
			map[v] = true;
		end
	end
	local uniqueList = {};
	for k,_ in pairs(map) do
			table.insert(uniqueList, k);
	end
	return uniqueList;
end

local function parseFile(f, fname)
	local w = {};
	local dat = {};
	local datatable = {};
	local i = 0;
	for line in f:lines() do
		i = i +1;
		--Level header
		local head = line:match("%s*LEVEL%s*:%s*(.*)%s*");
		if(head) then
			if(#w > 0) then
				dat.Chars = cleanupList(dat.Chars);
				dat.Filters = cleanupList(dat.Filters);
				dat.Path=w[#w];
				datatable[w[#w]] = dat;
				dat = {};
			end
			table.insert(w,head);
		else
			--Filter check
			local filter = string.lower(line):match("%s*filter(.*)%s*");
			if(filter) then
				if(dat.Filters == nil) then
					dat.Filters = {};
				end
				if(groupFilters[filter]) then
					for _,v in ipairs(groupFilters[filter]) do
						table.insert(dat.Filters, v);
					end
				else
					table.insert(dat.Filters, parseObjFilter(filter));
				end
				
			elseif(trim(line) ~= "") then
				--Separate key from value
				local kv = split(line, "=");
				if(#kv ~= 2) then
					Misc.warn("Malformatted line in "..fname.." at line "..i..": "..line);
				else
					--Trim whitespace
					for k,v in ipairs(kv) do
						kv[k] = trim(v);
					end
					--Convert key to lowercase
					kv[1] = string.lower(kv[1]);
					
					--Parse value depending on key
					if(kv[1] == "name") then
						dat.Name = kv[2];
					elseif(kv[1] == "author") then
						dat.Author = kv[2];
					elseif(kv[1] == "type") then
						dat.Type = parseType(kv[2]);
					elseif(kv[1] == "exit") then
						dat.Exit = parseExit(kv[2]);
					elseif(kv[1] == "secret") then
						dat.Secret = parseExit(kv[2]);
					elseif(kv[1] == "raocoins") then
						dat.Raocoins = parseBool(kv[2]);
					elseif(kv[1] == "chars") then
						dat.Chars = parseCharFilter(kv[2]);
					elseif(kv[1] == "peng") then
						dat.Peng = tonumber(kv[2]);
					end
				end
			end
		end
	end
	if(#w > 0) then
		dat.Chars = cleanupList(dat.Chars);
		dat.Filters = cleanupList(dat.Filters);
		dat.Path=w[#w];
		datatable[w[#w]] = dat;
		dat = {};
	end
	return w,datatable;
end

local function parseFiles()
	for i = 0,9,1 do
		local p = Misc.resolveFile("levelinfo/world"..i..".txt");
		if(p) then
			local f = io.open(p,"r");
			local w,d = parseFile(f, "world"..i..".txt");
			worlds[i] = w;
			for k,v in pairs(d) do
				lvl[k] = v;
			end
		else
			worlds[i] = {};
		end
	end
end

function leveldata.onInitAPI()
	registerEvent(leveldata, "onTick", "onTick", false);
	registerEvent(leveldata, "onExitLevel", "onExitLevel", true);
	
	parseFiles();
	
	if(SaveData.completion == nil) then
		SaveData.completion = {};
	end
	
	if(not isOverworld) then
		local name = string.sub(Level.filename(), 0, -5);
		if(not SaveData.completion[name]) then
			SaveData.completion[name] = {};
		end
	end
	--completion = SaveData.completion;--savedata:get();
	--for k,v in pairs(completion) do
	--	completion[k] = lunajson.decode(v);
	--end
end

local function contains(t,x)
	for _,v in ipairs(t) do
		if(v == x) then
			return true;
		end
	end
	return false;
end

function leveldata.enforceFilters()
	if(not isOverworld) then
		leveldata.applyFilters(Level.filename());
	end
end

function leveldata.applyFilters(charList, filterList)
	if(type(charList) == "string") then
		local dat = leveldata.GetData(charList);
		if(dat == nil) then
			return;
		end
		leveldata.applyFilters(leveldata.CharsOrDefault(dat), dat.Filters);
	else
		if(not contains(charList, player.character)) then
			for _,v in ipairs(defaultChars) do
				if(contains(charList, v)) then
					leveldata.setCharacter(v);
					break;
				end
			end
		end
		if(filterList) then
			if(contains(filterList, player.powerup)) then
				if(player.powerup == PLAYER_BIG) then
					player.powerup = PLAYER_SMALL;
				else
					player.powerup = PLAYER_BIG;
				end
			end
			if(filterMap[player.reservePowerup] ~= nil and contains(filterList, filterMap[player.reservePowerup])) then
					player.reservePowerup = 0;
				end
			if((player:mem(0x108,FIELD_WORD) == 1 and contains(filterList, SACK)) or player:mem(0x108,FIELD_WORD) == 3 and contains(filterList, CATNIP)) then
					player:mem(0x108,FIELD_WORD,0);
			end
		end
	end
end

function leveldata.setCharacter(id)
	local temps = Player.getTemplates();
	for i=0x00,0x184,0x02 do
		temps[player.character]:mem(i,FIELD_WORD,player:mem(i,FIELD_WORD));
	end
	player.powerup = temps[id].powerup;
	player.reservePowerup = temps[id].reservePowerup;
	player:mem(0x108, FIELD_WORD, temps[id]:mem(0x108,FIELD_WORD));
	player:mem(0x10A, FIELD_WORD, temps[id]:mem(0x10A,FIELD_WORD));
	player:mem(0x16, FIELD_WORD, temps[id]:mem(0x16,FIELD_WORD));
	
	player.character = id;
end

function leveldata.GetWorldInfo(index)
	local d = {};
	for k,v in ipairs(worlds[index]) do
		table.insert(d, lvl[v]);
	end
	return d;
end

function leveldata.GetData(levelFile)
	levelFile = levelFile or Level.filename();
	
	return lvl[string.sub(levelFile, 0, -5)];
end

function leveldata.GetCompletion(levelFile)
	levelFile = levelFile or Level.filename();
	
	return SaveData.completion[string.sub(levelFile, 0, -5)];
end

function leveldata.Visited(levelFile)
	return GetCompletion(levelFile) ~= nil;
end

function leveldata.Cleared(levelFile)
	return GetCompletion(levelFile).Exit == true;
end

function leveldata.SecretCleared(levelFile)
	return GetCompletion(levelFile).Secret == true;
end

function leveldata.CharsOrDefault(data)
	if(data == nil) then
		return defaultChars;
	end
	return data.Chars or defaultChars;
end

function leveldata.onTick()
	if(not isOverworld) then
		winState = Level.winState();
	end
end

if(not isOverworld) then
	function leveldata.onExitLevel()
		local name = string.sub(Level.filename(), 0, -5);
		local data = lvl[name];
		if(data) then
		
			--Level has been beaten
			if(winState == data.Exit) then
				SaveData.completion[name].Exit = true;
			end
			--Secret exit has been beaten
			if(winState == data.Secret) then
				SaveData.completion[name].Secret = true;
			end
			
			--SaveData.completion[name] = com
			--savedata:set(name, lunajson.encode(completion[name]));
			--savedata:save();
		end
	end
end

return leveldata;