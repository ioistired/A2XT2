local imagic = API.load("imagic")
local eventu = API.load("eventu")
local particles = API.load("particles")
local colliders = API.load("colliders")
local rng = API.load("rng")
local pblock = API.load("pblock")
local textblox = API.load("textblox")

local leveldata = API.load("a2xt_leveldata")
local message = API.load("a2xt_message")
local scene = API.load("a2xt_scene")
local archives = API.load("a2xt_archives")
local bgm = API.load("a2xt_bgm")

local pendSpr = Graphics.loadImage("pendulum.png")
local reflections = Graphics.CaptureBuffer(800,600);

local sanctuary = API.load("a2xt_leeksanctuary");
sanctuary.world = 3;


Block.config[1262].frames = 4;

local leekjuice = Graphics.loadImage("leek juice.png");
local leekjuicecap = Graphics.loadImage("leek juice cap.png");
local leekbackground = Graphics.loadImage("funnel-bg.png");

local gears = {};
local gearsOnLift = {};
local liftGearPlatform = nil;
local liftGear = Graphics.loadImage("liftGear.png");
local liftRailGear = Graphics.loadImage("liftRailGear.png");

local railGear = {t = 32, f = 0}
local liftCollider = colliders.Box(0,0,7*32,8);
local liftTimer = 8;
local liftEvent = nil;

local SUPER_LEEKS = 3; --TEMP: Replace with global value

local bubbletarget = Graphics.CaptureBuffer(48, 208);
local leekbubbles = particles.Emitter(24, 208-12, Misc.resolveFile("p_leekjuice.ini"));

local leekRewardZones = {};


local slotStrip = Graphics.loadImage("iconstrip.png")
local slotw9 = Graphics.loadImage("../graphics/hud/worlds/world9.png")

local slotMachine = {}
local slotzebra = {false,false,false}
local slotTitle;

local currentSlotRoutine;

local function shuffleSlots()
	for i = 1,3 do
		local id = rng.randomInt(1,7);
		
		--World 6 has no icon because corrupted spacetime, so skip it
		if(id >= 6) then
			id = id+1;
		end
		slotMachine[i] = id;
	end
	slotTitle = nil;
end


local function cycleSingleSlot(i, amt)
		local id = slotMachine[i] + (amt or 1);
		if(id >= 6 and id <= 7) then
			id = id+1;
		end
		if(id > 8) then
			id = id-8;
		end
		slotMachine[i] = id;
end

local function cycleSlots(startidx, amt)
	for i = startidx,3 do
		cycleSingleSlot(i,amt);
	end
end

local function resetSlots()
	if(currentSlotRoutine ~= nil) then
		eventu.abort(currentSlotRoutine);
		currentSlotRoutine = nil;
	end
	shuffleSlots();
	slotTitle = nil;
	slotzebra = {false,false,false}
end

