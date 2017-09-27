local eventu = API.load("eventu")
local rng = API.load("rng")
local inputs = API.load("inputs2")
local intercom = API.load("intercom")

local icon_tam = Graphics.loadImage("tamIcon.png")

local blockReplacementList = {
            [229] = {229, 237},
            [234] = {234, 236},
            [247] = {247, 249},
            [248] = {248, 250},
            [263] = {263, 265},
            [264] = {264, 266}
}
local blockReplacementIDs = {229,234,247,248,263,264}

local bgoReplacementList = {
            [42] = {42, 43, 44},
            [86] = {89, 90, 91, 42, 43, 44},
            [96]  = {96, 152, 131, 133},
            [116] = {116, 118, 120},
            [121] = {121, 119, 117},
            [122] = {122, 124, 128},
            [153] = {153, 130, 151, 132, 129}
}
local bgoReplacementIDs = {42,86,96,116,121,122,153}

local function randomiseTileset()
	for k,v in ipairs(Block.get(blockReplacementIDs)) do
		v.id = rng.irandomEntry(blockReplacementList[v.id])
	end
	for k,v in ipairs(BGO.get(bgoReplacementIDs)) do
		v.id = rng.irandomEntry(bgoReplacementList[v.id])
	end
end

local secondaryCharacterTable = {}
local initialisingCams = true
local hasJustSwitched = false

local leftCycle = {
            [CHARACTER_MARIO] = CHARACTER_UNCLEBROADSWORD,
            [CHARACTER_LUIGI] = CHARACTER_MARIO,
  [CHARACTER_UNCLEBROADSWORD] = CHARACTER_LUIGI,
}

local rightCycle = {
            [CHARACTER_MARIO] = CHARACTER_LUIGI,
            [CHARACTER_LUIGI] = CHARACTER_UNCLEBROADSWORD,
  [CHARACTER_UNCLEBROADSWORD] = CHARACTER_MARIO,
}

local memWhitelist = {
        0x02, --sparkles, why not
        0x0C, --fairy state
        0x16, --hearts
        0x40, --climbing
        0x38, --underwater stroke timer
        0x3C, --sliding
        0x44, --rainbow shell
        0x4A, --tanooki
        0x4C, --statue timer
        0x4E, --frames spent as statue
        0x50, --spinjumping
        0x52, --spinjumping
        0x54, --spinjumping
        0x56, --kill combo
        0x60, --has jumped
        0xE0, --xspeed
        0xE8, --yspeed
       0x108, --mount
       0x10A, --mount color
       0x114, --sprite index
       0x11C, --jump force
       0x122, --forced animation state
       0x124, --forced animation timer
       0x12E, --ducking
       0x140, --blinking timer
       0x154, --held item
       0x158, --reserve item
       0x1FA, --section
       0x160, --projectile timer
       0x164, --tail swipe timer
       0x16E, --flight
       0x170, --flight remaining
}

local function addCharacter(id, props)
	if not props then props = {} end
	local entry = {}
	entry.memSave = {}
    for _, i in ipairs(memWhitelist) do
        entry.memSave[i] = player:mem(i,FIELD_WORD)
    end
	entry.width = player.width
	entry.height = player.height
	entry.x = props.x
	entry.y = props.y
	entry.powerup = props.powerup
	entry.memSave[0x15A]= props.section or entry.memSave[0x15A]
	entry.sfx = props.sfx
	
	entry.buffer = Graphics.CaptureBuffer(800,600)
	entry.bufferTimer = 1
	secondaryCharacterTable[id] = entry
end

local function switchDelay(id)
	hasJustSwitched = true
	local character = player.character
    for _, i in ipairs(memWhitelist) do
        secondaryCharacterTable[character].memSave[i] = player:mem(i,FIELD_WORD)
    end
	secondaryCharacterTable[character].width = player.width
	secondaryCharacterTable[character].height = player.height
	secondaryCharacterTable[character].powerup = player.powerup
	secondaryCharacterTable[character].x = player.x
	secondaryCharacterTable[character].y = player.y
	eventu.waitFrames(1, true)
	player.character = id
    for _, i in ipairs(memWhitelist) do
        player:mem(i,FIELD_WORD, secondaryCharacterTable[id].memSave[i])
    end
	
	if not initialisingCams then
		Audio.playSFX(secondaryCharacterTable[id].sfx)
	end
	
	player:mem(0x15A, FIELD_WORD, secondaryCharacterTable[id].memSave[0x15A])
	player.powerup = secondaryCharacterTable[id].powerup
	player.width = secondaryCharacterTable[id].width
	player.height = secondaryCharacterTable[id].height
	player.x = secondaryCharacterTable[id].x
	player.y = secondaryCharacterTable[id].y
	eventu.waitFrames(1, true)
	hasJustSwitched = false
	eventu.waitFrames(3, true)
	eventu.signal("switched")
end

local function switchCharacter(id)
	
	local character = player.character
	for k,v in pairs(secondaryCharacterTable) do
		v.bufferTimer = 1
	end
	secondaryCharacterTable[character].buffer:captureAt(0)
	secondaryCharacterTable[character].bufferTimer = 0
	eventu.run(switchDelay, id)
