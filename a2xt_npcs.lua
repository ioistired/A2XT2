local npcconfig = API.load("npcconfig", true)
local npcManager = API.load("npcManager")

local friendlies = {}


local defaults = {frames = 1, 
				  framestyle = 1, 
				  jumphurt = 1,
				  nofireball=1,
				  noiceball=1,
				  noyoshi=1,
				  grabside=0,
				  grabtop=0,
				  isshoe=0,
				  isyoshi=0,
				  nohurt=1,
				  spinjumpsafe=0}

local ballpeng = npcManager.setNpcSettings(table.join(
				 {id = 999,
				  gfxheight = 48, 
				  gfxwidth = 56, 
				  width = 32, 
				  height = 32},
				  defaults))

return friendlies