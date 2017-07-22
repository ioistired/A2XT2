local npcconfig = API.load("npcconfig", true)
local npcManager = API.load("npcManager")
local pnpc = API.load("pnpc")
local audio = API.load("audioMaster")

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

if(SaveData.pengs) then
	for k,v in pairs(pengData) do
		v.collected = SaveData.pengs[tostring(k)];
	end
end

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
	npcManager.registerEvent(v.id, pengs, "onStartNPC");
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

local blackmarket = {};
local marketSettings = table.join(
				 defaults,
				 {id = 986,
				  gfxheight = 96, 
				  gfxwidth = 64, 
				  width = 96,
				  gfxoffsetx = 32,
				  height = 64,
				  noblockcollision = 1,
				  nogravity = 1});
marketSettings.frames = 4;
marketSettings.framespeed = 12;

npcManager.registerEvent(marketSettings.id, blackmarket, "onTickNPC");
npcManager.registerEvent(marketSettings.id, blackmarket, "onDrawNPC");
blackmarket.settings = npcManager.setNpcSettings(marketSettings);

function blackmarket:onTickNPC()
	self.data.playing = false;
	self.animationTimer = 0;
end

function blackmarket:onDrawNPC()
	if(self.data.frameTimer and self.data.frameTimer > 0) then
		self.data.frameTimer = self.data.frameTimer - 1;
	else
	
	if(self.data.playing) then
		if(self.animationFrame < 3) then
			self.animationFrame = self.animationFrame + 1;
			self.data.frameTimer = blackmarket.settings.framespeed;
		else
			self.animationFrame = 3;
			self.data.frameTimer = 0;
		end
	else
		if(self.animationFrame > 0) then
			self.animationFrame = self.animationFrame - 1;
			self.data.frameTimer = blackmarket.settings.framespeed;
		else
			self.animationFrame = 0;
			self.data.frameTimer = 0;
		end
	end
	end
end

function blackmarket:onMessage()
	self.data.frameTimer = blackmarket.settings.framespeed;
	self.data.playing = true;
end

function friendlies.onInitAPI()
	registerEvent(friendlies, "onMessageBox");
	registerCustomEvent(friendlies, "onMessage")
end

function friendlies.getTalkNPC()
	local best = nil;
	local distance = math.huge;
	for _,v in ipairs(NPC.getIntersecting(player.x,player.y,player.x+player.width,player.y+player.height)) do
		if(v:mem(0x44,FIELD_BOOL)) then
			local dx = (v.x+v.width*0.5) - (player.x+player.width*0.5);
			local dy = (v.y+v.height*0.5) - (player.y+player.height*0.5);
			if(dx*dx + dy*dy < distance) then
				best = v;
			end
		end
	end
	
	if  best ~= nil  then
		best = pnpc.wrap(best)
	end
	return best;
end

function friendlies.onMessageBox(eventObj, message)
	local npc = nil;
	if(player.upKeyPressing) then
		npc = friendlies.getTalkNPC();
	end
	if(npc ~= nil) then
		if(npc.id == blackmarket.settings.id) then
			blackmarket.onMessage(npc)
		elseif(pengData[npc.id]) then
			pengs.onMessage(npc);
		end
	end
	friendlies.onMessage(eventObj, message, npc);
end

function signs:onTickNPC()
	self.friendly = true;
	self.msg = "";
	self.dontMove = true;
end

function pengs:onMessage()
	audio.PlaySound{sound = Misc.resolveFile("sound/noot.ogg"), volume = 1}
	if(not pengData[self.id].collected) then
		pengData[self.id].collected = true;
		self.data.collected = true;
		if(SaveData.pengs == nil) then
			SaveData.pengs = {}
		end
		SaveData.pengs[tostring(self.id)] = true;
		Misc.saveGame();
	end
end

function pengs:onStartNPC()
	if(pengData[self.id].collected) then --TODO: add check for hub
		self:kill(9);
	end
end

function pengs:onTickNPC()
	if(self.data.collected) then
		local a = Animation.spawn(10,self.x+self.width*0.5,self.y+self.height*0.5);
		a.x = a.x-a.width*0.5;
		a.y = a.y-a.height*0.5;
		self:kill(9);
	else
		self.friendly = true;
		local i = 1;
		if(pengData[self.id].collected and CountCollectedPengs() >= 3) then
			i = 2;
		end
		self.msg = pengData[self.id].msg[i];
		self.dontMove = true;
	end
end

return friendlies