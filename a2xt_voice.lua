local voice = {}
local audiom = API.load("audiomaster")
local eventu = API.load("eventu")
local rng = API.load("rng")

voice.enableVoices = true;
voice.char = {};

local charids = {};

local charmt = {};
function charmt.__index(tbl,k)
	local c = k:lower();
	if(c == k) then
		local obj = audiom.Create{x = 0, y = 0, falloffRadius = 800, falloffType=audiom.FALLOFF_NONE, play = false, loops = 1};
		tbl[k] = obj;
		table.insert(charids,k);
		return obj;
	else
		return tbl[c];
	end
end

setmetatable(voice.char, charmt);

local function internal_play(character, sounds, args)
	if(type(sounds) == "table") then
		sounds = rng.irandomEntry(sounds);
	end
	character.sound = Audio.SfxOpen(sounds);
		
	if(args == nil) then
		args = {};
	end
	
	character.volume = args.volume or 1;
		
	character.tags = {"a2xt_voice"};
		
	if(args.tag) then
		table.insert(character.tags, args.tag);
	end
	if(args.tags) then
		for _,v in ipairs(args.tags) do
			table.insert(character.tags, v);
		end
	end
		
	character:Play();
end

local function internal_waitplay(character, sounds, args)
	eventu.waitFrames(1,true); 
	internal_play(character, sounds, args)
end

function voice.Play(character, sounds, args)
	if(voice.enableVoices) then
		if(character.playing) then
			character:Stop();
			if(type(sounds) == "table") then
				sounds = table.iclone(sounds);
			end
			if(args) then
				args = table.deepclone(args);
			end
			eventu.run(internal_waitplay, character, sounds, args);
		else
			internal_play(character, sounds, args);
		end
	end
end

registerEvent(voice, "onCameraDraw", "onCameraDraw", true);

function voice.onCameraDraw()
	local x,y = Camera.get()[1].x+400, Camera.get()[1].y+300;
	for _,v in ipairs(charids) do
		voice.char[v].x = x;
		voice.char[v].y = y;
	end
end

local voicemt = {}
function voicemt.__index(tbl,k)
	if(k == "volume") then
		return audiom.volume.a2xt_voice or 1;
	end
end
function voicemt.__newindex(tbl,k,v)
	if(k == "volume") then
		audiom.volume.a2xt_voice = v;
	end
end

setmetatable(voice, voicemt);

return voice;