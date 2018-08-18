--------------------------------------------------
-- Level code
-- Created 22:38 2018-8-8
--------------------------------------------------

local particles = API.load("particles")
local eventu = API.load("eventu")
local a2xt_message = API.load("a2xt_message")

local e_snow = particles.Emitter(0,0,Misc.resolveFile("snowy.ini"))
e_snow:AttachToCamera(Camera.get()[1])
local urgh = Graphics.loadImage("urgh.png")

-- Run code on level start
function onLoadSection()
    e_snow:setPrewarm(5)
end

-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
    --Your code here
end

local showMessage = false

local function image()
	eventu.waitFrames(35, true)
	showMessage = true
	a2xt_message.waitMessagePage(nil, 2)
	showMessage = false
	eventu.waitSignal("_messageEnd")
end

function a2xt_message.onMessageBox(eventObj, msg)
	if msg == "toadtalk" then
		if player.mount == 1 and player.mountColor == 2 then
			msg = "                        ä<br>                        ä<br>                         <br>                        ä<br>                        ä<br>                         <br>                        ä<br>                        ä<page>On second  thought, you can keep it."
			eventu.run(image)
		else
			msg = "Ah, you seem to have good jumping capabilities. Could you help me out? It appears I have misplaced my secondary hat. Could you help me find it?"
		end
	end
	if(eventObj.cancelled) then return end;
	local npc = nil;
	if(player.upKeyPressing) then
		npc = a2xt_message.getTalkNPC();
	end
	
	a2xt_message.talkToNPC(npc, a2xt_message.quickparse(msg));
	eventObj.cancelled = true
	--a2xt_message.showMessageBox
	--a2xt_message.waitMessagePage
end

local cam = Camera.get()[1]

-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onDraw()
    e_snow:Draw(0)
	if showMessage then
		for k,v in ipairs(NPC.get(94, player.section)) do
			Graphics.drawImageToSceneWP(urgh, v.x + - 45, v.y - 230, 5)
		end
	end
end

