local eventu = API.load("eventu")
local rng = API.load("rng")
local inputs = API.load("inputs2")
local intercom = API.load("intercom")
local pnpc = API.load("pnpc")

local icon_tam = Graphics.loadImage("tamIcon.png")
local icon_demo = Graphics.loadImage("demoIcon.png")
local icon_iris = Graphics.loadImage("irisIcon.png")
local icon_ub = Graphics.loadImage("broadswordIcon.png")

local blockReplacementList = 
		{
            [229] = {229, 237},
            [234] = {234, 236},
            [247] = {247, 249},
            [248] = {248, 250},
            [263] = {263, 265},
            [264] = {264, 266}
		}
local blockReplacementIDs = {229,234,247,248,263,264}

local sizeableReplacementList = 
		{
			[575] = Graphics.loadImage(Misc.resolveFile("sizeable-1.png"));
		}
		
local sizeableReplacementIDs = {575}

local sizeables = {};

local bgoReplacementList = 
		{
            [42] = {42, 43, 44},
			[80] = {80, 81, 67, 85, 58, 94, 59, 95, 62, 52, 63, 53, 54, 55, 56, 57},
            [86] = {89, 90, 91, 42, 43, 44},
            [96]  = {96, 152, 131, 133},
            [116] = {116, 118, 120},
            [121] = {121, 119, 117},
            [122] = {122, 124, 128},
            [153] = {153, 130, 151, 132, 129}
		}
local bgoReplacementIDs = {42,80,86,96,116,121,122,153}

Block.config[223].frames = 16;

function onTick()
	for k,v in ipairs(Block.get(223)) do
		v.speedX = -6
	end
	for _, q in pairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
		if q.id == 150 then
			if not q.isHidden then
				player.x = -179648
				player.y = -180352
			end
		end
	end
end

local function randomiseTileset()
	rng.seed = 57
	for k,v in ipairs(Block.get(blockReplacementIDs)) do
		v.id = rng.irandomEntry(blockReplacementList[v.id])
	end
	for k,v in ipairs(BGO.get(bgoReplacementIDs)) do
		v.id = rng.irandomEntry(bgoReplacementList[v.id])
	end
	for k,v in ipairs(Block.get(sizeableReplacementIDs)) do
		local t = {verts = {}, txs = {}, img = sizeableReplacementList[v.id]};
		local tw = math.ceil(v.width/32);
		local th = math.ceil(v.height/32);
		
		local frms = t.img.height/32;
		
		for i = 1,tw do
			local x1 = v.x + (i-1)*32;
			local x2 = math.min(x1+32, v.width);
			for j = 1,th do
				local y1 = v.y + (j-1)*32;
				local y2 = math.min(y1+32, v.height);
				
				local f = rng.randomInt(frms-1);
				local t1 = f/frms;
				local t2 = (f+1)/frms;
				
				table.insert(t.verts, x1);
				table.insert(t.verts, y1);
				table.insert(t.verts, x2);
				table.insert(t.verts, y1);
				table.insert(t.verts, x1);
				table.insert(t.verts, y2);
				table.insert(t.verts, x1);
				table.insert(t.verts, y2);
				table.insert(t.verts, x2);
				table.insert(t.verts, y1);
				table.insert(t.verts, x2);
				table.insert(t.verts, y2);
				
				table.insert(t.txs, 0);
				table.insert(t.txs, t1);
				table.insert(t.txs, 1);
				table.insert(t.txs, t1);
				table.insert(t.txs, 0);
				table.insert(t.txs, t2);
				table.insert(t.txs, 0);
				table.insert(t.txs, t2);
				table.insert(t.txs, 1);
				table.insert(t.txs, t1);
				table.insert(t.txs, 1);
				table.insert(t.txs, t2);
			end
		end
		
		table.insert(sizeables, t);
		v:remove();
	end
end



local function openingCutscene()
	--[[
	for i=1, 65 do
		player.rightKeyPressing = true
		player.leftKeyPressing = false
		eventu.waitFrames(1)
	end
	eventu.waitFrames(12)
	for i=1, 4 do
		Layer.get("gate"..i):show(false)
		Audio.playSFX(37)
		eventu.waitFrames(16)
		player.FacingDirection = -1
	end
	inputs.locked[1].all = false
	intercom.queueMessage{icon=icon_tam, frames=4, text="Test.. test... can you hear me?"}
	intercom.queueMessage{icon=icon_ub, frames=2, text="Yes, loud and clear. What's the matter?"}
	intercom.queueMessage{icon=icon_tam, frames=4, text="The core's defences are getting more agressive by the minute. Be careful."}
	intercom.queueMessage{icon=icon_demo, frames=2, text="Yeah... the door just shut behind me."}
	intercom.queueMessage{icon=icon_tam, frames=4, text="If you get stuck, let us know and we'll find a way to help you out."}
	intercom.queueMessage{icon=icon_demo, frames=2, text="Roger."}
	intercom.queueMessage{icon=icon_ub, frames=2, text="Roger."}
	intercom.queueMessage{icon=icon_iris, frames=2, text="Alfred."}
	--]]
end

function onStart()
	if player.section == 0 then
		eventu.run(openingCutscene);
	else
		inputs.locked[1].all = false
	end
	randomiseTileset()
	
	for k,v in ipairs(NPC.get()) do
		pnpc.wrap(v)
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

local GM_FRAME = readmem(0x00B2BEA0, FIELD_DWORD)
local function get_block_frame(id)
	return readmem(GM_FRAME + 2*(id-1), FIELD_WORD)
end
local function set_block_frame(id, v)
	return writemem(GM_FRAME + 2*(id-1), FIELD_WORD, v)
end

function onDraw()
	for _,v in ipairs(sizeables) do
		Graphics.glDraw{vertexCoords = v.verts, textureCoords = v.txs, texture = v.img, sceneCoords = true, priority = -95.01}
	end

	set_block_frame(223, (get_block_frame(223)+1)%16)
end

