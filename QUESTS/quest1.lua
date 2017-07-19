local textblox = API.load("textblox")
local a2xt_mission = API.load("a2xt_mission")

local quest1 = {}
local berriesCollected,berriesRequired = 0,5
local displayFrames = 240
local displayTimer = displayFrames

local endFrames = 0
local endStarted = false


function quest1.onInitAPI()
	if  Level.filename() == "MonkeyShrapnel-MuffinBluff.lvl"   then
		registerEvent(quest1, "onTick",    "onTick",     true)
		registerEvent(quest1, "onStart",   "onStart",    true)
	end
end


function quest1.onTick ()
	local camObj = Camera.get()[1]

	local _,berryTaskComplete = a2xt_mission.Progress.GetTask ("quest1", 1)

	-- Display berry count
	displayTimer = math.max(0, displayTimer - 1)

	if  displayTimer > 0  and  not berryTaskComplete  then
		local textProps = {x=player.x+0.5*player.width, y=player.y+player.height-96, halign=textblox.HALIGN_MID, scale=2, font=textblox.defaultSpritefont[4][1], bind=textblox.BIND_LEVEL}
		local textStr = "<color 0xCCCCFFFF>Berries:<br><color 0xFFFFFFFF>"..tostring(berriesCollected).."/"..tostring(berriesRequired)
		if      berriesCollected == 0  then
			textStr = "<color 0xCCCCFFFF>Berries:<br><color 0xFF7777FF>"..tostring(berriesCollected).."/"..tostring(berriesRequired)
		elseif  berriesCollected >= berriesRequired  then
			textStr = "<color 0xCCCCFFFF>Berries:<br><color 0x44FF44FF>"..tostring(berriesCollected).."/"..tostring(berriesRequired)
		end
		textblox.printExt (textStr, textProps)
	end

	-- Display success message
	endFrames = math.max(endFrames - 1)
	
	if  Level.winState() ~= 0  and  berriesCollected >= berriesRequired  and  not berryTaskComplete  then
		if  endStarted == false  then
			endStarted = true
			a2xt_mission.Progress.CompleteTask {quest="quest1", task=1, info="Return to Old MacDumpling to finish the quest."}
		end
	end

	-- Collect berries
	local contactNpcs = NPC.getIntersecting (player.x, player.y, player.x+player.width, player.y+player.height)
	local filter = {[92]=1, [139]=1, [140]=1}

	for k,v in pairs (contactNpcs)  do
		if  filter[v.id] ~= nil  and  not berryTaskComplete  then
			if  berriesCollected < berriesRequired  then
				v:kill ()
				berriesCollected = berriesCollected + 1
				a2xt_mission.Sounds.Play(a2xt_mission.Sounds.arps[berriesCollected])
			end
			displayTimer = displayFrames
		end
	end

	-- Lose berries if hurt
	if player:mem(0x122, FIELD_WORD) == 2  then
		if  berriesCollected ~= 0  then
			a2xt_mission.Sounds.Play(a2xt_mission.Sounds.bad)
		end
		berriesCollected = 0
		displayTimer = displayFrames
	end
end

return quest1