local function cor_doSlots(target)
	if(target == 6) then
		local id = 1;
		local t = 48;
		local err = 8;
		
		
		for i = 1,48 do
			cycleSlots(1, 0.5)
			eventu.waitFrames(1);
		end
		
		local spd = 0.05;
		for i = 1,47 do
			cycleSingleSlot(1, spd)
			if(i % 4 == 0) then
				spd = spd*-1;
			end
			cycleSlots(2, 0.5)
			eventu.waitFrames(1);
		end
		
		slotTitle = "<lt>ERROR<gt>"
		
		local i = 48;
		while(true) do			
			i = i+1;
			cycleSingleSlot(1, spd)
			if(i % 4 == 0) then
				spd = spd*-1;
			end
			cycleSingleSlot(2, 0.05)
			eventu.waitFrames(1);
			if(i < 96) then
				cycleSingleSlot(3, 0.5*(1-(i-48)/48))
			elseif(i == 128) then
				slotTitle = "WTF";
			elseif(i == 160) then
				slotTitle = "U dUN GooOo0oFfeEd";
			elseif(i == 192) then
				slotTitle = "Epochalypse";
			elseif(i >= 224) then
				slotTitle = leveldata.GetWorldName(target)
			end
		end
		
	elseif(target == 9) then
		local id = 1;
		local t = 48;
		while(id <= 3) do
			cycleSlots(id, 0.5)
			eventu.waitFrames(1);
			cycleSlots(id, 0.5)
			eventu.waitFrames(1);
			
			t = t-4;
			if(t <= 0) then
				slotzebra[id] = true;
				id = id + 1;
				t = 48;
				eventu.waitFrames(2);	
			else
				cycleSlots(id, 0.5)
				eventu.waitFrames(1);
				cycleSlots(id, 0.5)
				eventu.waitFrames(1);
			end
		end
		eventu.waitFrames(48);
		slotTitle = leveldata.GetWorldName(target);
	else
		local id = 1;
		local t = 48;
		while(id <= 3) do
			cycleSlots(id, 0.5)
			eventu.waitFrames(1);
			cycleSlots(id, 0.5)
			eventu.waitFrames(1);
			
			t = t-4;
			if(t <= 0 and slotMachine[id] == target) then
				id = id + 1;
				t = 48
				eventu.waitFrames(2);	
			else
				cycleSlots(id, 0.5)
				eventu.waitFrames(1);
				cycleSlots(id, 0.5)
				eventu.waitFrames(1);
			end

		end
		eventu.waitFrames(48);
		slotTitle = leveldata.GetWorldName(target);
	end
	
	currentSlotRoutine = nil;
end

shuffleSlots();

local function doSlots(world)
	if(currentSlotRoutine ~= nil) then
		eventu.abort(currentSlotRoutine);
	end

	_,currentSlotRoutine = eventu.run(cor_doSlots, world);
end

--TODO: Remove this. This is just for testing the slot machine
eventu.run(function() eventu.waitSeconds(6); doSlots(6); eventu.waitSeconds(6); resetSlots() end)

