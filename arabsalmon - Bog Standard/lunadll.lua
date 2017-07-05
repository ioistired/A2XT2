-- Max coin number
MAX_COINS = 20
coins = MAX_COINS
-- Current lives
lives = 0
-- Coin meter image
coinmeter = nil
coindeath = false

-- Vertical speed/position of player on previous frame
prevDY = 0
prevY = 0
-- Acceleration due to gravity
accel = 0.40000000596046
-- Minimum speed to bounce player
PLAYER_BOUNCE_SPEED = -8
-- Set maximum fall speed
Defines.gravity = 20

plant = {}
plant.x = 0; plant.y = 0;
holdtimer = 0

-- Frame counter
t = 0
-- Hold down at the start of the level
duckstart = false
-- Screen boundaries
top = {-200608, -180608, -160608, -140608}; bottom = {-200000, -180000, -160000, -140000};
-- Chained key info
coordX = -197600; coordY = -200544;
grabbed = false

midpoint = false

-- Section 2 default bounds
sec2default = nil
mazebounds = nil
plantplucked = false
mazestate = 0
mazestate_prev = 0

leveldata = Data(Data.DATA_LEVEL, "BogStandard_data")

campos = {}
campos.x = 0; campos.y = {}
lockcamera = false
camera = nil

leveldone = false
flag = false

goaltape_startpos = 0
goaltape_speedY = 0

function onLoop()
	-- On first frame
	if t == 0 then
		-- Set coins
		mem(0x00B2C5A8,FIELD_WORD,coins)
		-- Count lives
		lives = mem(0x00B2C5AC,FIELD_FLOAT)
		-- Filter powerup/mount
		if player.powerup > PLAYER_BIG then player.powerup = PLAYER_BIG end
		player:mem(0x108,FIELD_WORD,0)
		-- If not past midpoint
		if player.section == 0 then duckstart = true end
		
		if player.character ~= CHARACTER_MARIO then player.character = CHARACTER_MARIO end
		
		-- Get default section 2 size
		sec2default = Section.get(2).boundary
		-- Set maze boundaries
		mazebounds = newRECTd()
		mazebounds.top = sec2default.top
		mazebounds.bottom = sec2default.bottom
		mazebounds.left = -178848
		mazebounds.right = mazebounds.left + 32*25
		
		-- Check if the maze was completed
		if leveldata:get("mazecomplete") == "" or player.section == 0 then
			leveldata:set("mazecomplete", tostring(0))
			leveldata:save()
		end
		
		-- Lunapoint
		if leveldata:get("checkpoint_2") == "" or player.section == 0 then
			leveldata:set("checkpoint_2", tostring(0))
			leveldata:save()
		end
		if leveldata:get("checkpoint_2") == "1" then
			player.x = -173952
			player.y = -180224 - player.height
			Layer.get("door5"):hide(true)
		end
		
		Layer.get("fence7"):hide(true)
		Layer.get("coins3"):hide(true)
		
		-- Load coin meter graphics
		coinmeter = Graphics.loadImage("coinmeter.png")
		
		goal = NPC.get(33,2)[1]
		if goal then
			goaltape_startpos = goal.y
			goaltape_speedY = 1.95
		end
	end
	-- On second frame
	if t == 1 then
		if duckstart then triggerEvent("duck") end
	end
	
	-- Control water animation
	for _,water in pairs(NPC.get({19,20},player.section)) do
		frame = math.floor(t%(8*12)/12)
		water:mem(0xe8,FIELD_FLOAT,0)
		water:mem(0xe4,FIELD_WORD,frame)
	end
	
	-- Vertical wrap
	if top[player.section+1] and bottom[player.section+1] then
		if player.y > bottom[player.section+1] then player.y = top[player.section+1] - player.height
		elseif player.y < (top[player.section+1]-player.height) then player.y = bottom[player.section+1] end
	end
	for _,npc in pairs(NPC.get({25,31,242,244},player.section)) do
		if npc.layerName.str == "fence7" and (npc.id == 25 or npc.id == 242) then
			foobar = 1
		else
			if npc.y > bottom[player.section+1] then npc.y = top[player.section+1] - 32
			elseif npc.y < (top[player.section+1]-player.height) then npc.y = bottom[player.section+1] end
			if npc.id == 31 then -- Key
				if not grabbed and npc.activateEventName.str == "hanging_key" then
					if npc:mem(0x12c, FIELD_WORD) ~= 0 then grabbed = true end
					npc.speedY = 0
					npc.x = coordX
					npc.y = coordY - 4
				end
				npc:mem(0x12a, FIELD_WORD, 180)
			end
		end
	end
	
	coinLogic()
	lifeLogic()
	bounceLogic()
	plantLogic()
	donutLogic()
	fenceLogic()
	mazeLogic()
	
	if not midpoint and player.section ~= 0 then
		midpoint = true
		triggerEvent("sec2_warp")
	end
	
	for _,bullet in pairs(NPC.get(17,1)) do
		for _,block in pairs(Block.getIntersecting(bullet.x,bullet.y,bullet.x+bullet.width,bullet.y+bullet.height)) do
			if block.id == 124 and not block.layerObj.isHidden then bullet:kill() end
		end
	end
	
	for _,water in pairs(NPC.get({19,20,27},1)) do
		if water.layerName.str == "fence7" then water.y = water.y + water.layerObj.speedY end
	end
	for _,axe in pairs(NPC.get(178,1)) do
		if axe.layerName.str == "fence7" then
			axe.y = axe.y + axe.layerObj.speedY
		end
	end
	for _,fly in pairs(NPC.get(121,1)) do
		if fly.layerName.str == "fence7" then
			fly.y = fly.y + fly.layerObj.speedY
		end
	end
	
	for _,bgo in pairs(BGO.get(37)) do
		Warp.get()[4].entranceX = bgo.x
		Warp.get()[4].entranceY = bgo.y
	end
	Layer.get("fence7").speedX = 0
	
	if player.section == 2 then Layer.get("Default"):show(true) end
	if not flag and player.section == 2 then
		for _,noise in pairs(NPC.get(21,-1)) do
			noise:kill()
		end
		flag = true
	end

	if player.x > -173952 and player.section == 1 and leveldata:get("checkpoint_2") ~= "1" then
		leveldata:set("checkpoint_2", tostring(1))
		leveldata:save()
		playSFX(58)
	end
	
	goal = NPC.get(33,2)[1]
	if goal then
		for _,block in pairs(Block.getIntersecting(goal.x, goal.y-goaltape_speedY, goal.x+goal.width, goal.y+goal.height+goaltape_speedY)) do
			goaltape_speedY = -goaltape_speedY
			break
		end
		if goal.y < goaltape_startpos then
			goal.y = goaltape_startpos
			goaltape_speedY = -goaltape_speedY
		end
		goal.y = goal.y + goaltape_speedY
	end
	
	t = t+1
