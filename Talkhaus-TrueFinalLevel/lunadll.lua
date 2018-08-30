-------------
-- GENERAL --
-------------
local rng = API.load("rng")
local pipecannon = API.load("pipecannon")
local colliders = loadSharedAPI("colliders");
local pnpc = loadSharedAPI("pnpc");

local timer = 0

function thwompLoop()
	for  k,v in pairs(NPC.get(37, -1))  do
		Cam = Camera.get()
		if ((Cam[1].x < v.x + 800 and (Cam[1].x + 800) > v.x)) and (Cam[1].y < v.y + 600 and (Cam[1].y + 600 > v.y)) then
		--v.underwater = false
	--Text.print(v.speedY,100,100)
	--Text.print(v.underwater,200,100)
			if (v.ai1 == 0) then
				--v.ai1 = 1;
				if (timer == 8) then
					v.ai1 = 1
					--v.ai2 = 98;
					timer = 0
				else
					timer = timer + 1
					v.ai1 = 0
				end
				if (v.ai2 < 75) then
					v.ai2 = 92;
					timer = 0
				end
			end
			if (v.ai1 == 3) then
				--v.speedY = v.speedY * 1.13
				v.speedY = -4.5
				sounded = false
			end
	
			if (v.ai1 == 1) then
				--v.speedY = v.speedY * 1.06
				v.speedY = 4.5
				sounded = false
			end

			if (v.ai1 == 0 and sounded == false) then
				playSFX(37)
				sounded = true
			end

			if (v.ai1 == 2 and sounded == false) then
				playSFX(37)
				sounded = true
			end
		end

	end
end

--------------------------
-- SECTION 2 (SAJEWERS) --
--------------------------

local layer2x = 0
local layer3x = 0
local layer2xhold = 0
local layer3xhold = 0

function onLoopSection1()
	lavalayer = Layer.get("Layer2")
	lavalayer.speedY = (math.sin(layer2x)) * 1.1

	otherlayer = Layer.get("Layer3")
	otherlayer.speedY = (math.sin(layer3x)) * 2

	if (player:mem(0x122, FIELD_WORD)) == 0 then
		layer2x = layer2x - .01
		layer3x = layer3x + .02
	end
	--Text.print(player:mem(0x122, FIELD_WORD),100,100)
	
	thwompLoop()

end

----------------------
-- SECTION 3 (PYRO) --
----------------------

local backgroundSwapTimer = 60;

local tableOfCharacterBlocks = {626, 627, 628, 629, 632}
local tableSwitch = {}
tableSwitch[1] = 626;
tableSwitch[2] = 627;
tableSwitch[3] = 628;
tableSwitch[4] = 629;
tableSwitch[5] = 632;

function pyroInitialRun()
	Graphics.sprites.block[530].img = Graphics.loadImage("//pyro//block-530.png");
	Graphics.sprites.background[24].img = Graphics.loadImage("//pyro//background-24.png");
	Graphics.sprites.background[1].img = Graphics.loadImage("//pyro//background-1.png");
	Graphics.sprites.background[66].img = Graphics.loadImage("//pyro//background-66.png");
	Graphics.sprites.npc[260].img = Graphics.loadImage("//pyro//npc-260.png");
end