local function archiveSectionPages (args, group, folderName)
	local talker = args.npc

	message.promptChosen = false
	message.showMessageBox {target=talker, text="<gt>Accessing "..folderName.."...<pause 0.1>", type="system", closeWith="prompt"}
	message.waitMessageDone();

	-- Set up prompt
	local keys,names,bios = archives.GetUnlockedBios(group)

	local namePages = {}
	if  #names > 8  then
		for i=1,#names  do
			--windowDebug(names[i]..":\n\n"..bios[i])
			local pageNum = math.floor(i/8)+1
			if  namePages[pageNum] == nil  then  namePages[pageNum] = {};  end;
			table.insert(namePages[pageNum], names[i])
		end
	else
		namePages = {names}
	end


	-- Begin prompt loop
	local loopBroken = false
	local currentPage = 1

	while  (not loopBroken)  do

		-- Set up page controls and cancel option
		local extraOptions = {}
		local nextNum = -1
		local prevNum = -1
		local cancelNum = -1

		if  #namePages > 1  then
			if  currentPage > 1  then
				extraOptions[#extraOptions+1] = "Previous page"
				prevNum = #extraOptions
			end
			if  currentPage < #namePages  then
				extraOptions[#extraOptions+1] = "Next page"
				nextNum = #extraOptions
			end
		end
		extraOptions[#extraOptions+1] = message.getCancelOption()
		cancelNum = extraOptions[#extraOptions]


		-- Call prompt
		local currentNames = namePages[currentPage]

		message.promptChosen = false
		message.showPrompt{options=table.append(currentNames, extraOptions), sideX=-1}
		message.waitPrompt()


		-- If the player has chosen a character name, show the bio
		if  message.promptChoice <= #currentNames  then
			local keyIndex = (currentPage-1)*8 + message.promptChoice
			local key = keys[keyIndex]

			archives.UpdateBioReadExtent(group,key)
			names[keyIndex] = archives.GetBioProperty (group,key,"name")
			namePages[currentPage][message.promptChoice] = names[keyIndex]

			message.showMessageBox{target=talker, text=bios[keyIndex], type="system", bloxProps={autosizeRatio=10/3}}
			message.waitMessageEnd()

		-- Otherwise, if the player cancelled
		elseif  message.promptChoice == #currentNames + #extraOptions  then
			loopBroken = true

		-- Otherwise
		else
			local extraNum = message.promptChoice-#currentNames

			-- If the player has chosen next page
			if extraNum == nextNum  then
				currentPage = currentPage+1

			-- If the player has chosen previous page
			elseif  extraNum == prevNum  then
				currentPage = currentPage-1
			end

			message.promptChosen = false
			message.showMessageBox {target=talker, text="<gt>Accessing "..folderName.."...<pause 0.1>", type="system", closeWith="prompt"}
		end

		-- Yield
		eventu.waitFrames(0)
	end
	names[#names+1] = message.getCancelOption()

	message.endMessage();
	scene.endScene();
end

local function archiveSection (args, group, folderName)
	local talker = args.npc

	message.promptChosen = false
	message.showMessageBox {target=talker, text="<gt>Accessing "..folderName.."...<pause 0.1>", type="system", closeWith="prompt"}
	message.waitMessageDone();

	-- Set up prompt
	local keys,names,bios = archives.GetUnlockedBios(group)
	local optionTable = table.append(names, {message.getCancelOption()})


	-- Begin prompt loop
	local loopBroken = false
	local currentPage = 1

	while  (not loopBroken)  do

		-- Call prompt
		message.promptChosen = false
		message.showPrompt{options=optionTable, optionsShown=8, sideX=-1}
		message.waitPrompt()


		-- If the player cancelled
		if  message.promptChoice == #optionTable  then
			loopBroken = true

		-- Otherwise, if the player has chosen a character name, show the bio
		else
			local keyIndex = message.promptChoice
			local key = keys[keyIndex]

			archives.UpdateBioReadExtent(group,key)
			names[keyIndex] = archives.GetBioProperty (group,key,"name")
			optionTable[message.promptChoice] = names[keyIndex]

			message.showMessageBox{target=talker, text=bios[keyIndex], type="system", bloxProps={autosizeRatio=10/3}}
			message.waitMessageEnd()
		end

		-- Yield
		eventu.waitFrames(0)
	end

	message.endMessage();
	scene.endScene();
end




message.presetSequences.MessageTest = function(args)
	local talker = args.npc

	message.showMessageBox {target=talker, text="Testing sign messages.", type="sign"}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing bubble messages."}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing system messages.", type="system"}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing boxless messages.", type="textonly"}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing intercom messages.", type="intercom"}
	message.waitMessageEnd();

	message.endMessage();
	scene.endScene();
end


message.presetSequences.archiveDebug = function(args)
	local talker = args.npc

	message.promptChosen = false
	message.showMessageBox {target=talker, text="<gt>Accessing admin tools...<pause 0.1>", type="system", closeWith="prompt"}
	message.waitMessageDone();


	-- Set up the prompt
	local optionsList = {"Reset notifications", "Reset world override"}
	for  i=2,10  do
		optionsList[#optionsList+1] = "Set world override to "..tostring(i)
	end
	local cancelNum = -1
	optionsList[#optionsList+1] = message.getCancelOption()
	cancelNum = #optionsList


	-- Show the prompt
	message.showPrompt{options=optionsList, sideX=-1}
	message.waitPrompt()

	-- Reset notifications
	if  message.promptChoice == 1  then
		message.showMessageBox {target=talker, text="<gt>All profile notifications reset.", type="system"}
		message.waitMessageEnd();

		SaveData.biosRead = {}

	-- Reset override
	elseif  message.promptChoice == 2  then
		message.showMessageBox {target=talker, text="<gt>World assumption reset.", type="system"}
		message.waitMessageEnd();
		archives.SetBioDebugWorld(nil)

	-- Cancel
	elseif  message.promptChoice == cancelNum  then
		

	-- Set override
	else
		message.showMessageBox {target=talker, text="<gt>Assuming the player is in world "..tostring(message.promptChoice-1)..".  All bios up to this world are now unlocked.", type="system"}
		message.waitMessageEnd();
		archives.SetBioDebugWorld(message.promptChoice-1)
	end

	message.endMessage();
	scene.endScene();
end

message.presetSequences.archiveChars = function(args)
	return archiveSection (args, "characters", "character profiles")
end

message.presetSequences.archiveSpecies = function(args)
	return archiveSection (args, "species", "specie files")
end

message.presetSequences.archiveLocales = function(args)
	return archiveSection (args, "locations", "universal atlas")
end

message.presetSequences.archiveEpochs = function(args)
	return archiveSection (args, "epochs", "epoch data")
end

message.presetSequences.archiveEvents = function(args)
	return archiveSection (args, "events", "event records")
end

message.presetSequences.archiveTerms = function(args)
	return archiveSection (args, "terms", "glossary")
end

message.presetSequences.jukebox = function(args)
	return message.presetSequences.jukeboxNormal(args)
end


local retconEdges = {};


function onStart()
	for  i=0,1  do
		SaveData["world"..i].unlocked=true
		SaveData["world"..i].superleek=true
	end
	SaveData["world2"].unlocked=true
	
	for _,v in ipairs(Block.get(1262, 2)) do
		if(v.layerName == "RETCONLift") then
			v.layerName = nil;
			liftGearPlatform = pblock.wrap(v);
			liftGearPlatform.data.isLift = true;
		end
	end
	
	--Get gears
	for _,v in ipairs(BGO.get{21,22,16,17}) do
		v.isHidden = true;
		local t = { 
			img=imagic.Create
			{
				x=v.x+v.width*0.5, 
				y=v.y+v.height*0.5,
				width=v.width,
				height=v.height,
				primitive=imagic.TYPE_BOX,
				align=imagic.ALIGN_CENTRE,
				texture=Graphics.sprites.background[v.id].img,
				scene=true
			}
		}
		t.priority = -99;
		t.color = Color.grey;
		if(v.id == 16 or v.id == 17) then
			t.priority = -88;
			t.color = Color(0.8,0.8,0.8,1);
		end
		t.direction = 1;
		if(v.layerName == "CCWGears") then
			t.direction = -1;
			t.img:Rotate(-12)
		end
		table.insert(gears, t)
		if(v.layerName == "RETCONLift") then
			table.insert(gearsOnLift, t);
		end
	end
	
	--Get RETCON edge pieces
	do
		local txs = {}
		local vs = {}
		local idx = 1;
		for _,v in ipairs(Block.get(243, player.section)) do
			local x = v.x - 64;
			local y = v.y;
			
			for j = 0,v.height-32,32 do
				for i = 0,v.width+64-32,32 do
					vs[idx] = x + i;
					vs[idx+1] = y + j;
					vs[idx+2] = x + i + 32;
					vs[idx+3] = y + j;
					vs[idx+4] = x + i;
					vs[idx+5] = y + j + 32;
					vs[idx+6] = x + i;
					vs[idx+7] = y + j + 32;
					vs[idx+8] = x + i + 32;
					vs[idx+9] = y + j;
					vs[idx+10] = x + i + 32;
					vs[idx+11] = y + j + 32;
					
					local tx = 0;
					if(i >= 32) then
						if(i <= v.width) then
							tx = 0.33;
						else
							tx = 0.67;
						end
					end
					
					local ty = 0;
					if(j >= 32) then
						if(j < v.height-32) then
							ty = 0.33;
						else
							ty = 0.67;
						end
					end
					
					txs[idx] = tx;
					txs[idx+1] = ty;
					txs[idx+2] = tx+0.33;
					txs[idx+3] = ty;
					txs[idx+4] = tx;
					txs[idx+5] = ty+0.33;
					txs[idx+6] = tx;
					txs[idx+7] = ty+0.33;
					txs[idx+8] = tx+0.33;
					txs[idx+9] = ty;
					txs[idx+10] = tx+0.33;
					txs[idx+11] = ty+0.33;
					
					idx = idx + 12;
				end
			end
		end
		retconEdges.vs = vs;
		retconEdges.txs = txs;
	end

	
	--Get leek reward camera zones
	for _,v in ipairs(BGO.get(10, 3)) do
		for i = v.x+32, v.x+v.width-64, 32 do
			if i == v.x+32 or i == v.x+v.width-64 then
				for j = v.y, v.y+v.height-32, 32 do
					Block.spawn(1, i, j)
				end
			end
			Block.spawn(1, i, v.y-32)
		end
		
		table.insert(leekRewardZones, { x = v.x + v.width*0.5 - 400, y = v.y + v.height*0.5 - 300});
	end
	
end

function onLoadSection1(playerIndex)
	Audio.resetMciSections()
end


local gearAnimTimer = 6;
local GM_FRAME = readmem(0x00B2BEA0, FIELD_DWORD)

local function get_block_frame(id)
	return readmem(GM_FRAME + 2*(id-1), FIELD_WORD)
end
local function set_block_frame(id, v)
	return writemem(GM_FRAME + 2*(id-1), FIELD_WORD, v)
end

function onTick()
	for _,v in ipairs(gears) do
		v.img:Rotate(v.direction);
	end
	
	for _,v in ipairs(Block.get(1216, player.section)) do
		railGear.t = railGear.t - math.abs(v.layerObj.speedY);
		if(railGear.t <= 0) then
			railGear.f = 1-railGear.f;
			railGear.t = 32;
		end
		liftCollider.x = v.x - (3*32);
		liftCollider.y = v.y - liftCollider.height;
	end
	
	--THIS BE THE LIFT
	if(liftEvent == nil and player:isGroundTouching() and player.y + player.height <= liftCollider.y + liftCollider.height and colliders.collide(liftCollider, player)) then
		liftTimer = liftTimer - 1;
		if(liftTimer <= 0) then
			_,liftEvent = eventu.run(function()
				local t = 0;
				local layer = Layer.get("RETCONLift");
				
				local T = 1.5*64;
				local D = -576;
				local V = -24;
				local y = 0;
				
				while(true) do
					--layer.speedY = 3*D*t*t/(T*T*T);
					--layer.speedY = ((V*T - 2*D)/(T*T))*t*t*t + ((V + 6*D + 3*V*T)/(2*T))*t*t;
					layer.speedY = ((6*D*t*t)/(T*T)  +  ((3*V*t*t) + (6*D*t))/T  -  2*V*t)/(5*T); 
					t = t + 1;
					
					if(t == T) then
						layer.speedY = D-y;
					elseif(t > T) then
						layer:stop();
						
						break;
					end
					
					liftGearPlatform:translate(0,layer.speedY);
					liftGearPlatform.speedX = 4/7;
					y = y+layer.speedY;
					
					for _,v in ipairs(gearsOnLift) do
						v.img.y = y - 160288 + 48;
					end
					
					eventu.waitFrames(0);
				end
				t = 0;
				
				local timer = 8;
				
				while(true) do
					if(not colliders.collide(liftCollider, player)) then
						timer = timer - 1;
						if(timer <= 0) then
							break;
						end
					else
						timer = 8;
					end
					eventu.waitFrames(0);
				end
				
				eventu.waitFrames(32);
				
				while(true) do
					layer.speedY = -2*D*t/(T*T);
					t = t + 1;
					
					if(t == T) then
						layer.speedY = -y;
					elseif(t > T) then
						layer:stop();
						
						break;
					end
					
					liftGearPlatform:translate(0,layer.speedY);
					liftGearPlatform.speedX = 4/7;
					y = y+layer.speedY;
					
					for _,v in ipairs(gearsOnLift) do
						v.img.y = y - 160288 + 48;
					end
					
					eventu.waitFrames(0);
				end
				
				
				while(colliders.collide(liftCollider, player)) do
					eventu.waitFrames(0);
				end
				
				liftEvent = nil;
			end);
		end
	else
		liftTimer = 8;
	end
end

local function drawRetconEdges()
	
	Graphics.glDraw{vertexCoords = retconEdges.vs, textureCoords = retconEdges.txs, sceneCoords = true, texture = Graphics.sprites.block[243].img, priority=-89.9}
end

function onCameraUpdate(event, camidx)
	local c = Camera.get()[camidx];
	
	for _,v in ipairs(leekRewardZones) do
		if (player.x > v.x and player.y > v.y
		and player.x < v.x + 800 and player.y < v.y + 600) then
			c.x = v.x;
			c.y = v.y;
			break;
		end
	end
end

function onMessageBox(eventObj, msg)
	local s = msg:match("^You need (%d+) stars? to enter%.$");
	if(s) then
		eventObj.cancelled = true;
		if(s == "1") then
			s = s..CHAR_LEEK.." is required to unlock this door.";
		else
			s = s..CHAR_LEEK.." are required to unlock this door.";
		end
		
		message.talkToNPC(nil, s);
	end
end

local BLOCK_FRAME = readmem(0x00B2BEA0, FIELD_DWORD)
local function get_block_frame(id)
	return readmem(BLOCK_FRAME + 2*(id-1), FIELD_WORD)
end

function onDraw()

	drawRetconEdges();

	--Gear animation
	if gearAnimTimer > 0 then
		gearAnimTimer = gearAnimTimer -1;
	else
		gearAnimTimer = 6;
		set_block_frame(1262, (get_block_frame(1262)+1)%4)
	end

	--Gear fading for perspective
	local gearfadeverts = {}
	local gearfadecols = {}
	for _,v in ipairs(Block.get(1262, player.section)) do
	
		if(pblock.wrap(v).data.isLift) then
			Graphics.drawImageToSceneWP(liftGear, v.x, v.y, 0, 32*get_block_frame(v.id), 128, 32, -85)
		
		else
	
			v.speedX = 4/7;
			local x = v.x;
			local w = v.width*0.45;
			local a1 = 0.75;
			local a2 = 0;
			local la = a1;
			local ra = a2;
			for i = 1,2 do
			
				table.insert(gearfadeverts, x)		table.insert(gearfadeverts, v.y)
				table.insert(gearfadeverts, x+w)	table.insert(gearfadeverts, v.y)
				table.insert(gearfadeverts, x)		table.insert(gearfadeverts, v.y+v.height)
				table.insert(gearfadeverts, x)		table.insert(gearfadeverts, v.y+v.height)
				table.insert(gearfadeverts, x+w)	table.insert(gearfadeverts, v.y)
				table.insert(gearfadeverts, x+w)	table.insert(gearfadeverts, v.y+v.height)
				
				table.insert(gearfadecols, 0) table.insert(gearfadecols, 0)  table.insert(gearfadecols, 0)  table.insert(gearfadecols, la)
				table.insert(gearfadecols, 0) table.insert(gearfadecols, 0)  table.insert(gearfadecols, 0)  table.insert(gearfadecols, ra)
				table.insert(gearfadecols, 0) table.insert(gearfadecols, 0)  table.insert(gearfadecols, 0)  table.insert(gearfadecols, la)
				table.insert(gearfadecols, 0) table.insert(gearfadecols, 0)  table.insert(gearfadecols, 0)  table.insert(gearfadecols, la)
				table.insert(gearfadecols, 0) table.insert(gearfadecols, 0)  table.insert(gearfadecols, 0)  table.insert(gearfadecols, ra)
				table.insert(gearfadecols, 0) table.insert(gearfadecols, 0)  table.insert(gearfadecols, 0)  table.insert(gearfadecols, ra)
				
				
				local c = la;
				la = ra;
				ra = c;
				x = v.x+v.width - w;
			end	
		end
	end
	
	--Gear rail
	for _,v in ipairs(Block.get(1216, player.section)) do
		Graphics.drawImageToSceneWP(liftRailGear, v.x, v.y+16, 0, 32*railGear.f, 32, 32, -25)
	end
	
	Graphics.glDraw{vertexCoords = gearfadeverts, vertexColors = gearfadecols, sceneCoords = true, priority = -89}
	
	for _,v in ipairs(gears) do
		v.img:Draw(v.priority, v.color);
	end
	
	bubbletarget:clear(-89);
	leekbubbles:Draw(-89, true, bubbletarget, false);

	for _,v in ipairs(BGO.get(1, player.section)) do
		Graphics.drawImageToSceneWP(leekbackground, v.x, v.y, -89);
		
		local h = 24 + SUPER_LEEKS*36;
		local x = v.x;
		local y = v.y+v.height-h;
		local w = v.width;
		
		local ty1 = 1- (h/v.height)
		
		local verts = {x,y,x+w,y,x+w,y+h,x,y+h};
		local txs = {0,ty1,1,ty1,1,1,0,1};
		Graphics.glDraw{vertexCoords = verts, textureCoords = txs,
						primitive = Graphics.GL_TRIANGLE_FAN, texture = leekjuice, priority = -89, sceneCoords = true}
		
		Graphics.glDraw{vertexCoords = verts, textureCoords = txs,
						primitive = Graphics.GL_TRIANGLE_FAN, texture = bubbletarget, priority = -89, sceneCoords = true}
						
		Graphics.drawImageToSceneWP(leekjuicecap, v.x, y-6, -89)
	end
	
	--Slot machine		
	for _,v in ipairs(BGO.get(4, player.section)) do
		for i,w in ipairs(slotMachine) do
			local x = v.x+34+(i-1)*62;
			local y = v.y+102;
			if(slotzebra[i]) then
				Graphics.drawImageToSceneWP(slotw9, x, y, -40)
			else
				local ty1 = w-1;
				if(w > 6) then
					ty1 = ty1-1;
				end
				
				local ty2 = ty1+1;
				ty1 = ty1/7;
				ty2 = ty2/7;
				
				if(ty1 < 0) then
					Graphics.glDraw{vertexCoords = {x,y,x+32,y,x+32,y+32,x,y+32}, textureCoords = {0,ty1+1,1,ty1+1,1,ty2+1,0,ty2+1}, priority = -40, sceneCoords = true, texture = slotStrip, primitive = Graphics.GL_TRIANGLE_FAN}
				end
				
				Graphics.glDraw{vertexCoords = {x,y,x+32,y,x+32,y+32,x,y+32}, textureCoords = {0,ty1,1,ty1,1,ty2,0,ty2}, priority = -40, sceneCoords = true, texture = slotStrip, primitive = Graphics.GL_TRIANGLE_FAN}
			
			end
		end
		
		if(slotTitle ~= nil) then
			textblox.printExt(slotTitle, {x = v.x+20+92, y = v.y+24+18, width=176, font = textblox.FONT_SPRITEDEFAULT4X2, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_MID, z=-40, color=0x000000FF, bind=textblox.BIND_LEVEL})
		end
	end
	
	
	
	-- Pendulum section
	if  player.section == 0  then

		-- Pendulum
		local pendPercent = math.sin(math.rad(lunatime.tick()))
		imagic.Draw {primitive=imagic.TYPE_BOX, align=imagic.ALIGN_TOP,
		             color=0xFFFFFF00 + 32 + 32*(1-math.abs(pendPercent)),
		             x=-200000+400, y=-200600-150, priority=-95, scene=true,
		             width=pendSpr.width*2, height=pendSpr.height*2, 
		             texture=pendSpr, rotation=55*pendPercent}

		-- Reflection
		reflections:captureAt(-2);
		local cam = Camera.get()[1]
		local reflectY = -200160 - cam.y;
		local th = (reflectY/600);
		local stretchFactor = 1;
		local brightness = 0.1;
		Graphics.glDraw {
		                 vertexCoords = {0,reflectY,800,reflectY,800,600,0,600}, 
		                 textureCoords = {0,th,1,th,1,(th*2-1)*stretchFactor,0,(th*2-1)*stretchFactor}, 
		                 vertexColors = {brightness,brightness,brightness,0, brightness,brightness,brightness,0, 0,0,0,0, 0,0,0,0},
		                 primitive = Graphics.GL_TRIANGLE_FAN, 
		                 texture=reflections, 
		                 priority = -2,
		};
	end
end