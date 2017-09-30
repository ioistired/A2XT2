local rng = API.load("rng")
local eventu = API.load("eventu")
local audiom = API.load("audioMaster")

local a2xt_sounds = {}



a2xt_sounds.volume = {music=1, ambient=1, sfx=1, voice=1}
local voicedGameplay = false


local charMap = {demo=CHARACTER_DEMO, iris=CHARACTER_IRIS, kood=CHARACTER_KOOD, raocow=CHARACTER_RAOCOW, sheath=CHARACTER_SHEATH, broadsword=CHARACTER_BROADSWORD}
local playerSounds = {}

for  k,v in pairs{"demo"}  do

	local folderPath = Misc.resolveDirectory("sound/voice/player/"..v.."/")
	local playerSoundsTable = {paths={}, chunks={}}

	for  _,v1 in ipairs (Misc.listFiles(folderPath))  do
		local chunks = Audio.SfxOpen(folderPath.."/"..v1)
		for _,category in string.gmatch (v1, "(v%-"..v.."%-)([^%-]*)") do
			--windowDebug(v.."\n"..v1.."\n"..tostring(category))

			if  playerSoundsTable.chunks[category] == nil  then
				playerSoundsTable.chunks[category] = {}
				playerSoundsTable.paths[category] = {}
			end

			table.insert(playerSoundsTable.chunks[category], chunks)
			table.insert(playerSoundsTable.paths[category], folderPath.."/"..v1)
		end
	end
	playerSounds[charMap[v]] = playerSoundsTable
end


function a2xt_sounds.play(args)
	if  type(args.sound) == "table"  then
		local list = args.sound
		args.sound = rng.randomEntry(list)
	end
	audiom.PlaySound(args)
end


function a2xt_sounds.playSFX(args)
	local params = table.join(args, {volume=a2xt_sounds.volume.sfx})
	a2xt_sounds.play(params)
end

function a2xt_sounds.playVoice(args)
	local params = table.join(args, {volume=a2xt_sounds.volume.voice})
	a2xt_sounds.play(params)
end

function a2xt_sounds.playAmbient(args)
	local params = table.join(args, {volume=a2xt_sounds.volume.ambient})
	a2xt_sounds.play(params)
end



function a2xt_sounds.onInitAPI()
	registerEvent (a2xt_sounds, "onJump")
	registerEvent (a2xt_sounds, "onTick")
end


local jumpCount = 0
local jumpFlag = false

function a2xt_sounds.onJump(index)
	local playerRef = player
	if  index == 2  then
		playerRef = player2
	end

	if  rng.random() > 0.3  and  not jumpFlag  and  voicedGameplay  then--(1 - 0.3*jumpNum)  then
		jumpCount = jumpCount+1
		local sndTable = playerSounds[player.character]
		if  sndTable ~= nil  then
			a2xt_sounds.playVoice{sound=sndTable.paths.jump}
		end
		if  jumpCount > rng.randomInt(2,4)  then
			jumpFlag = true
			eventu.run(function ()
			            eventu.waitSeconds(rng.random(1,2))
			            jumpFlag = false
			            jumpCount = 0
		              end)
		end
	end
end


local hurtFlag = false
function a2xt_sounds.onTick()
	if  player:mem(0x122, FIELD_WORD) == 2  and  voicedGameplay  then
		if  not hurtFlag  then
			local sndTable = playerSounds[player.character]
			if  sndTable ~= nil  then
				a2xt_sounds.playVoice{sound=sndTable.paths.hurt}
				hurtFlag = true
			end
		end
	else
		hurtFlag = false
	end
end

return a2xt_sounds