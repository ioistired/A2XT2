

local multipoints = API.load("multipoints")

multipoints.addLuaCheckpoint(-179264, -180352, 1)
multipoints.addLuaCheckpoint(-159584, -160288, 2)
multipoints.addLuaCheckpoint(-139872, -140512, 3)

local tableOfCharacterBlocks = {626, 627, 628, 629, 632}
local tableSwitch = {}
tableSwitch[1] = 626;
tableSwitch[2] = 627;
tableSwitch[3] = 628;
tableSwitch[4] = 629;
tableSwitch[5] = 632;

function onTick()
	for _,a in pairs(Block.get(tableOfCharacterBlocks)) do
		a.id = tableSwitch[player.character]
	end
	
	for _, v in pairs(NPC.get(122,-1)) do
		v:mem(0x12A,FIELD_WORD,180)
	end
end

function onStart()
	_G["ManualTitle"] = "I Sawed the Deamond"
	_G["ManualArtist"] = "Robert Prince"
	_G["ManualAlbum"] = "Doom"
end