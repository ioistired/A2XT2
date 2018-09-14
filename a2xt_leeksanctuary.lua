local leeks = {}

local particles = loadSharedAPI("particles")
local pnpc = loadSharedAPI("pnpc")
local colliders = loadSharedAPI("colliders")
local textblox = loadSharedAPI("textblox")
local eventu = loadSharedAPI("eventu")
local leveldata = API.load("a2xt_leveldata")
local democounter = API.load("a2xt_democounter")

local leekAnimFrame = 0;

leeks.id = 1000
leeks.world = 3;
leeks.current = nil;
leeks.info = {};

leeks.sections={};
leeks.sectionParticles={};

leeks.SANC_BG = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/leek_sanctuary_bg.png"))
leeks.SANC_FG = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/leek_sanctuary_fg.png"))
leeks.SANC_LIGHT = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/leek_sanctuary_light.png"))
leeks.SANC_DOOR = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/leek_sanctuary_door.png"))
leeks.SANC_HALO = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/leek_sanctuary_window_halo.png"))
leeks.SANC_BEAM = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/leek_sanctuary_window_beam.png"))

leeks.font = GENERIC_FONT;

leeks.BG = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/sanctuary_bg.png"))
leeks.ARROWLEFT= Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/sanctuary_arrow_left.png"))
leeks.ARROWRIGHT= Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/sanctuary_arrow_right.png"))

leeks.ICONS_CHAR = {}

leeks.ICONS_CHAR[CHARACTER_DEMO] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_demo.png"))
leeks.ICONS_CHAR[CHARACTER_IRIS] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_iris.png"))
leeks.ICONS_CHAR[CHARACTER_KOOD] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_kood.png"))
leeks.ICONS_CHAR[CHARACTER_RAOCOW] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_raocow.png"))
leeks.ICONS_CHAR[CHARACTER_SHEATH] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_sheath.png"))
leeks.ICONS_CHAR[CHARACTER_UNCLEBROADSWORD] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_broadsword.png"))

leeks.ICONS_FILTER = {}