function onLoopSection2()
	local initialRun = false;
	if initialRun == false then
		pyroInitialRun()
		initialRun = true;
	end

	local mySection = Section(player.section);
	for _, q in pairs(Block.getIntersecting(player.x-4, player.y-4, player.x + player.width + 4, player.y + player.height + 4)) do
		if q.id == 530 then
			player.speedY = player.speedY - 0.35;
		end
	end
	
	if backgroundSwapTimer > 0 then
		backgroundSwapTimer = backgroundSwapTimer - 1;
	end
	if backgroundSwapTimer == 0 then
		mySection.backgroundID = rng.randomInt(1,58)
		backgroundSwapTimer = 120;
		Audio.playSFX("//pyro//pswitch.ogg")
	end
	
	local top = -160640
	local bottom = -160000
	
	for _,v in ipairs(BGO.getIntersecting(player.x,player.y-600,player.x+player.width,player.y+600)) do
		if v.id == 24 or v.id == 1 then
			if player.y < top then
				player.y = bottom;
				Audio.playSFX("//pyro//GravityFlip.wav")
			end
			if player.y > bottom then
				player.y = top;
				Audio.playSFX("//pyro//GravityFlip.wav")
			end
		end
	end
	
	for _,b in ipairs(NPC.get()) do
		for _,v in ipairs(BGO.getIntersecting(b.x,b.y-600,b.x+b.width,b.y+600)) do
			if v.id == 24 or v.id == 1 then
				if b.y < top then
					b.y = bottom;
					Audio.playSFX("//pyro//GravityFlip.wav")
				end
				if b.y > bottom then
					b.y = top;
					Audio.playSFX("//pyro//GravityFlip.wav")
				end
			end
		end
	end
	
	for k,v in pairs(NPC.get(27,-1)) do
		if player.x < v.x then
			v.speedX = -2;
		else
			v.speedX = 2;
		end
	end

	for _,a in pairs(Block.get(510)) do
		a.id = tableSwitch[player.character]
	end
	
	for _,v in ipairs(NPC.get(260,2)) do
		v.width = 32;
		v.height = 32;
	end
	
	for _,v in ipairs(NPC.get({4,5},2)) do
		v.speedY = -0.26;
	end
	
	thwompLoop()
end

--------------------------
-- SECTION 4 (7NameSam) --
--------------------------

function onLoadSection3()
	-- pyro's code, don't touch (just reverting some gfx override i did in my section)
	Graphics.sprites.block[530].img = nil
	Graphics.sprites.background[24].img = nil
	Graphics.sprites.background[1].img = nil
	Graphics.sprites.background[66].img = nil
	Graphics.sprites.npc[260].img = nil
end

function onNPCKill(eventObj, killedNPC, killReason)
	--explosions for furbombs
    if killedNPC.id == 242 or killedNPC.id == 243 then
        for i=0,10 do
			a = pnpc.wrap(NPC.spawn(282, killedNPC.x, killedNPC.y, player.section));
			a.dir = i * 360 / 10;
			a.data = { spd = 5, dir = a.dir, dirspd = 0 };
			a.speedX = a.data.spd * math.cos(math.rad(a.data.dir));
			a.speedY = a.data.spd * math.sin(math.rad(a.data.dir));
		end
    end
end
local shootWait = 360
function onLoopSection3()
	--make furbombs explode on touch
	furbombs()
    --makes lakitu shoot projectiles
    shootWait = shootWait -1
    if shootWait <= 0 then 
    	for _,v in pairs(NPC.get(47, -1)) do
    		if ((Cam[1].x < v.x + 800 and (Cam[1].x + 800) > v.x)) and (Cam[1].y < v.y + 600 and (Cam[1].y + 600 > v.y)) then
    			for i=0,2 do
					a = pnpc.wrap(NPC.spawn(282, v.x, v.y, player.section));
					a.dir = 45 + i * 360 / 8;
					a.data = { spd = 3, dir = a.dir, dirspd = 0 };
					a.speedX = a.data.spd * math.cos(math.rad(a.data.dir));
					a.speedY = a.data.spd * math.sin(math.rad(a.data.dir));
				end
				playSFX(9)
			end
		end
		shootWait = 360
	end
	thwompLoop()
end
function furbombs()
	local _,_,list1 = colliders.collideNPC(242,player);
    local _,_,list2 = colliders.collideNPC(243,player);
    for _,v in ipairs(list1) do
        v:kill(2);
        player:harm();
    end
    for _,v in ipairs(list2) do
        v:kill(2);
        player:harm();
    end
end
---------------------------
-- SECTION 5 (Mikkofier) --
---------------------------
function onLoopSection4()
	furbombs()
end
