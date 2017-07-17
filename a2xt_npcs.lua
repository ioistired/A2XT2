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

local pengs = {}
local pengData = 
{
	[999] = {collected = false,
	msg = {"HELLO I AM A PENG.", "I LIKE BEING A PENG."}},
	[987] = {collected = false,
	msg = {"PENG WAS TOLD THIS WOULD BE DIFFERENT KIND OF JAIL.", "YOU'LL NEVER TAKE PENG ALIVE, MAGNESUIMS."}},
	[988] = {collected = false,
	msg = {"PENG IS NOT USED TO COLD.", "PENG DON'T KNOW HOW TO TAKE OFF PAKRA."}},
	[989] = {collected = false,
	msg = {"I AM THE BIGGEST PENG.", "I WAS WRONG."}},
	[990] = {collected = false,
	msg = {"SUCH SUPERNATURAL MATTERS ARE NO BUSENES TO MORTALS LIKE YOU.","THE FREE FOOD CANNOT CONTAIN PENG."}},
	[991] = {collected = false,
	msg = {"I would appreciate not being labelled with the same level of eloquence that my penguin siblings have been known for. I think you will find I am perfectly erudite.", "...I believe I understand why people are so quick to judge us as penguins. They really are awfully noisy."}},
	[992] = {collected = false,
	msg = {"AM PRETTIEST PENG.","MANY PRETTY PENGS!!!!"}},
	[993] = {collected = false,
	msg = {"PENG LIKE JAM.","JAAAAAAAAM!"}},
	[994] = {collected = false,
	msg = {"AM HIDE PENG.","AM FIND PENG."}},
	[995] = {collected = false,
	msg = {"I AM A SERIOUS BUILDER PENG.","PLEASE LET ME GO, I HAVE BUILDS TO CONSTRUCT."}}
}

local function CountCollectedPengs()
	local c = 0;
	for _,v in pairs(pengData) do
		if(v.collected) then
			c = c + 1;
		end
	end
	return c;
end

pengs[1] = table.join(
				 {id = 999,
				  gfxheight = 48, 
				  gfxwidth = 56, 
				  width = 32, 
				  height = 32},
				  defaults);
				  
local bigpengs = {[988] = true, [993] = true, [995] = true}
local widepengs = {[988] = true}
local tinypeng = 989;

for i = 987,995 do
	local s = table.clone(pengs[1]);
	s.id = i;
	if(bigpengs[s.id]) then
		s.gfxheight = 56;
	end
	if(widepengs[s.id]) then
		s.gfxwidth = 58;
	end
	
	if(tinypeng == s.id) then
		s.gfxheight = 32;
		s.gfxwidth = 32;
	end
	table.insert(pengs, s);
end
			
for _,v in ipairs(pengs) do
	npcManager.setNpcSettings(v);
	npcManager.registerEvent(v.id, pengs, "onTickNPC");
end			

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

function pengs:onTickNPC()
	self.friendly = true;
	local i = 1;
	if(pengData[self.id].collected and CountCollectedPengs() >= 3) then
		i = 2;
	end
	self.msg = pengData[self.id].msg[i];
	self.dontMove = true;
end

return friendlies