end

-- Fence logic
function fenceLogic()
	GAP = 0
	if player:mem(0x40, FIELD_WORD) ~= 0 then
		dx = 0; dy = 0;
		fencelayer = nil
		horiz_bounded = false
		vert_bounded = false
		if player.speedX > 0 then player.speedX = math.floor(10*player.speedX)/10
		else player.speedX = math.ceil(10*player.speedX)/10 end
		if player.speedY > 0 then player.speedY = math.floor(10*player.speedY)/10
		else player.speedY = math.ceil(10*player.speedY)/10 end
		for _,bgo in pairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
			if bgo.id >= 174 and bgo.id <= 186 then
				if bgo.layer.isHidden then
					player:mem(0x40, FIELD_WORD, 0)
					return
				end
				dx = -player.speedX
				dy = -player.speedY
				fencelayer = bgo.layer
				break
			end
		end
		if fencelayer then
			for _,fence in pairs(BGO.get(182)) do
				if fence.layer == fencelayer then
					for  _,bound in pairs(BGO.getIntersecting(fence.x+dx+GAP, fence.y+GAP, fence.x+32+dx-GAP, fence.y+32-GAP)) do
						if not horiz_bounded and bound.id == 72 and not bound.isHidden then
							horiz_bounded = true
						end
					end
					for  _,bound in pairs(BGO.getIntersecting(fence.x+GAP, fence.y+dy+GAP, fence.x+32-GAP, fence.y+32+dy-GAP)) do
						if not vert_bounded and bound.id == 71 and not bound.isHidden then
							vert_bounded = true
						end
					end
					if player.speedX == 0 then horiz_bounded = false end
					if player.speedY == 0 then vert_bounded = false end
					if horiz_bounded then dx = 0 end
					if vert_bounded then dy = 0 end
				end
			end
			if player:mem(0x146, FIELD_WORD) ~= 0 then dy = 0 end
			if player:mem(0x148, FIELD_WORD) ~= 0 then dx = 0 end
			if player:mem(0x14a, FIELD_WORD) ~= 0 then dy = 0 end
			if player:mem(0x14c, FIELD_WORD) ~= 0 then dx = 0 end
			fencelayer.speedX = dx;
			fencelayer.speedY = dy;
			player.x = player.x + dx;
			player.y = player.y + dy;
		end
	else
		for _,layer in pairs(Layer.find("fence")) do
			layer:stop()
		end
	end
end