leeks.ICONS_FILTER[-2] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_catllama.png"))
leeks.ICONS_FILTER[-1] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_sack.png"))
leeks.ICONS_FILTER[PLAYER_BIG] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_beet.png"))
leeks.ICONS_FILTER[PLAYER_FIREFLOWER] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_fire.png"))
leeks.ICONS_FILTER[PLAYER_LEAF] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_leaf.png"))
leeks.ICONS_FILTER[PLAYER_TANOOKIE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_onion.png"))
leeks.ICONS_FILTER[PLAYER_HAMMER] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_gourd.png"))
leeks.ICONS_FILTER[PLAYER_ICE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_ice.png"))

leeks.ICON_LEEKS = Graphics.loadImage(Misc.resolveFile("graphics/HUD/leeks.png"))
leeks.ICON_RAOCOINS = Graphics.loadImage(Misc.resolveFile("graphics/HUD/raocoins.png"))
leeks.ICON_DEMOS = Graphics.loadImage(Misc.resolveFile("graphics/HUD/demos.png"))

leeks.ICON_PENG_EMPTY = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_peng_empty.png"))
leeks.ICON_PENG = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_peng.png"))

leeks.ICON_CARD_EMPTY = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_card_empty.png"))
leeks.ICON_CARD = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_card.png"))

leeks.TYPE_SECRET = leveldata.TYPE_EOW+1;
leeks.MAXTYPE = leeks.TYPE_SECRET+1;

leeks.ICONS_EXIT = {}
leeks.ICONS_EXIT[leveldata.TYPE_LEVEL+leeks.MAXTYPE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_level_empty.png"));
leeks.ICONS_EXIT[leveldata.TYPE_LEVEL] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_level.png"));
leeks.ICONS_EXIT[leveldata.TYPE_TOWN+leeks.MAXTYPE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_town_empty.png"));
leeks.ICONS_EXIT[leveldata.TYPE_TOWN] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_town.png"));
leeks.ICONS_EXIT[leveldata.TYPE_EOW+leeks.MAXTYPE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_boss_empty.png"));
leeks.ICONS_EXIT[leveldata.TYPE_EOW] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_boss.png"));
leeks.ICONS_EXIT[leeks.TYPE_SECRET+leeks.MAXTYPE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_secret_empty.png"));
leeks.ICONS_EXIT[leeks.TYPE_SECRET] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/icon_secret.png"));

leeks.currentIndex = 0;
leeks.nextIndex = 0;

local dataList;
local leekList;

local particleSet = Misc.resolveFile("graphics/sanctuary/p_leeks.ini");

function leeks.onInitAPI()
	registerEvent(leeks, "onTick","onTick",true)
	registerEvent(leeks, "onCameraDraw","onCameraDraw",true)
	registerEvent(leeks, "onStart","onStart",true)
	registerEvent(leeks, "onInputUpdate","onInputUpdate",true)
end

local leekObjs = {}

local function spawnSanctuaryBlocks(section)
	local x = Section(section).boundary.left;
	local y = Section(section).boundary.top - 8;
	local id = 422;
	local lft = 452;
	local rgt = 451;
	
	for i=1,11 do
		Block.spawn(id,x+(6+i)*32, y+3*32);
	end
	
	for i=1,3 do
		Block.spawn(id,x+(6*32), y+(3+i)*32);
		Block.spawn(id,x+(18*32), y+(3+i)*32);
	end
	
	for i=1,21 do
		if(i < 6 or i > 17) then
			Block.spawn(id,x+((1+i)*32), y+6*32);
		end
	end
	
	for i=1,8 do
		Block.spawn(id,x+32, y+(6+i)*32);
		Block.spawn(id,x+(23*32), y+(6+i)*32);
	end
	
	for i=1,3 do
			Block.spawn(id,x+((10+i)*32), y+13*32);
	end
	
	for i=1,21 do
		if(i < 8 or i > 14) then
			Block.spawn(id,x+((1+i)*32), y+15*32);
		end
	end
	
	Block.spawn(lft,x+(9*32), y+14*32);
	Block.spawn(lft,x+(10*32), y+13*32);
	
	Block.spawn(rgt,x+(15*32), y+14*32);
	Block.spawn(rgt,x+(14*32), y+13*32);
	
	
end

local function setSectionCustomMusic(sectionNum, newCustomMusicPath)
    local musicPathArray = mem(0x00B257B8, FIELD_DWORD)
    mem(musicPathArray + 4 * sectionNum, FIELD_STRING, newCustomMusicPath)
    -- Note sectionNum should be 0-based
end

function leeks.onStart()
	if(leeks.id ~= nil) then
		loadSanctuaryInfo();
		
		for k,v in pairs(leeks.sections) do
			spawnSanctuaryBlocks(k)
			local sobj =  Section(k);
			
			for _,v in ipairs(Warp.getIntersectingEntrance(sobj.boundary.left, sobj.boundary.top, sobj.boundary.right, sobj.boundary.bottom)) do
				v.entranceX = sobj.boundary.left + 128;
				v.entranceY = sobj.boundary.top + 440;
			end
			for _,v in ipairs(Warp.getIntersectingExit(sobj.boundary.left, sobj.boundary.top, sobj.boundary.right, sobj.boundary.bottom)) do
				v.exitX = sobj.boundary.left + 128;
				v.exitY = sobj.boundary.top + 440;
			end
			
			local n = NPC.spawn(leeks.id, sobj.boundary.left + 368, sobj.boundary.top + 362, k);
			n:mem(0xA8,FIELD_DFLOAT,n.x);
			n:mem(0xB0,FIELD_DFLOAT,n.y);
			n:mem(0xDC,FIELD_WORD,leeks.id);
			
			leeks.sectionParticles[k] = {};
			
			local lightdust = Misc.resolveFile("graphics/sanctuary/p_lightDust.ini");
			
			local p1 = particles.Emitter(sobj.boundary.left+340, sobj.boundary.top + 80, lightdust)
			local p2 = particles.Emitter(sobj.boundary.left+668, sobj.boundary.top + 80, lightdust)
			local p3 = particles.Emitter(sobj.boundary.left+504, sobj.boundary.top + 80, lightdust)
			
			p3:setParam("scale","0.03:0.2")
			
			table.insert(leeks.sectionParticles[k],p1)
			table.insert(leeks.sectionParticles[k],p2)
			table.insert(leeks.sectionParticles[k],p3)
			
			sobj.musicID = 24;
			setSectionCustomMusic(k, "music/a2xt-alliumampeloprasum.ogg");
		end
		
		eventu.setFrameTimer(8, function() leekAnimFrame = (leekAnimFrame+1)%8 end, true);
	end
end

local hitLeft = false;
local hitRight = false;

local progressAnimTimer = 0;
local maxAnimTimer = 8;

local function playSound()
	playSFX(26)
end

function leeks.onInputUpdate()
	if(leeks.current ~= nil and leeks.current.isValid and not isGamePaused()) then
	
		if(progressAnimTimer == 0) then
			local info = dataList;
			
			if(#info > 1) then
				if(player.leftKeyPressing) then
					if(not hitLeft) then
						leeks.nextIndex = (leeks.currentIndex-1)%#info;
						playSound();
						hitLeft = true;
						progressAnimTimer = maxAnimTimer;
					end
				else
					hitLeft = false;
				end
				
				if(player.rightKeyPressing) then
					if(not hitRight) then
						leeks.nextIndex = (leeks.currentIndex+1)%#info;
						playSound();
						hitRight = true;
						progressAnimTimer = -maxAnimTimer;
					end
				else
					hitRight = false;
				end
			end
		
		end
		
		player.leftKeyPressing = false;
		player.rightKeyPressing = false;
		player.x = (player.x + player.width*0.5)*0.8 + (leeks.current.x+leeks.current.width*0.5)*0.2 - player.width*0.5;
		player.speedX = 0;
	else
		hitLeft = true;
		hitRight = true;
	end
end

function leeks.onTick()
	if(leeks.id ~= nil) then
		local ypos = 0;
	
		for k,v in ipairs(NPC.get(leeks.id,player.section)) do
			local lk = pnpc.wrap(v);
			if(lk.data.particles == nil) then
				lk.data.particles = particles.Emitter(v.x,v.y,particleSet);
				lk.data.particles:Attach(v);
				lk.data.t = 0;
				if(not table.icontains(leekObjs,lk)) then
					table.insert(leekObjs, lk);
				end
			end
			
			v.speedX = 0;
			v.speedY = 0;
			v.x = v:mem(0xA8,FIELD_DFLOAT)
			v.y = v:mem(0xB0,FIELD_DFLOAT)
			v.height = 48;
		end
		
		local index = player:mem(0x176,FIELD_WORD);
		if(index > 0 and NPC(index-1).id == leeks.id) then
			leeks.current = pnpc.wrap(NPC(index-1));
		else
			leeks.current = nil;
		end
		
		if(progressAnimTimer > 0) then
			progressAnimTimer = progressAnimTimer - 1;
		elseif(progressAnimTimer < 0) then
			progressAnimTimer = progressAnimTimer + 1;
		end
		
		if(progressAnimTimer == 0) then
			leeks.currentIndex = leeks.nextIndex;
		end
	end
end

local arrowPos = 0;

local function drawLevel(info,i,basex,y,alpha)

			local completion = leveldata.GetCompletion(info[i].Path..".lvl");
			
			local name = "???";
			local author = "by ???";
			if(completion ~= nil) then
				name = info[i].Name;
				author = "by "..info[i].Author;
			end
			
			local halfwid = (math.max(leeks.font:getStringWidth(info[i].Name),leeks.font:getStringWidth(author))*0.5);
			
			--[[if(leeks.ICONS_TYPE[info[i].Type]) then
				Graphics.drawImage(leeks.ICONS_TYPE[info[i].Type],basex - halfwid - 32, y, alpha)
			end]]
			
			local basey = y;
			
			textblox.printExt(name, {x = basex, y = y, width=600, font = leeks.font, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=1, opacity=alpha})
			y = y + leeks.font.charHeight + 4;
			textblox.printExt(author, {x = basex, y = y, width=600, font = leeks.font, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=1, opacity=alpha})
			y = y + leeks.font.charHeight + 12;
			
			
			if(info[i].Raocoins) then
				Graphics.drawImage(leeks.ICON_RAOCOINS,basex - halfwid - 48, basey + leeks.font.charHeight*0.5, alpha)
				Graphics.drawImage(leeks.ICON_RAOCOINS,basex + halfwid + 32, basey + leeks.font.charHeight*0.5, alpha)
			end
			
			local exitindex = info[i].Type;
			if(completion == nil or (not completion.Exit and exitindex ~= leveldata.TYPE_TOWN)) then
				exitindex = exitindex + leeks.MAXTYPE;
			end
			
			local count = 1;
			if(info[i].Secret) then
				count = count + 1;
			end
			if(info[i].Peng ~= nil) then
				count = count + 1;
			end
			if(info[i].Cards ~= nil) then
				count = count + #info[i].Cards;
			end
			
			local xoffset = -(count+1)*12
				
			
			if(info[i].Secret) then
				xoffset = xoffset+24;
				local secretindex = leeks.TYPE_SECRET;
				if(completion == nil or not completion.Secret) then
					secretindex = secretindex + leeks.MAXTYPE;
				end
				Graphics.drawImage(leeks.ICONS_EXIT[secretindex],basex-xoffset - 8,y, alpha)
			end
			
			if(info[i].Cards ~= nil) then
				for _,v in ipairs(info[i].Cards) do
					xoffset = xoffset+24;
					local cardimg = leeks.ICON_CARD_EMPTY;
					--TODO: Maybe adjust this when we add the proper card system
					if(SaveData.cards ~= nil and SaveData.cards[tostring(v):lower()]) then
						cardimg = leeks.ICON_CARD;
					end
					Graphics.drawImage(cardimg,basex-xoffset - 8,y, alpha)
				end
			end
			
			if(info[i].Peng ~= nil) then
				xoffset = xoffset+24;
				local pengimg = leeks.ICON_PENG_EMPTY;
				if(SaveData.pengs ~= nil and SaveData.pengs[tostring(info[i].Peng)]) then
					pengimg = leeks.ICON_PENG;
				end
				Graphics.drawImage(pengimg,basex-xoffset - 8,y, alpha)
			end
			
			xoffset = xoffset+24;
				
			Graphics.drawImage(leeks.ICONS_EXIT[exitindex],basex-xoffset - 8,y, alpha)
			
			y = y + 30;
			
			local demos = democounter.GetDemos(info[i].Path);
			local demstr = " x "..tostring(demos);
			local demowid = 64+leeks.font:getStringWidth(demstr);
			if(info[i].Type == leveldata.TYPE_TOWN) then
				demowid = 0;
			end
			
			local leekwid = 0;
			local bufferwid = 0;
			
			if(leekList[i][2] > 0) then
				local leekstr = leekList[i][1].."/"..leekList[i][2];
				local leekx;
				leekwid = leeks.font:getStringWidth(" x 0/0") + 16;
				if(info[i].Type ~= leveldata.TYPE_TOWN) then
					bufferwid = 16;
				end
				leekx = basex - (leekwid+demowid+bufferwid)*0.5;
				
				textblox.printExt(" x "..leekstr, {x = leekx + 16, y = y, width=600, font = leeks.font, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_TOP, z=1, opacity=alpha})
				
				Graphics.drawImage(leeks.ICON_LEEKS, leekx, y, alpha)
			end
			
			if(info[i].Type ~= leveldata.TYPE_TOWN) then
					local demox = basex + (leekwid-demowid+bufferwid)*0.5;
					textblox.printExt(demstr, {x = demox + 64, y = y, width=600, font = leeks.font, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_TOP, z=1, opacity=alpha})
					Graphics.drawImage(leeks.ICON_DEMOS,demox,y, alpha)
			end
			
			y = y + leeks.font.charHeight + 8;
			
			local chrs = leveldata.CharsOrDefault(info[i]);
			local x = basex+10-(10*#chrs)-8;
			for k,v in ipairs(chrs) do
				Graphics.drawImage(leeks.ICONS_CHAR[v],x,y, alpha)
				x = x + 20;
			end
			
			y = y + 30
			
			if(info[i].Filters) then
				x = basex+10-(10*#info[i].Filters) - 8;
				
				for k,v in ipairs(info[i].Filters) do
						Graphics.drawImage(leeks.ICONS_FILTER[v],x,y, alpha)
						x = x + 20;
				end
			end
end

function leeks.onCameraDraw()

	if(leeks.sections[player.section] ~= nil and leeks.sections[player.section] ~= false) then
		local bounds = Section(player.section).boundary;
		Graphics.draw{x=bounds.left, y=bounds.top,isSceneCoordinates=true,type=RTYPE_IMAGE,priority=-95,image=leeks.SANC_BG}
		Graphics.draw{x=bounds.left, y=bounds.top,isSceneCoordinates=true,type=RTYPE_IMAGE,priority=-64,image=leeks.SANC_FG}
		Graphics.draw{x=bounds.left+96, y=bounds.top+376,isSceneCoordinates=true,type=RTYPE_IMAGE,priority=-60,image=leeks.SANC_DOOR}
		
		local verts = {bounds.left,bounds.top,bounds.left+800,bounds.top,bounds.left,bounds.top+600,bounds.left+800,bounds.top+600};
		local tx = {0,0,1,0,0,1,1,1};
		
		local c = 0;
		
		Graphics.glDraw{vertexCoords=verts,textureCoords=tx,vertexColors={c,c,c,0,c,c,c,0,c,c,c,0,c,c,c,0},sceneCoords = true,primitive=Graphics.GL_TRIANGLE_STRIP,priority=-94,texture=leeks.SANC_HALO}
		
		local c = 0.75;
		
		Graphics.glDraw{vertexCoords=verts,textureCoords=tx,vertexColors={c,c,c,0,c,c,c,0,c,c,c,0,c,c,c,0},sceneCoords = true,primitive=Graphics.GL_TRIANGLE_STRIP,priority=-93,texture=leeks.SANC_BEAM}
		
		c = 0.3;
		
		Graphics.glDraw{vertexCoords=verts,textureCoords=tx,vertexColors={c,c,c,0,c,c,c,0,c,c,c,0,c,c,c,0},sceneCoords = true,primitive=Graphics.GL_TRIANGLE_STRIP,priority=-4,texture=leeks.SANC_LIGHT}
		
		for k,v in ipairs(leeks.sectionParticles[player.section]) do
			if(k~=3) then
				v:Draw(-64.1);
			else
				v:Draw(-93);
			end
		end
	end

	local k = 1;
	while(k <= #leekObjs) do
		local v = leekObjs[k];
		k = k+1;
		if(v.isValid and v.data.particles ~= nil) then
			if(v:mem(0x146, FIELD_WORD) ~= player.section) then
				v.data.particles = nil;
			else
				v.data.particles:Draw(-5);
				v.data.particles:SetOffset(math.sin(v.data.t)*24,0)
				v.data.t=v.data.t+(math.pi/(64));
			end
			v.animationFrame = leekAnimFrame;
		elseif(not v.isValid) then
			k = k-1;
			table.remove(leekObjs,k);
		end
	end
	
	if(leeks.current ~= nil and leeks.current.isValid) then
		local info = dataList;
		
			local i = leeks.currentIndex+1;
			local j = leeks.nextIndex+1;
			local y = 200;
			local t = 0;
			if(progressAnimTimer ~= 0) then
				if(progressAnimTimer > 0) then
					t = maxAnimTimer-progressAnimTimer;
				else
					t = -maxAnimTimer-progressAnimTimer;
				end
			end
			
			t=t/maxAnimTimer;
			
			
			local basex = 400 + t*400
			local alpha = 1-(math.abs(t))
			
			
			Graphics.drawImage(leeks.BG,0,y)
			
			if(#info > 1 and progressAnimTimer == 0) then
				local a = math.sin(arrowPos)
				
				Graphics.drawImage(leeks.ARROWLEFT, 64 + a, y+100-8--[[charheight]]*0.5)
				Graphics.drawImage(leeks.ARROWRIGHT, 800-64-16 - a, y+100-8--[[charheight]]*0.5)
				
				arrowPos = arrowPos+0.1;
			end
			
			y = y + 20
			
			local dir = 1;
			if(progressAnimTimer > 0) then
				dir = -1;
			end
			
			drawLevel(info,i,basex,y,alpha)
			if(progressAnimTimer ~= 0) then
				drawLevel(info,j,basex+400*dir,y,1-alpha)
			end
	end
end

local function getCollectedLeekCount(levelName)
	local starCount = mem(0x00B251E0, FIELD_WORD)
    local starTablePtr = mem(0x00B25714, FIELD_DWORD)
    local counter = 0
    for starIdx=1,starCount do
        local starLevelName = tostring(mem(starTablePtr + (starIdx-1)*8, FIELD_STRING))
        local starSection = mem(starTablePtr + (starIdx-1)*8 + 4, FIELD_WORD)
        if (starLevelName == levelName) then
            counter = counter + 1
        end
    end
    return counter
end

local function parseFile (path)
	local p = Misc.resolveFile(path);
	
	if(not pcall(function() f = io.open(p,"r") end)) then
		error("Could not open level file "..tostring(path),3);
	else
	
		local maxLeeks = 0;
		local i = 1;
		for k in f:lines() do
			if(i == 2) then
				maxLeeks = tonumber(k);
				break;
			end
			i = i + 1;
		end
		
		local leekCount = getCollectedLeekCount(path)
		
		return maxLeeks, leekCount;
	end
end

function loadSanctuaryInfo()
	dataList = leveldata.GetWorldInfo(leeks.world);
	leekList = {};
	for k,v in ipairs(dataList) do
		local leekMax,leekCount = parseFile(v.Path..".lvl");
		leekList[k] = {leekCount, leekMax};
	end
	
	if(leeks.world == 10) then
		for i=#dataList,1,-1 do
			if(leveldata.GetCompletion(dataList[i].Path..".lvl") == nil) then
				table.remove(dataList, i)
			end
		end
	end
end

return leeks;