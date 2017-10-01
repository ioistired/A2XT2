local rng = API.load("rng")
local npcconfig = API.load("npcconfig")
local npcManager = API.load("npcManager")
local pnpc = API.load("pnpc")
local audio = API.load("audioMaster")
local textblox = API.load("textblox")
local pm = API.load("playerManager")
local colliders = API.load("colliders")
local eventu = API.load("eventu");

local a2xt_scene = API.load("a2xt_scene");
local a2xt_leveldata = API.load("a2xt_leveldata")
local a2xt_rewards = API.load("a2xt_rewards")
local a2xt_message = API.load("a2xt_message")
local a2xt_costumes = API.load("a2xt_costumes")

if(not isOverworld) then

	local starman = API.load("starman")
	if(isTownLevel()) then
		starman.start = function(p) p.reservePowerup = starman.id; Audio.playSFX(12); end;
		starman.startTheStar = starman.start;

		local localstarman = {}
		
		npcManager.registerEvent(starman.id, localstarman, "onTickNPC");
		function localstarman:onTickNPC()
			self.speedY = math.max(self.speedY, 0);
			self.speedX = 0;
		end
	end

	starman.sfxFile = Misc.resolveFile("popipo.ogg") or Misc.resolveFile("music/popipo.ogg")
	starman.reloadMusic();
	starman.duration = lunatime.toTicks(26.6);
end

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
				  width = 64, 
				  height = 64},
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
		s.width = 32;
		s.height = 32;
	end
	table.insert(pengs, s);
end
			
for _,v in ipairs(pengs) do
	npcManager.setNpcSettings(v);
	npcManager.registerEvent(v.id, pengs, "onTickNPC");
	npcManager.registerEvent(v.id, pengs, "onStartNPC");
end		


npcManager.setNpcSettings({id = 151, talkrange = 0});	

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
				  nogravity = 1,
				  noturn = 1,
				  talkrange = 56});
marketSettings.frames = 4;
marketSettings.framespeed = 12;

npcManager.registerEvent(marketSettings.id, blackmarket, "onTickNPC");
blackmarket.settings = npcManager.setNpcSettings(marketSettings);

function blackmarket:onTickNPC()

	self.data.event = "steve";
	if(SaveData.spokenToSteve) then
		self.data.name = "Steve";
	else
		self.data.name = "???";
	end
	if(self.data.frameTimer and self.data.frameTimer > 0) then
		self.data.frameTimer = self.data.frameTimer - 1;
	else
		local offset = 0;
		if(self.direction == 1) then
			offset = 4;
		end
		if(self.data.playing) then
			if(self.animationFrame < 3+offset) then
				self.animationFrame = self.animationFrame + 1;
				self.data.frameTimer = blackmarket.settings.framespeed;
			else
				self.animationFrame = 3+offset;
				self.data.frameTimer = 0;
			end
		else
			if(self.animationFrame > offset) then
				self.animationFrame = self.animationFrame - 1;
				self.data.frameTimer = blackmarket.settings.framespeed;
			else
				self.animationFrame = offset;
				self.data.frameTimer = 0;
			end
		end
	end
	self.animationTimer = 2;
end

function blackmarket:onMessage()
	self.data.frameTimer = blackmarket.settings.framespeed;
	self.data.playing = true;
end

function blackmarket:onMessageEnd()
	self.data.frameTimer = blackmarket.settings.framespeed;
	self.data.playing = false;
end

function friendlies.onInitAPI()
	--registerEvent(friendlies, "onMessageBox");
	--registerCustomEvent(friendlies, "onMessage")
end

--[[
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
end]]

function signs:onTickNPC()
	self.friendly = true;
	self.msg = "";
	self.dontMove = true;
end

function pengs:onMessage()
	if(not pengData[self.id].collected) then
		self.data.collected = true;
		if(SaveData.pengs == nil) then
			SaveData.pengs = {}
		end
	end
end

function pengs:onMessageEnd(id)
	if(not pengData[id].collected) then
		pengData[id].collected = true
		SaveData.pengs[tostring(id)] = true;
		--Misc.saveGame();
		audio.PlaySound{sound = Misc.resolveFile("sound/noot.ogg")}
		local a = Animation.spawn(10,self.x+self.width*0.5,self.y+self.height*0.5);
		a.x = a.x-a.width*0.5;
		a.y = a.y-a.height*0.5;
		self:kill(9);
	end
end

function pengs:onStartNPC()
	if(pengData[self.id].collected) then --TODO: add check for hub
		self:kill(9);
	end
end

function pengs:onTickNPC()
	if(self.data.collected) then
	
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


local changebooth = {};
local boothSettings = 
				 {id = 978,
				  gfxheight = 96, 
				  gfxwidth = 48, 
				  width = 48,
				  height = 14,
				  noblockcollision = true,
				  nogravity = true,
				  noturn = true,
				  speed = 0,
				  playerblocktop = true,
				  frames=1,
				  framespeed=4,
				  nohurt=true};

npcManager.registerEvent(boothSettings.id, changebooth, "onTickNPC");
changebooth.settings = npcManager.setNpcSettings(boothSettings);

registerEvent(changebooth, "onTick");
registerEvent(changebooth, "onDraw");

changebooth.arrowPos = 0;
changebooth.arrowLeft = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/sanctuary_arrow_left.png"))
changebooth.arrowRight = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/sanctuary_arrow_right.png"))

changebooth.changing = 0;