-- Donut block logic
function donutLogic()
	for _,donut in pairs(NPC.get({212,46}, player.section)) do
		if donut.speedY ~= 0 then donut.speedY = donut.speedY - accel*1.2 end
		if donut.speedY < -Defines.gravity then donut.speedY = -Defines.gravity end
	end
end

-- Plant logic
function plantLogic()
	if holdtimer == 12 then holdtimer = 13
	else holdtimer = player:mem(0x26,FIELD_WORD) end
	if holdtimer == 1 then
		for _,p in pairs(NPC.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height+1)) do
			if p.id == 91 then
				plant.x = p.x
				plant.y = p.y
				break
			end
		end
	end
	if holdtimer == 13 then
		if player.holdingNPC.id == 0 then
			player.x = plant.x;
			player.y = player.y + player.height;
		end
	end
end

-- Life counter
function lifeLogic()
	if lives < mem(0x00B2C5AC,FIELD_FLOAT) then
		mem(0x00B2C5AC,FIELD_FLOAT,lives)
		player:kill()
	end
end

-- Coin counter
function coinLogic()
	if player.x >= -156256 then leveldone = true end
	if leveldone then return end
	if coins < mem(0x00B2C5A8,FIELD_WORD) then
		coins = 2*coins - mem(0x00B2C5A8,FIELD_WORD)
		mem(0x00B2C5A8,FIELD_WORD,coins)
	end
	if coins <= 0 and not coindeath then
		player:kill()
		coins = 0
		coindeath = true
	end
	if coinmeter then
		frame = math.floor((MAX_COINS-coins)/MAX_COINS*15)
		DrawCoinMeter(214, 54)
	end
end
function DrawCoinMeter(x, y)
	Graphics.drawImage(coinmeter, x, y, 0, frame*32, 28, 32)
	if coins > 9 then Text.print(tostring(coins),x+36,y-2)
	else Text.print("0"..tostring(coins),x+36,y-2) end
	Text.print("/",x+70,y+8)
	Text.print(tostring(MAX_COINS),x+82,y+16)
end

-- Logic for bouncy spikes
function bounceLogic()
	-- Detect if contacting bouncy spike underneath player
	for _,b in pairs(Block.getIntersecting(player.x, player.y+player.height, player.x+player.width, player.y+player.height+1)) do
		if not b.layerObj.isHidden then
			if b.id == 45 then
				-- Reflect player downward momentum
				player.y = prevY
				player.speedY = -prevDY - accel
				if player.speedY > PLAYER_BOUNCE_SPEED then player.speedY = PLAYER_BOUNCE_SPEED end
				playSFX(24)
			end
		end
	end
	prevY = player.y
	prevDY = player.speedY
end

-- Logic for first maze
function mazeLogic()
	if mazestate == 2 then return end
	if player.x >= mazebounds.right or leveldata:get("mazecomplete") == tostring(1) then
		mazestate = 2
		triggerEvent("resetbounds")
	end
	if mazestate ~= 2 and plantplucked then
		if player.y <= mazebounds.bottom - 10*32 and player.x >= mazebounds.right - 5*32 then mazestate = 0
		elseif player.x + player.speedX < mazebounds.left + 32*12 then mazestate = 0
		elseif player.x + player.speedX >= mazebounds.left + 32*12 and player.x + player.speedX < mazebounds.left + 32*25/2 then mazestate = 1
		elseif player.x + player.speedX >= mazebounds.left + 32*25/2 then mazestate = 2
		end
		
		if mazestate ~= mazestate_prev then
			if mazestate == 0 then triggerEvent("setmazebounds")
			elseif mazestate == 1 then triggerEvent("mazebuffer")
			else triggerEvent("resetbounds") end
		end
		
		mazestate_prev = mazestate
	end
end

function onEvent(eventName)
	if eventName == "after_maze1" then
		plantplucked = true
	elseif eventName == "resetbounds" then
		if leveldata:get("mazecomplete") ~= tostring(1) then
			leveldata:set("mazecomplete", tostring(1))
			leveldata:save()
		end
	elseif eventName == "hit_switch" then
		camera = Camera.get()[1]
		lockcamera = true
		campos.x = -173696
		campos.y = -180600
	elseif eventName == "send_back" then
		player.x = -139808
		player.y = -140320
		player:mem(0x15a, FIELD_WORD, 3)
	end
end

function onNPCKill(eventObj, npc, reason)
	if npc.layerName.str == "fence7" and npc.id == 178 then
		fish = NPC.spawn(244, npc.x, npc.y, player.section)
		fish.friendly = true
	end
end

function onCameraUpdate(eventObj)
	if player.section == 1 and lockcamera and camera then
		camera.x = campos.x
		camera.y = campos.y
	end
end
