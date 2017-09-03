local scene = API.load("a2xt_scene")
local message = API.load("a2xt_message")
local hud = API.load("a2xt_hud")
local costumes = API.load("a2xt_costumes")

local eventu = API.load("eventu")
local cman = API.load("cameraman")
local textblox = API.load("textblox")
local imagic = API.load("imagic")
local rng = API.load("rng")
local rewards = {}

function rewards.onInitAPI()
	registerEvent (rewards, "onDraw", "onDraw", false)
end


-- Control vars
local rewardJingle = Audio.SfxOpen(Misc.resolveFile("sound/jingle-reward.ogg"))
local sunburstImg = Graphics.loadImage(Misc.resolveFile("graphics/rewards/sunburst.png"));
local sunburstBox = imagic.Create{x=400, y=-9999, scene=true, align=imagic.ALIGN_CENTRE, primitive=imagic.TYPE_BOX, width=sunburstImg.width*2, height=sunburstImg.height*2, texture=sunburstImg};

local rewardImg = {}
local rewardBox = {}
for  _,v in pairs{"card", "raocoin", "costume"}  do
	local img = Graphics.loadImage(Misc.resolveFile("graphics/rewards/reward_"..v..".png"));
	rewardImg[v] = img
	rewardBox[v] = imagic.Create{x=400, y=-999, scene=true, align=imagic.ALIGN_CENTRE, primitive=imagic.TYPE_BOX, width=img.width*2, height=img.height*2, texture=img};
end

local exclamations = {"Hot DOG", "Hot DIGGITY", "Hot ZIGGETY", "Sweet", "Radicola", "Righteous", "Swanky", "Yes", "Oh man", "Heck yeah", "Yay", "Excellent", "Woo", "Woohoo", "Cool beans", "All right", "Cor blimey", "Nice", "Lawdy", "WHAT", "No way", "Hallelujah", "Wow", "Gee whiz", "Oh me, oh my", "Yippee", "Holy smokes", "Holy mackerel", "Holy priceless collection of etruscan snoods, Batman", "Holy hotpockets", "Holy known unknown flying objects", "Holy cow", "Holy guacamole", "Holy hamstrings", "Well, whaddaya know", "Oh, hey", "Brilliant", "Beautiful", "Billions of bilious blue blistering barnacles", "Ten thousand thundering typhoons", "Great Scott", "NANI?!?", "MAJIDE?!?", "NO! THAT'S IMPOSSIBLE", "Outstanding", "Incredible", "Amazing", "Spectacular", "Unbelievable", "Inconceivable", "Huh, how about that", "Welp", "Objection", "Hold it", "Take that", "Huzzah", "Jackpot", "Hey! Listen", "Mamma-mia", "Oooh", "Believe your justice", "Neato", "Jeepers", "Man alive", "Rock solid", "Mathematical", "BEHOLD", "Jeezy Petes", "Appa! Yip yip", "Bajabbers", "Blabbering blatherskite", "Good news, everyone"}

local currBox = rewardBox.raocoin

local function cor_giveReward (args)

	-- Determine the notification string and grant the reward
	local exclaim = args.exclaim  or  rng.randomEntry(exclamations)
	exclaim = exclaim .. "!"
	local msg = "You got "
	if  string.len(exclaim) > 20  then
		msg = exclaim.."<br>"..msg
	else
		msg = exclaim.." "..msg
	end

	local currBox = rewardBox.raocoin
	local rewardType = "raocoin"
	if  args.type == "raocoin"  then
		msg = msg..tostring(args.quantity).." raocoins!"
		rewardType = "raocoin"
		-- Add the raocoins
	end
	if  args.type == "costume"  then
		local costumeInfo = costumes.info[args.quantity]
		msg = msg.."the "..costumeInfo.name.." costume!"
		costumes.unlock(args.quantity)
	end
	if  args.type == "card"  then
		msg = msg.."the "..tostring(args.quantity).." card!"
		-- Add the card
	end
	currBox = rewardBox[rewardType]


	-- Camera stuff
	while (cman.playerCam[1] == nil)  do
		eventu.waitFrames(0, true)
	end
	local cam = cman.playerCam[1]

	local yOffTemp = cam.yOffset
	local targetTemp = cam.targets
	local zoomTemp = cam.zoom
	cam:Transition {time=0.5, targets={player}, yOffset=-50, zoom=1.5, easeBoth=cman.EASE.QUAD, runWhilePaused=true}

	-- Raise sprite
	local _, raiseSpr = eventu.run (function ()
			currBox.y = player.y
			local timePassed = 0
			while  (timePassed < 0.5)  do
				currBox.y = player.y - 16 - math.sin(math.rad(90*(timePassed/0.3)))*45
				currBox.x = player.x + 0.5*player.width
				timePassed = timePassed + eventu.deltaTime
				eventu.waitFrames(0)
			end
			while  (true)  do
				currBox.y = player.y - 16 - math.sin(math.rad(90*(timePassed/0.3)))*45
				currBox.x = player.x + 0.5*player.width
				eventu.waitFrames(0)
			end
		end)

	Audio.SfxPlayObj(rewardJingle, 0)
	eventu.waitFrames(32)


	-- 	Show the window
	local _,showMsgLoop = eventu.run (function ()
		while (true) do
			local strWidth, strHeight = textblox.printExt (msg, {x=400,y=150,z=8.1, font=textblox.FONT_SPRITEDEFAULT4X2, halign=textblox.ALIGN_MID,valign=textblox.ALIGN_MID})

			local getBar = hud.window{x=400, y=150, width=strWidth+110,height=math.max(strHeight+50, 70)}
			getBar:Draw{priority=8, colour=0x07122700 + 255};
			eventu.waitFrames(0)
		end
	end)
	eventu.waitFrames(65)
	while (not (scene.prevInputs.jump  and  not scene.currInputs.jump)) do
		eventu.waitFrames(0)
	end
	eventu.abort(showMsgLoop)
	eventu.abort(raiseSpr)
	currBox.y = -999
	cam:Transition {time=0.5, targets=targetTemp, yOffset=yOffTemp, zoom=zoomTemp, easeBoth=cman.EASE.QUAD, runWhilePaused=true}

	scene.endScene()
end


function rewards.give(args)
	scene.startScene{scene=cor_giveReward, sceneArgs=args}
end

function rewards:onDraw()
	sunburstBox.y = currBox.y
	sunburstBox.x = currBox.x

	sunburstBox:Rotate(0.5)
	sunburstBox:Draw{priority=-1.1, color=0xFFFFFF99}

	for  k,v in pairs(rewardBox)  do
		v.x = player.x + 0.5*player.width
		v:Draw{priority=-1}
	end
end


return rewards;