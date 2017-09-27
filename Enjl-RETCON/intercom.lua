local intercom = {}

local msg = API.load("textblox")
local eventu = API.load("eventu")

local img_icon = Graphics.loadImage("intercom_icon.png")
local img_bg = Graphics.loadImage("intercom_backdrop.png")

intercom.opened = false
intercom.lerp = 0

intercom.delay = 65

local messageQueue = {}

intercom.defaults = 
{
	x=200,
	y=500,
	text="",
	props={
		z=5,
		boxTex=nil,
		borderTable={col=0x00000000},
		boxColor=0x00000000,
		width=400,
		height=96,
		scaleMode=0,
		boxAnchorX = msg.ALIGN_RIGHT,
		textAnchorX = msg.ALIGN_LEFT,
		boxAnchorY = msg.ALIGN_BOTTOM,
		textAnchorY = msg.ALIGN_TOP,
		textOffX=16,
		textOffY=12,
		instant = false,
		inputClose = false,
		inputProgress = false,
		closeSound = nil,
		font=msg.FONT_SPRITEDEFAULT4X2
	
	}
}
intercom.icon = nil

function intercom.queueMessage(source, text)
	--[[showMessageBox args:
		strings: text,closeWith(auto,prompt)
		objects: target
		bools:   keepOnscreen,hasTail,screenSpace,instant
		enums:   type
		ints:    x,y,offX,offY
		tables:  bloxProps
	--]]
	
	local entry = {}
	entry.text = text
	entry.img = source
	table.insert(messageQueue, entry)
	
	if #messageQueue == 1 then
		eventu.run(intercom.start)
	end
end

function intercom.open()
	while intercom.lerp < 1 do
		intercom.lerp = intercom.lerp + 0.05
		eventu.waitFrames(1)
	end
	intercom.lerp = 1
	intercom.opened = true
end

function intercom.close()
	while intercom.lerp > 0 do
		intercom.lerp = intercom.lerp - 0.05
		eventu.waitFrames(1)
	end
	intercom.lerp = 0
	intercom.opened = false
end

function intercom.start()

	intercom.open()
	
	intercom.defaults.text = messageQueue[1].text
	intercom.icon = messageQueue[1].img
	local block = msg.Block(intercom.defaults.x, intercom.defaults.y, intercom.defaults.text, intercom.defaults.props)
	
	while not block.finished do
		eventu.waitFrames(1)
	end
	eventu.waitFrames(intercom.delay)
	
	table.remove(messageQueue, 1)
	block:closeSelf()
	intercom.defaults.text = ""
	
	if #messageQueue > 0 then
		intercom.start()
	else
		intercom.close()
	end
end

function intercom.onInitAPI()
	registerEvent(intercom, "onDraw")
end

function intercom.onDraw()
	if intercom.lerp > 0 then
		local x = intercom.defaults.x
		local y = intercom.defaults.y
		local w = intercom.defaults.props.width
		local h = intercom.defaults.props.height
		local z = intercom.defaults.props.z
		Graphics.drawImageWP(img_icon, x - 8 - img_icon.width,y + 0.5 * h - 0.5 * img_icon.height,z)
		
		if intercom.icon then
			Graphics.drawImageWP(intercom.icon, x - 8 - img_icon.width,y + 0.5 * h - 0.5 * img_icon.height,z)
		end
		
		local vt = {
		    x,
			y,
			x + math.lerp(0, w, intercom.lerp),
			y,
			x + math.lerp(0, w, intercom.lerp),
			y + h,
		    x,
			y + h
		}
		
		Graphics.glDraw{
		       texture = img_bg,
			   vertexCoords = vt,
			   textureCoords = {0,0,1,0,1,1,0,1},
			   primitive=Graphics.GL_TRIANGLE_FAN,
			   priority=z
		}
	end
end

return intercom