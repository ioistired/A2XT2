local leveldata = API.load("a2xt_leveldata")
local scene = API.load("a2xt_scene")

local eventu = API.load("eventu")
local cman = API.load("cameraman")
local animatx = API.load("animatx")





local function cor_intro()
	
end

local function skip_intro()
	
end





local hubLevel = "hub"
function onStart()
	mem(0xB2572A,FIELD_BOOL,false)


	-- If the hub is unlocked, start there
	if  leveldata.Visited(hubLevel)  then
		leveldata.LoadLevel(hubLevel)

	-- else if the player is in world 1 or 2
	elseif  leveldata.getWorldsUnlocked() > 0  then

		-- if the current SOW level is beaten, go to that submap
		if  leveldata.getWorldsUnlocked() == leveldata.getMapsUnlocked()  then
			Level.exit()

		-- else if the player is currently on a different SOW level, go to that one
		else
			mem(0xB2572A,FIELD_BOOL,true)
			leveldata.LoadLevel(leveldata.GetWorldStart(leveldata.getWorldsUnlocked()))
		end

	-- Else if in the tutorial world
	elseif  SaveData.currentTutorial ~= nil  then
		mem(0xB2572A,FIELD_BOOL,true)
		leveldata.LoadLevel(SaveData.currentTutorial)

	-- else start the intro cutscene
	else
		a2xt_scene.startScene{scene=cor_intro, skip=skip_intro}
	end
end