function changebooth.onTick()
	local index = player:mem(0x176,FIELD_WORD);
	if(index > 0 and NPC(index-1).id == boothSettings.id) then
		changebooth.current = pnpc.wrap(NPC(index-1));
		
		if(changebooth.costumes == nil) then
		
			changebooth.keyLeft = true;
			changebooth.keyRight = true;
			changebooth.changing = 0;
		
			changebooth.costumes = a2xt_costumes.getUnlocked(player.character);
			changebooth.costumeindex = table.ifind(changebooth.costumes, a2xt_costumes.getCurrent(player.character));
			if(changebooth.costumeindex == nil) then
				changebooth.costumeindex = 0;
			end
		end
	else
		changebooth.costumes = nil;
		changebooth.current = nil;
	end
	
	if(changebooth.current) then
		player.speedX = 0;
		
		player.x = math.lerp(player.x+player.width*0.5, changebooth.current.x+changebooth.current.width*0.5, 0.2) - player.width*0.5
		
		
		if(changebooth.changing == 0) then
			if(player.keys.left and not changebooth.keyLeft) then
				changebooth.changing = -7*boothSettings.framespeed;
			elseif(player.keys.right and not changebooth.keyRight) then
				changebooth.changing = 7*boothSettings.framespeed;
			end
		else
			player.keys.jump = false;
			player.keys.altJump = false;
			
			if(math.abs(changebooth.changing) == 3*boothSettings.framespeed) then
				if(changebooth.changing < 0) then
					changebooth.costumeindex = changebooth.costumeindex - 1;
					if(changebooth.costumeindex < 0) then
						changebooth.costumeindex = #changebooth.costumes;
					end
				else
					changebooth.costumeindex = changebooth.costumeindex + 1;
					if(changebooth.costumeindex > #changebooth.costumes) then
						changebooth.costumeindex = 0;
					end
				end
				if(changebooth.costumes[changebooth.costumeindex]) then
					a2xt_costumes.wear(changebooth.costumes[changebooth.costumeindex]);
				else
					Player.setCostume(player.character, nil);
				end
			end
		end
		
		player.keys.run = false;
		player.keys.altRun = false;
		player.keys.dropItem = false;
		
		changebooth.keyLeft = player.keys.left;
		changebooth.keyRight = player.keys.right;
		
		player.keys.left = false;
		player.keys.right = false;
	end
	
end

function changebooth.onDraw()
	if(changebooth.current) then
		local idx = 15;
		if(player.character == CHARACTER_SHEATH) then
			idx = 1;
		end
		player:mem(0x114, FIELD_WORD, idx)
	
		if(changebooth.changing == 0) then
			local priority = 5;
			local a = math.sin(changebooth.arrowPos)
						
			Graphics.drawImageToSceneWP(changebooth.arrowLeft, changebooth.current.x + changebooth.current.width * 0.5 - 48 - a - 8, changebooth.current.y-48, priority)
			Graphics.drawImageToSceneWP(changebooth.arrowRight, changebooth.current.x + changebooth.current.width * 0.5 + 48 + a - 8, changebooth.current.y-48, priority)
						
			changebooth.arrowPos = changebooth.arrowPos+0.1;
			
			local name = changebooth.costumes[changebooth.costumeindex];
			if(name) then
				name = a2xt_costumes.data[name];
				if(name) then
					name = name.name;
				end
			end
			if(not name) then
				name = "Default";
			end
			
			local x = changebooth.current.x + changebooth.current.width * 0.5;
			local y = changebooth.current.y - boothSettings.gfxheight - 8
			
			textblox.printExt(name, {x = x+2, y = y+2, width=250, font = GENERIC_FONT, bind=textblox.BIND_LEVEL, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0x000000FF});
			textblox.printExt(name, {x = x, y = y, width=250, font = GENERIC_FONT, bind=textblox.BIND_LEVEL, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0xFFFFFFFF});
			
		else
			local frame = math.ceil(math.abs(changebooth.changing/boothSettings.framespeed));
			
			if(changebooth.changing < 0) then
				changebooth.changing = changebooth.changing + 1;
			else
				changebooth.changing = changebooth.changing - 1;
				frame = 8-frame;
			end
			
			Graphics.drawImageToSceneWP(Graphics.sprites.npc[boothSettings.id].img, changebooth.current.x, changebooth.current.y + changebooth.current.height - boothSettings.gfxheight, 0, boothSettings.gfxheight*(frame), boothSettings.gfxwidth, boothSettings.gfxheight, -15)
		end
	end
end

function changebooth:onTickNPC()
end


-- ***********************
-- ** COLLECTIBLES      **
-- ***********************

local collectsettings =
	{
		gfxwidth=48,
		gfxheight=50,
		width=42,
		height=42,
		framestyle=0,
		frames=1,
		speed = 0,
		playerblock=false,
		npcblock=false,
		nofireball=true,
		noiceball=true,
		noyoshi=true,
		grabside=false,
		isshoe=false,
		isyoshi=false,
		nohurt=true,
		iscoin=false,
		isinteractable=true,
		jumphurt=true,
		spinjumpsafe=false
	}

local costumeobj = {};
costumeobj.settings = table.join(
	{
		id = 977
	},
	collectsettings);
	
costumeobj.mannequin = Graphics.loadImage(Misc.resolveFile("graphics/extra/mannequin.png"));
	
npcManager.setNpcSettings(costumeobj.settings);
	
registerEvent(costumeobj, "onNPCKill")
npcManager.registerEvent(costumeobj.settings.id, costumeobj, "onTickNPC");
npcManager.registerEvent(costumeobj.settings.id, costumeobj, "onDrawNPC");

function costumeobj.collect(args)
		player.speedX = 0;
		eventu.waitFrames(32);
		a2xt_rewards.give{type="costume", quantity=args.npc.data.costume, wait=true};
		a2xt_scene.endScene();
end

function costumeobj.onNPCKill(eventobj,npc,reason)
	local id = npc.id;
	if(id == costumeobj.settings.id) then
		npc = pnpc.wrap(npc);
		if(reason == 9 and not npc.data.shopkeep) then
			if(colliders.collide(player,npc) or colliders.speedCollide(player,npc) or colliders.slash(player,npc) or colliders.downSlash(player,npc)) then
				a2xt_scene.startScene{scene=costumeobj.collect, sceneArgs={npc=npc}}
			end
		end
	end
end

function costumeobj:onTickNPC()
	if(not self.data.shopkeep and (self.data.costume == nil or SaveData.costumes[self.data.costume])) then
		self:kill(9);
	end
end

local function parseCostumeIni(path)
	local f = io.open(path, "r");
	if(f == nil) then
		return -24,-4,28,56;
	end
	local x,y = 0,0;
	local w,h = 0,0;
	local parse = -1;
	local whparse = -1;
	for v in f:lines() do
		if(whparse == -1) then
			local m = v:match("%[common%]");
			if(m) then
				whparse = 2;
			end
		else
			local m = v:match("width%s*=%s*(%d+)$");
			if(m) then
				w = tonumber(m);
				whparse = whparse-1;
			else
				m = v:match("height%s*=%s*(%d+)$");
				if(m) then
					h = tonumber(m);
					whparse = whparse-1;
				end
			end
		end
		
		if(parse == -1) then
			local m = v:match("%[frame%-(%d%-%d)%]");
			local c = path:sub(-14,-7);
			if(m and ((c ~= "link" and m == "6-4") or (c == "link" and m == "5-1"))) then
				parse = 2;
			end
		else
			local m = v:match("offsetX%s*=%s*(%d+)$");
			if(m) then
				x = tonumber(m);
				parse = parse-1;
			else
				m = v:match("offsetY%s*=%s*(%d+)$");
				if(m) then
					y = tonumber(m);
					parse = parse-1;
				end
			end
		end
		
		if(whparse == 0 and parse == 0) then
			break;
		end
	end
	f:close();
	return x,y,w,h;
end

function costumeobj:onDrawNPC()
	if(self.data.shopkeep) then
		self.animationFrame = 2;
		
		if(not SaveData.costumes[self.data.costume]) then
			if(self.data.sprite == nil) then
				local path = Misc.resolveFile(a2xt_costumes.info[self.data.costume].path.."/"..a2xt_costumes.info[self.data.costume].characterName.."-2.png");
				self.data.sprite = Graphics.loadImage(path);
				self.data.spritexoffset,self.data.spriteyoffset,self.data.spritewidth,self.data.spriteheight = parseCostumeIni(path:sub(1,-4).."ini");
			end
			local x,y = 600,400;
			if(a2xt_costumes.info[self.data.costume].character == CHARACTER_SHEATH) then
				x = 500;
				y = 0;
			end
			Graphics.drawImageToSceneWP(self.data.sprite, self.x+self.width*0.5-self.data.spritewidth+self.data.spritexoffset, self.y+self.height-self.data.spriteheight+self.data.spriteyoffset, x, y, 100, 100, -45);
		else
			if(self.data.a2xt_message) then
				self.data.a2xt_message.iconSpr.visible=false
			end
			self.data.price = "";
			Graphics.drawImageToSceneWP(costumeobj.mannequin, self.x+self.width*0.5-35, self.y+self.height-56, -45);
		end
	end
end

local cardobj = {};
cardobj.settings = table.join(
	{
		id = 976
	},
	collectsettings);
	
npcManager.setNpcSettings(cardobj.settings);
	
registerEvent(cardobj, "onNPCKill")
npcManager.registerEvent(cardobj.settings.id, cardobj, "onTickNPC");

function cardobj.collect(args)
		player.speedX = 0;
		eventu.waitFrames(32);
		a2xt_rewards.give{type="card", quantity=args.npc.data.card, wait=true};
		a2xt_scene.endScene();
end

function cardobj.onNPCKill(eventobj,npc,reason)
	local id = npc.id;
	if(id == cardobj.settings.id) then
		npc = pnpc.wrap(npc);
		if(reason == 9) then
			if(colliders.collide(player,npc) or colliders.speedCollide(player,npc) or colliders.slash(player,npc) or colliders.downSlash(player,npc)) then
				a2xt_scene.startScene{scene=cardobj.collect, sceneArgs={npc=npc}}
			end
		end
	end
end

function cardobj:onTickNPC()
	if(self.data.card == nil or false --[[SaveData.cards[self.data.card] --TODO: Replace this with a proper system for card saves]]) then
		self:kill(9);
	end
end


-- ***********************
-- ** PORTALS           **
-- ***********************
local portal = {}
local portalSettings = table.join(
	{
	 gfxwidth = 128, 
	 gfxheight = 128,
	 gravity = 0,
	 width = 64, 
	 height = 64,
	 framestyle = 0,
	 frames = 15,
	 framespeed = 3
	},
	defaults);

for i = 974,975 do
	local s = table.clone(portalSettings);
	s.id = i;
	
	table.insert(portal, s);
end

for _,v in ipairs(portal) do
	npcManager.setNpcSettings(v);
	npcManager.registerEvent(v.id, portal, "onTickNPC");
	--npcManager.registerEvent(v.id, portal, "onTickNPC");
	--npcManager.registerEvent(v.id, portal, "onDrawNPC");
end	

local portalEvents = {[974]="townportal",[975]="hubportal"}
function portal:onTickNPC()
	self.friendly = true
	self.data.event = portalEvents[self.id]
end

a2xt_message.presetSequences.townportal = function(args)
	a2xt_message.promptChosen = false
	a2xt_message.showPrompt {options = {"Return to P.O.R.T.(S.)", a2xt_message.getNoOption()}}
	a2xt_message.waitPrompt ()

	if  (a2xt_message.promptChoice == 1)  then
		eventu.waitSeconds(1)

	end
end

a2xt_message.presetSequences.hubportal = function(args)
	local portal = args.npc

	local worldOptions = {}
	local worldPositions = {}
	local optionWorlds = {}

	-- Set up prompt
	for  i=0,9  do
		if  (SaveData["world"..i].unlocked)  then
			worldOptions[#worldOptions+1] = a2xt_leveldata.GetWorldName(i)
			optionWorlds[#worldOptions] = i
			worldPositions[i] = worldOptions[#worldOptions]
		end
	end
	worldOptions[#worldOptions+1] = a2xt_message.getNoOption()
	a2xt_message.promptChosen = false

	-- Randomize W6's name
	if  worldPositions[6] ~= nil  then
		eventu.run(function()
				while (not a2xt_message.promptChosen) do
					worldOptions[worldPositions[6]] = a2xt_leveldata.GetWorldName(6)
					eventu.waitFrames(rng.randomInt(5,21))
				end
			end
		)
	end

	-- Display prompt
	a2xt_message.showPrompt {options=worldOptions}
	a2xt_message.waitPrompt ()

	-- If the player selected one of the worlds, either go to that map position or the SOW level
	if(a2xt_message.promptChoice ~= #worldOptions)  then
		eventu.waitSeconds(1)
		a2xt_scene.endScene()

		local worldNum = optionWorlds[#worldOptions]
		local pos = a2xt_leveldata.GetWorldStartMapPos(worldNum)  or  {x=0,y=0}

		local overworldDataPtr = mem(0xB2C5C8, FIELD_DWORD)
		mem(overworldDataPtr + 0x40, FIELD_DFLOAT, pos.x)
		mem(overworldDataPtr + 0x48, FIELD_DFLOAT, pos.y)


		-- If the player cleared the corresponding SOW level, just go to the map
		if  a2xt_leveldata.Cleared(worldStartLevel)  then
			Level.exit()

		else
			-- Insert player enter effect here
			-- Go to sow level
			a2xt_leveldata.loadLevel(worldStartLevel,0)
		end
		a2xt_message.waitMessageEnd()
	end

	-- End scene
	a2xt_scene.endScene()
end




-- ***********************************
-- ** GENERIC FRIENDLY NPCs         **
-- ***********************************

local chronotons = {}
local chronoSettings = table.join(
	{
	 gfxwidth = 32, 
	 gfxheight = 64,
	 gfxoffsety = 2,
	 nogravity = false,
	 width = 24, 
	 height = 52,
	 framestyle = 1,
	 frames = 4,
	 framespeed = 4,
	 speed=0,
	 noblockcollision=false
	},
	defaults);

for _,v in ipairs {403,404,405,489,973} do
	local s = table.clone(chronoSettings);
	s.id = v;
	if(v == 489) then
		s.framespeed = 6;
	elseif(v == 973) then
		s.framespeed = 8;
		s.gfxwidth=38;
	end

	npcManager.setNpcSettings(s);
end

npcManager.registerEvent(973, chronotons, "onTickNPC");

function chronotons:onTickNPC()
	self.friendly = true;

	self.data.name = "Tam";
end

-- ***********************
-- ** DEMO KREW         **
-- ***********************
local demokrew = {}
local demokrewData = 
{
	[980] = {collected = false, msg = {}},
	[981] = {collected = false, msg = {}},
	[982] = {collected = false, msg = {}},
	[983] = {collected = false, msg = {}},
	[994] = {collected = false, msg = {}}
}

demokrew[1] = table.join(
				 {id = 980,
				  width = 32, 
				  height = 64,
				  speed = 0},
				  defaults);

local krewInfo = {
                 chars     = {[980]=CHARACTER_MARIO, [981]=CHARACTER_LUIGI, [982]=CHARACTER_PEACH, [983]=CHARACTER_TOAD, [984]=CHARACTER_LINK},
                 names     = {[980]="Demo", [981]="Iris", [982]="Kood", [983]="raocow", [984]="Sheath"}
                }


for i = 980,984 do
	local s = table.clone(demokrew[1]);
	s.id = i;
	
	local ps = PlayerSettings.get(pm.getCharacters()[krewInfo.chars[i]].base, 2);
	
	s.width = ps.hitboxWidth;
	s.height = ps.hitboxHeight;
	table.insert(demokrew, s);
end

for _,v in ipairs(demokrew) do
	npcManager.setNpcSettings(v);
	npcManager.registerEvent(v.id, demokrew, "onTickNPC");
	npcManager.registerEvent(v.id, demokrew, "onDrawNPC");
end	

registerEvent(demokrew, "onStart", "onStart", false)

--Force update the character hitboxes for the demo krew NPCs to use
function demokrew.onStart()
	if(isTownLevel()) then
		for i = 1,5 do
			pm.refreshHitbox(i)
		end
	end
end


function demokrew:onTickNPC()
	self.friendly = true;

	self.data.name = krewInfo.names[self.id];

	self.isHidden = false;
	if  self.layerObj ~= nil  then
		self.isHidden = self.layerObj.isHidden;
	end
	if  player.character == krewInfo.chars[self.id]  then
		self.isHidden = true;
	end
	
	local x,y = self.x,self.y;
	x = x + self.width*0.5;
	y = y + self.height;
	local temps = Player.getTemplates();
	local c = krewInfo.chars[self.id];
	local ps = PlayerSettings.get(pm.getCharacters()[c].base, temps[c].powerup);
	self.height = ps.hitboxHeight;
	self.width = ps.hitboxWidth;
	
	self.x = x-self.width*0.5;
	self.y = y-self.height;
end

function demokrew:onDrawNPC()
	if(not self.isHidden) then
		local temps = Player.getTemplates();
		local c = krewInfo.chars[self.id];
		local ps = PlayerSettings.get(pm.getCharacters()[c].base, temps[c].powerup);
				
		local f = 1;
		
		local tx1,ty1 = 0,0;
		
		if(f == 0) then
			tx1 = 4;
			ty1 = 9;
		elseif(self.direction == 1) then
			tx1 = 4 + math.ceil(f/10);
			ty1 = (f-1)%10
		else --if(self.direction == -1) then
			tx1 = 4 - math.floor(f/10);
			ty1 = 9-(f%10)
		end
				
		local xOffset = ps:getSpriteOffsetX(tx1, ty1);
		local yOffset = ps:getSpriteOffsetY(tx1, ty1);
		
		tx1 = tx1*100;
		ty1 = ty1*100;
				
		Graphics.drawImageToSceneWP(Graphics.sprites[pm.getCharacters()[c].name][temps[c].powerup].img, self.x+xOffset, self.y+yOffset, tx1, ty1, 100, 100, -45)
		
		self.animationFrame = 9999;
	end
end


-- ***********************
-- ** TREASURE CHESTS   **
-- ***********************

if (SaveData.chests == nil)  then
	SaveData.chests = {}
end

if (SaveData.chests[Level.filename()] == nil)  then
	SaveData.chests[Level.filename()] = {}
end

local chest = {}
local chestSettings = table.join(
				 defaults,
				 {id = 979,
				  gfxheight = 64, 
				  gfxwidth = 64, 
				  width = 64,
				  gfxoffsetx = 0,
				  gfxoffsety = 0,
				  height = 64});

chestSettings.noyoshi = 1;
chestSettings.grabtop = 0;
chestSettings.grabside = 0;
chestSettings.frames = 2;
chestSettings.framespeed = 12;

registerEvent(chest, "onStart");
npcManager.registerEvent(chestSettings.id, chest, "onTickNPC");
chest.settings = npcManager.setNpcSettings(chestSettings);


a2xt_message.presetSequences.chest = function(args)
	local chest = args.npc
	local data = chest.data.chest

	if (not SaveData.chests[Level.filename()][tostring(data.chestid)]) then
		Audio.SeizeStream(-1)
		Audio.MusicPause()

		SaveData.chests[Level.filename()][tostring(data.chestid)] = true
		Audio.playSFX(28)
		eventu.waitSeconds (1)

		a2xt_rewards.give(table.join (data, {useTransitions=false, endScene=false, wait=true}))
	end

	Audio.MusicResume()
	Audio.ReleaseStream(-1)
	a2xt_scene.endScene()
	a2xt_message.endMessage();
	chest.data.event = nil
	chest.msg = ""
end

local chestIDCounter = 0;

function chest:onTickNPC()
	self.friendly = true
	
	if(not self.data.open) then
		self.data.event = "chest"

		-- Initialize data table
		local data = self.data.chest

		if data == nil  then
			self.data.chest = {
							 type = self.data.type  or  "raocoin",
							 quantity = self.data.quantity  or  self.data.item  or  5,
							 chestid = self.data.chestid
							}
			data = self.data.chest

			if(data.chestid == nil) then
				data.chestid = chestIDCounter;
				chestIDCounter = chestIDCounter + 1;
			end
			
			-- Update open state for costumes and cards, just in case
			if  (data.type == "costume" or data.type == "card") and SaveData.costumes and SaveData.costumes[data.quantity] then
				SaveData.chests[Level.filename()][tostring(data.chestid)] = true;
			end
		end

		-- Manage frame
		self.direction = DIR_LEFT
		self.animationFrame = 0;
		if (SaveData.chests[Level.filename()][tostring(data.chestid)])  then
			self.data.event = nil
			self.msg = ""
			self.animationFrame = 1;
		end
	else
		self.msg = ""
		self.animationFrame = 1;
	end
	self.animationTimer = 2;
end



-- ***********************
-- ** PAL STUFF         **
-- ***********************
local vectr = API.load("vectr");
local colliders = API.load("colliders");

local pal = {}
local palSettings = table.join(
				 defaults,
				 {id = 985,
				  gfxheight = 48, 
				  gfxwidth = 48, 
				  width = 32,
				  gfxoffsetx = 0,
				  gfxoffsety = 2,
				  height = 32});

palSettings.noyoshi = 0;
palSettings.grabtop = 1;
palSettings.grabside = 1;
palSettings.frames = 22;
palSettings.framespeed = 12;

registerEvent(pal, "onStart");
registerEvent(pal, "onNPCKill");
npcManager.registerEvent(palSettings.id, pal, "onTickNPC");
pal.settings = npcManager.setNpcSettings(palSettings);

local REACTIONS = {
                   FOLLOW = {},
                   ANGER  = {5,95,98,99,100,148,149,150,228, 987,988,989,990,991,992,993,994,995,999},
                   SCARE  = {986},
                   DIG    = {91}
                  }
local REACTPRIORITY = {
                       NONE   = 0,
                       PLAYER = 2,
                       FOLLOW = 1,
                       DIG    = 3,
                       ANGER  = 4,
                       SCARE  = 5
                      }
local REACTDIST = {
                   NONE   = 0,
                   PLAYER = 400,
                   FOLLOW = 400,
                   DIG    = 400,
                   ANGER  = 600,
                   SCARE  = 600
                  }
local REACTBARKS = {
                    NONE   = {"bow","wow","woof"},
                    PLAYER = {"bow","wow","woof","pant"},
                    FOLLOW = {"bow","wow","woof","pant"},
                    DIG    = {"sniff","pant"},
                    ANGER  = {"growl"},
                    SCARE  = {"whimper","whine"}
                   }
local REACTBARKS2 = {
                     NONE   = {"bark","bark2","woof"},
                     PLAYER = {"bow","wow","woof","pant"},
                     FOLLOW = {"bow","wow","woof","pant"},
                     DIG    = {"woof","sniff","bow","wow"},
                     ANGER  = {"snarl","bark","bark2"},
                     SCARE  = {"whimper","whine","yip"}
                   }

-- generate list of all ids to react to + lookup table in which k = npc id and v = type of reaction
local REACTIDS = {}
local REACTTYPES = {}
for k1,v1 in pairs(REACTIONS) do
	for _,v2 in pairs(v1) do
		table.insert(REACTIDS, v2)
		REACTTYPES[v2] = k1
	end
end

local buriedNPCs = {};

function pal.onStart()
	for _,v in ipairs(NPC.get()) do
		v = pnpc.getExistingWrapper(v);
		if(v and v.data.buried == true) then
			if(v.id == 979 and SaveData.chests[Level.filename()][tostring(v.data.chestid)]) then --Don't let pal dig up chests you've already opened
				v:kill(9);
			else
				table.insert(buriedNPCs, v);
				v.isHidden = true;
			end
		end
	end
end

function pal.onNPCKill(event, npc, reason)
	if(npc.id == palSettings.id) then
		event.cancelled = true;
	end
end


-- Utility functs (feel free to outsource some of these to another API)
local function clearShot (objA,objB)
	local x1,y1,x2,y2 = objA.x,objA.y, objB.x,objB.y

	if  not (x1 == nil  or  x2 == nil  or  y1 == nil  or  y2 == nil)  then
		if  objA.width ~= nil  then
			x1 = x1+objA.width*0.5
			y1 = y1+objA.height*0.5
		end
		if  objB.width ~= nil  then
			x2 = x2+objB.width*0.5
			y2 = y2+objB.height*0.5
		end

		return true--colliders.linecast({x1,y1},{x2,y2},colliders.BLOCK_SEMISOLID)
	else
		return false
	end
end

local function objDirection (objA,objB)
	local x1,x2 = objA.x,objB.x

	if  not (x1 == nil  or  x2 == nil)  then
		if  objA.width ~= nil  then
			x1 = x1+objA.width*0.5
		end
		if  objB.width ~= nil  then
			x2 = x2+objB.width*0.5
		end

		if  x1 > x2  then
			return DIR_LEFT
		else
			return DIR_RIGHT
		end
	else
		return nil
	end
end

local function objDistance (objA,objB)
	local x1,y1,x2,y2 = objA.x,objA.y, objB.x,objB.y

	if  not (x1 == nil  or  x2 == nil  or  y1 == nil  or  y2 == nil)  then
		if  objA.width ~= nil  then
			x1 = x1+objA.width*0.5
			y1 = y1+objA.height*0.5
		end
		if  objB.width ~= nil  then
			x2 = x2+objB.width*0.5
			y2 = y2+objB.height*0.5
		end

		local dist = math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
		return dist
	else
		return math.huge
	end
end

local function setPalState(npcRef, type, funct)
	if  npcRef == nil  then  return;  end;
	local data = npcRef.data.pal

	if  data[type].state ~= funct  then
		if  data[type].cor ~= nil  then
			eventu.abort(data[type].cor)
		end
		data[type].state = funct
		_,data[type].cor = eventu.run(funct,npcRef)
	end
end
local function setPalMoveState(npcRef, funct)
	setPalState(npcRef, "move", funct)
end
local function setPalAnimState(npcRef, funct)
	setPalState(npcRef, "anim", funct)
end


-- ANIMATION ROUTINES
local ANIM = {}

ANIM.STAND = function(npcRef)
	while (true) do
		local data = npcRef.data.pal
		data.anim.frame = 1
		if  data.bark.mouthOpen  then
			data.anim.frame = 2
		end
		eventu.waitFrames(0)
	end
end

ANIM.ANGER = function(npcRef)
	while (true) do
		local data = npcRef.data.pal
		data.anim.frame = 18
		if  data.bark.mouthOpen  then
			data.anim.frame = 2
		end
		eventu.waitFrames(0)
	end
end

ANIM.WORRY = function(npcRef)
	while (true) do
		local data = npcRef.data.pal
		data.anim.frame = 17
		if  data.bark.mouthOpen  then
			data.anim.frame = 2
		end
		eventu.waitFrames(0)
	end
end

ANIM.SCARE = function(npcRef)
	while (true) do
		local data = npcRef.data.pal
		data.anim.frame = 19
		if  data.bark.mouthOpen  then
			data.anim.frame = 2
		end
		eventu.waitFrames(0)
	end
end

ANIM.WALK = function(npcRef)
	local x1,y1 = rng.random(10,790), rng.random(10,590)
	local data = npcRef.data.pal
	while (true) do
		for i=0,2 do
			data.anim.frame = 1 + 2*i
			if  data.bark.mouthOpen  then
				data.anim.frame = data.anim.frame+1
			end

			--Graphics.draw {type=RTYPE_TEXT, x=x1, y=y1, text="WALK"}
			eventu.waitFrames(math.max(3, 2*(4-math.abs(npcRef.speedX))))
		end
	end
end

ANIM.AIR = function(npcRef)
	local data = npcRef.data.pal
	while (true) do
		data.anim.frame = 1
		if  npcRef.speedY < 0  then
			data.anim.frame = 3
		elseif  npcRef.speedY > 0  then
			data.anim.frame = 5
		end

		if  data.bark.mouthOpen  then
			data.anim.frame = data.anim.frame+1
		end
		eventu.waitFrames(0)
	end
end

ANIM.DIG = function(npcRef)
	local data = npcRef.data.pal 
	while (true) do
		data.anim.frame = 14
		eventu.waitFrames (pal.settings.framespeed*0.5)

		data.anim.frame = 15
		-- dirt particle
		eventu.waitFrames (pal.settings.framespeed*0.5)

		data.anim.frame = 16
		eventu.waitFrames (pal.settings.framespeed*0.5)

		data.anim.frame = 13
		-- dirt particle
		eventu.waitFrames (pal.settings.framespeed*0.5)
	end
end

ANIM.SNIFF = function(npcRef)
	local data = npcRef.data.pal 
	while (true) do
		data.anim.frame = 9
		eventu.waitFrames (pal.settings.framespeed*0.5)

		data.anim.frame = 10
		eventu.waitFrames (pal.settings.framespeed*0.5)
	end
end

ANIM.TARGETBARK = function(npcRef)
	local data = npcRef.data.pal 
	while (true) do
		data.anim.frame = 9
		if  data.bark.mouthOpen  then
			data.anim.frame = 2
		end
		eventu.waitFrames (pal.settings.framespeed*0.5)

		data.anim.frame = 10
		if  data.bark.mouthOpen  then
			data.anim.frame = 2
		end
		eventu.waitFrames (pal.settings.framespeed*0.5)
	end
end

ANIM.WAG = function(npcRef)
	local data = npcRef.data.pal 
	while (true) do
		data.anim.frame = 11
		eventu.waitFrames (pal.settings.framespeed*0.5)

		data.anim.frame = 12
		eventu.waitFrames (pal.settings.framespeed*0.5)
	end
end

ANIM.SLEEP = function(npcRef)
	local data = npcRef.data.pal 
	while (true) do
		data.anim.frame = 7
		-- emit z particle
		eventu.waitFrames (pal.settings.framespeed*8)

		data.anim.frame = 8
		eventu.waitFrames (pal.settings.framespeed*8)
	end
end

ANIM.LOOK = function(npcRef)
	local data = npcRef.data.pal 
	while (true) do
		-- Look away from camera
		data.anim.frame = 20
		eventu.waitFrames (pal.settings.framespeed*2)

		-- Look behind
		data.anim.frame = 1
		eventu.waitFrames (pal.settings.framespeed*0.5)
		data.anim.frame = 21
		eventu.waitFrames (pal.settings.framespeed*0.5)
		data.anim.frame = 22
		eventu.waitFrames (pal.settings.framespeed*2)

		-- Look forward
		data.anim.frame = 21
		eventu.waitFrames (pal.settings.framespeed*0.5)
		data.anim.frame = 1
		eventu.waitFrames (pal.settings.framespeed*2)
	end
end


-- MOVEMENT ROUTINES
local MOVE = {}

MOVE.ROAM = function(npcRef)
	local dir = -1
	local sleepCounter = 0
	local data = npcRef.data.pal

	data.follow.distance = math.huge
	data.follow.target   = nil
	data.follow.type     = nil
	data.follow.react    = "NONE"
	data.follow.timer    = 0


	npcRef:mem(0x136, FIELD_WORD, 0)
	data.friction = 0
	data.accel = 0
	data.bark.active = false

	while (sleepCounter < 5) do
		-- Turn around randomly or if too far from home position
		local changedDir = false
		if  rng.random(1) < 0.5  then
			dir = -dir
			changedDir = true
		end
		if  objDistance(npcRef, data.homePos) > 256  then
			if  npcRef.x < data.homePos.x  then  dir = 1;   end;
			if  npcRef.x > data.homePos.x  then  dir = -1;  end;
			changedDir = true
		end

		npcRef.direction = DIR_LEFT
		if  dir == 1  then  npcRef.direction = DIR_RIGHT;  end;
		if  changedDir  then
			eventu.waitFrames(lunatime.toTicks(rng.random(0.25,0.75)))
		end

		-- Walk forward
		npcRef.speedX = dir*rng.random(1,2)
		setPalAnimState(npcRef, ANIM.WALK)
		eventu.waitFrames(lunatime.toTicks(rng.random(0.5,1.5)))

		-- Stop, sometimes look around
		npcRef.speedX = 0
		setPalAnimState(npcRef, ANIM.STAND)
		if  rng.random(1) < 0.5  then
			setPalAnimState(npcRef, ANIM.LOOK)
		end
		eventu.waitFrames(lunatime.toTicks(rng.random(1,3)))
		while (data.anim.frame ~= 1)  do
			eventu.waitFrames(0)
		end

		sleepCounter = sleepCounter + 1
	end

	setPalMoveState(npcRef, MOVE.SLEEP)
end

MOVE.FOLLOW = function(npcRef)
	local data = npcRef.data.pal

	-- Leap with excitement
	data.bark.active = false
	npcRef.speedX = 0
	while  (not data.move.grounded)  do
		eventu.waitFrames(0)
	end

	setPalAnimState(npcRef, ANIM.AIR)
	npcRef.speedY = -4
	eventu.waitFrames(1)


	-- Turn toward the target
	if  data.follow.target.isValid  then
		npcRef.direction = objDirection(npcRef, data.follow.target)
	end
	eventu.waitFrames(30)


	-- Begin following the target
	while (data.follow.target ~= nil) do

		-- Standing is default animation
		local currentAnim = ANIM.STAND

		-- Determine the type of reaction and the distance to stop at
		if  data.move.grounded  then
			npcRef.speedX = 0
		end

		if  data.follow.target.isValid  then
			local stopDist = 64
			local rType = data.follow.react
			local dirToTarget = objDirection(npcRef, data.follow.target)
			npcRef.direction = objDirection(npcRef, data.follow.target)
			
			if  data.follow.type == "npc"  then
				rType = REACTTYPES[data.follow.target.id];
				if(data.follow.target.data.buried == true) then
					rType = "DIG"
				end
			end
			if  rType == "DIG"    then  stopDist = 24;   end;
			if  rType == "SCARE"  then  stopDist = 256;  end;
			if  rType == "ANGER"  then  stopDist = 128;  end;


			-- When at the right distance, behave according to the reaction type
			if  data.follow.distance > stopDist-8  and  data.follow.distance < stopDist+8  and  math.abs(data.follow.target.y+(data.follow.target.height or 0)*0.5 - (npcRef.y + npcRef.height*0.5)) < stopDist+8  then

				if  rType == "DIG"    then  data.startDigging = true;                            end;
				if  rType == "SCARE"  then  currentAnim = ANIM.WORRY;  data.bark.active = true;  end;
				if  rType == "ANGER"  then  currentAnim = ANIM.ANGER;  data.bark.active = true;  end;


			-- When closer than the stop distance, move based on reaction type
			elseif  data.follow.distance < stopDist  then

				if  rType == "SCARE"  or  rType == "ANGER"  then
					if  rType == "SCARE"  then
						npcRef.animationFrame = npcRef.animationFrame + 22
					end

					npcRef.speedX = -(0.5 + 3.5 * (data.follow.distance/256))
					if  dirToTarget == DIR_LEFT  then
						npcRef.speedX = -npcRef.speedX
					end
				end
				--Graphics.draw {type=RTYPE_TEXT, isSceneCoordinates=true, x=npcRef.x, y=npcRef.y-32, text=rType.." ("..rType..", "..tostring(dirToTarget)..")"}


			-- When further than the stop distance, move based on reaction type
			else
				if rType == "SCARE"  then

				else
					npcRef.speedX = (0.5 + 3.5 * (data.follow.distance/256))
					if  dirToTarget == DIR_LEFT  then
						npcRef.speedX = -npcRef.speedX
					end
				end
			end


			-- Jump up to target if not scared
			if  rType ~= "SCARE"  and  (data.follow.target.y + data.follow.target.height - 32) < npcRef.y-8  and  data.move.grounded  then

				-- Jump based on a timer
				data.follow.jumptimer = data.follow.jumptimer - 1

				if  data.follow.jumptimer <= 0  then
					npcRef.speedY = math.min(24,npcRef.y-data.follow.target.y)*-0.3*rng.random(0.8, 1.2)
					data.follow.jumptimer = rng.random(10,30)
				end
			end
		end

		-- Handle animation
		if  data.move.grounded  then
			if  npcRef.speedX ~= 0  then
				currentAnim = ANIM.WALK
			end
		else
			currentAnim = ANIM.AIR
		end
		setPalAnimState(npcRef, currentAnim)

		-- Yield
		eventu.waitFrames(0)
	end


	-- When the target is no longer valid, begin roaming again
	setPalMoveState(npcRef, MOVE.ROAM)
end

local NPC_COIN = {10,138,258,88,33,103,252,251,253}
local NPC_COIN_MAP = table.map(NPC_COIN);

MOVE.DIG = function(npcRef)
	local data = npcRef.data.pal

	-- Stop moving and start sniffing
	npcRef.speedX = 0
	setPalAnimState (npcRef, ANIM.SNIFF)
	eventu.waitFrames (pal.settings.framespeed*4)

	-- Start digging
	setPalAnimState (npcRef, ANIM.DIG)
	eventu.waitFrames (pal.settings.framespeed*7)

	-- Pluck the NPC
	local npcToSpawn = data.follow.target.ai1
	local newNpc;
	if  (npcToSpawn ~= nil)  then
		if(npcToSpawn > 0) then --is a container
			data.follow.target:kill()
			newNpc = NPC.spawn (npcToSpawn, data.follow.target.x+data.follow.target.width*0.5, data.follow.target.y-17, player.section, true, true)
		else
			data.follow.target.isHidden = false;
			data.follow.target.data.buried = nil;
			newNpc = data.follow.target;
			data.follow.target = nil;
		end
		if(newNpc.id == 979) then --chest
			newNpc.speedY = -3
		else
			newNpc.speedY = -8
			newNpc.speedX = rng.random(-2,2)
		end
		
		if(NPC_COIN_MAP[newNpc.id]) then
			newNpc.ai1 = 1;
		end
	end

	Audio.playSFX(9);

	-- reset the follow data
	data.follow.distance = math.huge
	data.follow.target   = nil
	data.follow.type     = nil
	data.follow.react    = "NONE"
	data.follow.timer    = 1

	-- Pal feels accomplished
	setPalAnimState (npcRef, ANIM.WAG)
	eventu.waitFrames (pal.settings.framespeed*8)

	-- Go back to roaming
	setPalMoveState (npcRef, MOVE.ROAM)
end


MOVE.HELD = function(npcRef)
	local data = npcRef.data.pal
	npcRef.speedX = 0
	npcRef.data.accel = 0
	while (true) do

		data.bark.active = false
		if  data.follow.target ~= nil  then

			-- Barking frequency based on proximity to target
			if  data.follow.distance < 2560  then
				data.bark.active = true
				data.bark.freq = math.max(20, math.min(data.follow.distance*0.25, 240))
			end

			-- Different animations based on different target reactions
			local currentAnim = ANIM.STAND
			local dirToTarget = objDirection(npcRef, data.follow.target)

			if  REACTPRIORITY[data.follow.react] > REACTPRIORITY.DIG  then
				npcRef.direction = dirToTarget  or  player.direction
				if  data.follow.react == "SCARE"  then
					currentAnim = ANIM.WORRY
					if  data.follow.distance < 64  then  currentAnim = ANIM.SCARE;  end;
				end
				if  data.follow.react == "ANGER"  then  currentAnim = ANIM.ANGER;  end;
			end

			setPalAnimState (npcRef, currentAnim)
		end
		eventu.waitFrames(0)
	end
end

MOVE.AIR = function(npcRef)
	setPalAnimState (npcRef, ANIM.AIR)
	npcRef:mem(0x12C, FIELD_WORD, 0)

	local data = npcRef.data.pal

	data.bark.active = false
	data.friction = 0
	data.accel = 0
	while (true) do

		--[[
		if  npcRef:mem(0x0A, FIELD_WORD) == 2  then
			if  npcRef.speedY == 0  then
				data.friction = 0.1
			end

			if  math.abs(npcRef.speedX) <= 0.5  then
				setPalMoveState (npcRef, MOVE.ROAM)
			end
		end
		]]
		eventu.waitFrames(0)
	end
end


MOVE.SCARERUN = function(npcRef)
	setPalAnimState(npcRef, ANIM.WALK)
	if  npcRef.direction == DIR_LEFT  then
		npcRef.speedX = 4
	else
		npcRef.speedX = -4
	end
end

local scaredOfCatllamas = false
MOVE.SPITOUT = function(npcRef)
	--eventu.waitFrames(4)
	while (npcRef:mem(0x138, FIELD_WORD) == 5) do
		player:mem(0xFE, FIELD_BOOL, not player:mem(0xFE, FIELD_BOOL))
		eventu.waitFrames(1)
	end
	if  not scaredOfCatllamas  then
		scaredOfCatllamas = true
		for  k,v in pairs {95,98,99,100,148,149,150,228}  do
			table.insert(REACTIONS.SCARE, v)
			REACTTYPES[v] = "SCARE"
		end
	end
	setPalMoveState (npcRef, MOVE.SCARERUN)
end

MOVE.SLEEP = function(npcRef)
	local data = npcRef.data.pal

	-- Start moving
	setPalAnimState(npcRef, ANIM.WALK)
	data.accel = rng.randomEntry({-0.2, 0.2})
	eventu.waitFrames(8)

	-- Turn a few times
	for  i=1,3  do
		data.accel = -data.accel
		eventu.waitFrames(16)
	end

	-- Stop
	data.friction = math.abs(data.accel)
	data.accel = 0
	setPalAnimState(npcRef, ANIM.SNIFF)
	while  (npcRef.speedX ~= 0)  do
		eventu.waitFrames(0)
	end

	-- Sleep
	data.friction = 0
	setPalAnimState(npcRef, ANIM.SLEEP)
end


-- Per-tick stuff
function pal:onTickNPC()

	-- Initialize data table
	if self.data.pal == nil  then
	    self.data.pal = {
	                     move = {
	                             state    = nil,
	                             grounded = true,
	                             cor      = nil
	                            },
	                     anim = {
	                             state    = nil,
	                             cor      = nil,
	                             frame    = 1
	                            },
	                     accel        = 0,
	                     friction     = 0,
	                     startDigging = false,
	                     bark         = {
	                                     active    = false,
	                                     mouthOpen = false,
	                                     freq      = 20,
	                                     timer     = 0,
	                                    },
	                     follow       = {target=nil, distance=9999, maxdist=128, type=nil, react="NONE", timer=1, jumptimer=1},
	                     homePos      = {x=self.x,y=self.y}
	                    }
		setPalMoveState (self, MOVE.ROAM)
		setPalAnimState (self, ANIM.STAND)
	end

	local data = self.data.pal


	-- If Pal is despawned, then
	if  self:mem(0x12A, FIELD_WORD) <= 0  then
		data.bark.active = false
		if  data.move.state ~= MOVE.ROAM  then
			setPalMoveState (self, MOVE.ROAM)
			setPalAnimState (self, ANIM.STAND)
		end

	else
		-- Stubborn following coroutine stopgap
		if  data.startDigging  then
			data.startDigging = false
			setPalMoveState (self, MOVE.DIG)
		end
		
		for i=#buriedNPCs,1,-1 do
			if(not buriedNPCs[i].isValid or buriedNPCs[i].data.buried ~= true) then
				table.remove(buriedNPCs,i);
			end
		end

		-- Manage follow targeting
		local allTargets = table.append ({player}, buriedNPCs, NPC.get(REACTIDS, player.section))
		local closestDist = data.follow.maxdist
		local closestTarget = nil
		local closestType = nil
		local closestReact = "NONE"
		for  _,v in ipairs(allTargets)  do

			-- Determine validity based on object type
			local isValid = false
			local targetType = nil
			local reactType  = nil

			if  v.__type == "NPC"  then
				-- if it's an NPC, the NPC must not be hidden unless it's something to dig up
				v = pnpc.wrap(v)
				isValid = (not v:mem(0x40, FIELD_BOOL)  or  v.data.buried == true)
				if  isValid  then
					targetType = "npc"
					reactType = REACTTYPES[v.id]
					if  v.data.buried == true  then
						reactType = "DIG"
					end
				end
			else
				-- if it's the player, automatically valid unless being held
				if data.move.state ~= MOVE.HELD  then
					isValid = true
					targetType = "player"
					reactType = "PLAYER"

					-- If the player is riding a catllama, become angry (or scared if the player tried to eat him)
					if  v:mem(0x108, FIELD_WORD) == 3  then
						targetType = "player"
						reactType = "ANGER"
						if  scaredOfCatllamas  then
							reactType = "SCARE"
						end
					end
				end
			end

			-- If the target is valid and there's a clear line of sight, 
			--   get the distance and check whether it's the closest/highest-priority thing so far
			if  isValid  and  clearShot(self,v)  then
				local isNew = false
				local dist = objDistance (self,v)
				local defDist = data.follow.maxdist or 128
				local typeDist = REACTDIST[reacttype] or 128

				if  dist <= math.max(defDist, typeDist)  and
					((dist <= closestDist  and  REACTPRIORITY[reactType] == REACTPRIORITY[closestReact])  or
					 (REACTPRIORITY[reactType] > REACTPRIORITY[closestReact]))                            then
					closestDist = dist
					closestTarget = v
					closestType = targetType
					closestReact = reactType
				end
			end
		end

		-- If there is not a valid target to follow, stick to the current one for two seconds, or half a second if carried
		if  closestTarget == nil  then
		
			if(data.move.state == MOVE.HELD) then
				data.follow.timer = (data.follow.timer + 1) % lunatime.toTicks(0.5)
			else
				data.follow.timer = (data.follow.timer + 1) % lunatime.toTicks(2)
			end

			-- If those two seconds are up, stop following
			if  data.follow.timer == 0  then
				data.follow.distance = math.huge
				data.follow.target   = nil
				data.follow.type     = nil
				data.follow.react    = "NONE"
				data.follow.timer    = 1
			end
		-- If there is a valid target to follow... well, follow it!
		else
			Graphics.draw {type=RTYPE_TEXT, x=closestTarget.x, y=closestTarget.y, text="T", isSceneCoordinates=true}
			data.follow.distance = objDistance(self, {x=closestTarget.x, y=self.y, width=closestTarget.width, height=self.height})
			data.follow.target   = closestTarget
			data.follow.type     = closestType
			data.follow.react    = closestReact
			data.follow.timer    = 1
		end


		-- Manage barking
		if  data.bark.active  then
			data.bark.timer = data.bark.timer + 1

			-- Perform bark
			if  data.bark.timer >= 0  then
				data.bark.mouthOpen = false
			end

			if  data.bark.timer >= data.bark.freq  then
				data.bark.timer = -10
				data.bark.mouthOpen = true

				local selectedList = REACTBARKS.NONE
				if  data.follow.react ~= nil  then
					selectedList = REACTBARKS[data.follow.react]
					if  data.follow.distance < 64  then
						selectedList = REACTBARKS2[data.follow.react]
					end
				end
				
				local selectedSound = rng.randomEntry(selectedList)
				audio.PlaySound{sound = Misc.resolveFile("sound/voice/pal/v-pal-"..selectedSound..".ogg"), volume = rng.random(0.4,0.5)}
				-- sound effect
			end
		else
			data.bark.timer = 0
			data.bark.mouthOpen = false
		end


		-- Natural state transitions
		data.follow.maxdist = 256

			-- SLEEPING
			if      data.move.state == MOVE.SLEEP  then
				-- wake up if the player runs, lands or picks up

			-- ROAMING
			elseif  data.move.state == MOVE.ROAM   then

				-- If a target is found, switch to follow mode
				if  data.follow.target ~= nil  then
					setPalMoveState(self, MOVE.FOLLOW)
				end

			-- FOLLOWING
			elseif  data.move.state == MOVE.FOLLOW   then
				data.bark.freq = rng.randomInt (20,65)

			-- LANDING
			elseif  data.move.state == MOVE.AIR  then
				if  data.move.grounded  then
					self.speedX = self.speedX * 0.75
					
					if  math.abs(self.speedX) < 0.5  then
						setPalMoveState(self, MOVE.ROAM)
					end
				end
			end


		-- Forced state transitions
			-- THROWING
			if  data.move.state == MOVE.HELD  then
				if  self:mem(0x12E, FIELD_WORD) < 30  then
					setPalMoveState(self, MOVE.AIR)
				end

			-- PICKING UP
			elseif  self:mem(0x12C, FIELD_WORD) > 0  then  -- If being held by a player
				setPalMoveState(self, MOVE.HELD)
				data.follow.maxdist = 2560

			elseif  self:mem(0x138, FIELD_WORD) == 5  then  -- being eaten by a catllama		
				setPalMoveState(self, MOVE.SPITOUT)
			end




		-- Manage physics
		data.move.grounded = (self:mem(0x0A, FIELD_WORD) == 2)

		if  data.accel ~= 0  then
			self.speedX = self.speedX + data.accel
		end
		if  data.friction ~= 0  then
			if  math.abs(self.speedX) < data.friction  then
				self.speedX = 0
			else
				self.speedX = self.speedX - (self.speedX/math.abs(self.speedX))*data.friction
			end
		end


		-- Manage animation
		self.animationFrame = data.anim.frame-1;
		if  self.direction == DIR_RIGHT  then
			self.animationFrame = self.animationFrame + 22
		end
		self.animationTimer = 2;
	end
end





function a2xt_message.onMessage(npc, text)
	if(npc ~= nil) then
		if(npc.id == blackmarket.settings.id) then
			blackmarket.onMessage(npc)
		elseif(pengData[npc.id]) then
			pengs.onMessage(npc,id);
		end
	end
end

function a2xt_message.onMessageEnd(npc)
	if(npc and npc.isValid) then
		local id = npc.id;
		if(pengData[id]) then
			pengs.onMessageEnd(npc, id);
		elseif(id == blackmarket.settings.id) then
			blackmarket.onMessageEnd(npc);
		end
	end
end




return friendlies