end

local function openingCutscene()
	for i=1, 65 do
		player.rightKeyPressing = true
		eventu.waitFrames(1)
	end
	eventu.waitFrames(25)
	for i=1, 4 do
		Layer.get("gate"..i):show(false)
		Audio.playSFX(37)
		eventu.waitFrames(16)
		player.FacingDirection = -1
	end
	inputs.locked[1].all = false
	intercom.queueMessage(icon_tam, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.")
	intercom.queueMessage(icon_tam, "CAN YOU HEAR ME?!?!.")
end

local function initCams()
	inputs.locked[1].all = true
	player.character = 1
	addCharacter(CHARACTER_MARIO,
	            {    x=-199552,
				     y=-200250,
					 powerup = 2,
					 section = 0,
					 sfx = "sfx_demoswitch.ogg"
				}
	)
	eventu.waitFrames(1)
	addCharacter(CHARACTER_LUIGI,
	            {    x=-179712,
				     y=-180224,
					 powerup = 2,
					 section = 1,
					 sfx = "sfx_irisswitch.ogg"
				}
	)
	eventu.waitFrames(1)
	switchCharacter(CHARACTER_LUIGI)
	eventu.waitSignal("switched")
	eventu.waitFrames(1)
	addCharacter(CHARACTER_UNCLEBROADSWORD,
	            {    x=-159808,
				     y=-160192,
					 powerup = 2,
					 section = 2,
					 sfx = "sfx_broadswordswitch.ogg"
				}
	)
	eventu.waitFrames(1)
	switchCharacter(CHARACTER_UNCLEBROADSWORD)
	eventu.waitSignal("switched")
	eventu.waitFrames(1)
	switchCharacter(CHARACTER_MARIO)
	eventu.waitSignal("switched")
	eventu.waitFrames(1)
	for k,v in pairs(secondaryCharacterTable) do
		v.bufferTimer = 1
	end
	initialisingCams = false
	
	if player.section == 0 then
		openingCutscene()
	else
		inputs.locked[1].all = false
	end
end

function onStart()
	eventu.run(initCams)
	randomiseTileset()
end

local function charSwitch()
	if player.keys.altRun == KEYS_PRESSED then
		Misc.pause()
	elseif player.keys.altRun == SPAGHETTI_AND_MEATBALLS then
		Misc.unpause()
	end
	
	if player.keys.altRun then
		if player.keys.left == KEYS_PRESSED then
			switchCharacter(leftCycle[player.character])
		elseif player.keys.right == KEYS_PRESSED then
			switchCharacter(rightCycle[player.character])
		end
	end
end

local function drawMonitor(id, dir)
	local v = secondaryCharacterTable[id]
	
	if v.bufferTimer < 1 then
		v.bufferTimer = v.bufferTimer + 0.05
	end
	
	local vt = {}
	vt[1] = math.lerp(0, 336 + 328 * dir, v.bufferTimer)
	vt[2] = math.lerp(0, 8, v.bufferTimer)
	vt[3] = math.lerp(800, 464 + 328 * dir, v.bufferTimer)
	vt[4] = vt[2]
	vt[5] = vt[3]
	vt[6] = math.lerp(600, 104, v.bufferTimer)
	vt[7] = vt[1]
	vt[8] = vt[6]
	
	local tx = {}
	tx[1] = math.lerp(0.5 + 0.5 * dir, 0.5 + 0.1 * dir, v.bufferTimer)
	tx[2] = math.lerp(0, 0.4, v.bufferTimer)
	tx[3] = math.lerp(0.5 - 0.5 * dir, 0.5 - 0.1 * dir, v.bufferTimer)
	tx[4] = tx[2]
	tx[5] = tx[3]
	tx[6] = math.lerp(1,0.6,v.bufferTimer)
	tx[7] = tx[1]
	tx[8] = tx[6]
	
	local colSlider = 0.5 * v.bufferTimer
	
	Graphics.glDraw{texture=v.buffer,
	                vertexCoords = vt,
	                textureCoords = tx,
	                priority = 5 + 1 - v.bufferTimer,
	                primitive = Graphics.GL_TRIANGLE_FAN,
					color={colSlider,colSlider,colSlider,v.bufferTimer}
	}
	Graphics.glDraw{vertexCoords = vt,
	                textureCoords = tx,
	                priority = 5.1 + 1 - v.bufferTimer,
	                primitive = Graphics.GL_LINES,
	                color={colSlider,0,0,v.bufferTimer * v.bufferTimer}
	}
end

function onInputUpdate()
	if not initialisingCams then
		charSwitch()
	end
end

function onDraw()
	if initialisingCams then
		Graphics.drawScreen{color=Color.black, priority=10}
	else
		if hasJustSwitched then
			Graphics.drawScreen{color=Color.grey, priority=10}
		end
		if player.keys.altRun then
			Graphics.drawScreen{color={0,0,0,0.5}, priority=0}
		end
		drawMonitor(leftCycle[player.character], -1)
		drawMonitor(rightCycle[player.character], 1)
	end
end