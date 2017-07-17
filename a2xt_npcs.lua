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
				  

local signs = {};

for i = 1,3 do
	local s = table.join(
				 defaults,
				 {id = 996+i-1,
				  gfxheight = 48, 
				  gfxwidth = 48, 
				  width = 48, 
				  height = 48,
				  nogravity = 1,
				  noblockcollision = 1});
	s.framestyle = 0;
	signs[i] = npcManager.setNpcSettings(s);
				  
	npcManager.registerEvent(signs[i].id, signs, "onTickNPC");
end

function signs:onTickNPC()
	self.friendly = true;
	self.msg = "";
	self.dontMove = true;
end

return friendlies