-- Load libraries into shared memory
-- local cinematX = API.load ("cinematX")
local particles = API.load ("particles")
-- local altruistX = API.load ("altruistX")
-- raocoin2 = loadSharedAPI("raocoin2")
local NPCID = API.load ("npcid")

local scene = API.load ("a2xt_scene")

-- Configure cinematX (generate actors by parsing NPC messages, activate debug features)
--cinematX.config (true, false, true, true)
cinematX.configExt ({imageUi=false, useNpcParse=true})
local localProgressData = Data (Data.DATA_WORLD, "town1", true)
local globalProgressData = Data (Data.DATA_WORLD, "towns", true)


--***************************************************************************************
--                                                                                      *
-- CONSTANTS AND ENUMS																	*
--                                                                                      *
--***************************************************************************************
do
	-- Foreground images
	fgTreeImage = Graphics.loadImage("fgTreesNoGrass.png")
	fgGrassImage = Graphics.loadImage("fgGrass.png")
	fgShadowImage = Graphics.loadImage("fgShadow.png")


	-- NPC ID shorthands
	NPCID_CALLEOCA = NPCID.TOAD_B

	-- Sound IDs
	VOICEID_CAL_01 = "voice_calleoca_01.wav"
	VOICEID_CAL_02 = "voice_calleoca_02.wav"
	VOICEID_CAL_03 = "voice_calleoca_03.wav"

	-- Individual Actor animation settings
	animData_Calleoca = cinematX.readAnimData("calleoca.anim");

	
	-- Event flags
	calleocaShouldFollowPlayer = false
end


--***************************************************************************************
-- 																						*
-- LOAD FUNCTIONS																		*
-- 																						*
--***************************************************************************************

do
	function onLoad ()
		--cinematX.defineQuest ("test", "Test Quest", "Test the quest the quest the test system")
	end

	function onLoadSection1 ()
		--cinematX.runCutscene (cutscene_Calleoca)		
	end
end


--***************************************************************************************
-- 																						*
-- LOOP FUNCTIONS																		*
-- 																						*
--***************************************************************************************

	function loadProgress (key)
		local loadedData = progressData:get(key)
		local returnval = nil
		
		if  loadedData ~= ""  then
			returnval = tonumber (loadedData)
		end
	   
		return returnval
	end

	function saveProgress (key, value)
		progressData:set (key, tostring(value))
		progressData:save ()
	end


	function onEvent (eventName)

		if eventName == "Elevator Start"  then
			scene.startScene{scene=cutscene_Elevator, sceneArgs={}}
		end
	end

	
	local fenceGfx = {}
	fenceGfx[129] = Graphics.loadImage("background-129.png")
	fenceGfx[130] = Graphics.loadImage("background-130.png")
	fenceGfx[131] = Graphics.loadImage("background-131.png")
	
	
	function onDraw ()
		local fences = BGO.get({129,130,131})
		
		for k,v in pairs(fences) do
			
			Graphics.draw  {type=RTYPE_IMAGE,
							image=fenceGfx[v.id],
							priority=-38.0,
							isSceneCoordinates=true,
							x=v.x, y=v.y}
		end
	end


constantEarthquake = false
baseRevealed = false
bookshelfActor = nil



calleocaCarryDelay = 0
leftBballCarryDelay = 0
rightBballCarryDelay = 0

bballNpc = nil



testSpawnedActor = nil
prevTestSpawnedActor = nil


do	
	function onLoop ()		
		Text.print(tostring(mem(0x00B2D6BC,FIELD_DFLOAT)), 50, 100)
		Text.print(tostring(mem(0x00B2D6C4,FIELD_DFLOAT)), 50, 120)
		
		-- Define actor references
		--calleocaActor = cinematX.getActorFromKey ("calleoca")
		--leftBballActor = cinematX.getActorFromKey ("bballally")
		--rightBballActor = cinematX.getActorFromKey ("bballfoe")
		--ballActor = cinematX.getActorFromKey ("ball")
		--bookshelfActor = cinematX.getActorFromKey("bookshelf")
		
		
		worldLevelNames = {"The Preventable Forest Path", "???", "Just Rusty!"}
		worldCreatorNames = {"Pholtos", "SnoruntPyro", "Willhart"}

		-- Leek sanctuary
		--leekActors = {cinematX.getActorFromKey ("leek1"),
		--			  cinematX.getActorFromKey ("leek2"),
		--			  cinematX.getActorFromKey ("leek3")}


		for  k,v in pairs(leekActors)  do
			local warps = Warp.getIntersectingEntrance(v.smbxObjRef.x, v.smbxObjRef.y, v.smbxObjRef.x+16, v.smbxObjRef.y+96)
			
			local levelFullString = ""
			local levelNameString = " "
			local levelCreatorString = " "
			local dashStart = 0
			local dashEnd = 0
						
			if  warps[1] ~= nil  then
				if  warps[1].levelFilename ~= nil  then
					levelFullString = warps[1].levelFilename --worldLevelNames[k]
					dashStart = string.find(levelFullString, " - ")
					if  (dashStart == nil)  then
						levelNameString = string.gsub (levelFullString, ".lvl", "")
						levelCreatorString = "CREATOR UNKNOWN"
					else
						dashEnd = dashStart+3
						levelNameString = string.gsub (string.sub (levelFullString, dashEnd), ".lvl", "", 1)
						levelCreatorString = string.sub (levelFullString, 0, dashStart-1)
					end
				end
			end
			
			v.nameString = levelNameString
			v.altSubString = levelCreatorString
		end
					  
		
		
		-- Function-spawned actor
		if testSpawnedActor ~= nil  then
			--windowDebug ("TEST")
			--testSpawnedActor:jump (5)
			--testSpawnedActor.smbxObjRef.friendly = true
			
			--if  math.random (100) > 20  then
				testSpawnedActor:followActor (prevTestSpawnedActor, 8, 16, true)
				testSpawnedActor.shouldDespawn = false
				testSpawnedActor.canBeKilled = false
			--else
			--	testSpawnedActor:stopFollowing ()
			--end
		end
		
		-- Manage behavior of Calleoca actor
		if calleocaActor ~= nil then	
			calleocaActor:overrideAnimation (animData_Calleoca)
			--calleocaActor.helloVoice = VOICEID_CAL_01
			--calleocaActor.goodbyeVoice = VOICEID_CAL_02
			calleocaActor.shouldDespawn = false
			calleocaActor.shouldFacePlayer = true
			
			
			-- Follow block test - if the player is close to a certain block, Calleoca walks to it.  
			-- 						When the player walks away, Calleoca goes back to following them.
			
			calleocaActor:stopFollowing ()
			if  calleocaShouldFollowPlayer  ==  true  --[[and  cinematX.currentSceneState  ~=  cinematX.SCENESTATE_CUTSCENE--]]  then
				--Text.print ("TEST", 400,300)
			
				local targetBlock = cinematX.playerActor:closestBlock (293, 256)
				local targetNpc = cinematX.playerActor:closestNPC (NPCID.SATURN, 512)
				local targetShell = cinematX.playerActor:closestNPC (NPCID.KEY, 512)
				
				local targetMotherBrain = cinematX.playerActor:closestNPC (NPCID.MOTHERBRAIN, 512)
				
				local followPlayerCheck = true
				
				calleocaCarryDelay = calleocaCarryDelay - 1
				
				
				-- Carry and throw Pal around
				if  calleocaActor.isCarrying == true  then
					if  targetMotherBrain ~= nil  then
					
						calleocaActor:followNPC (targetMotherBrain, 6, -16, false)
						followPlayerCheck = false
						
						if  calleocaActor:distancePos (targetMotherBrain.x + (targetMotherBrain.width*0.5), calleocaActor:getCenterY()) < 16  then
							calleocaActor:throwCarried (0, 8)
							calleocaCarryDelay = 30
						end
				
					elseif  calleocaCarryDelay < 1  then
						calleocaActor:throwCarried ()
						calleocaCarryDelay = 30
					end
				else
					local npcToPickUp = nil
					
					if  targetNpc ~= nil  then
						npcToPickUp = targetNpc
					elseif  targetShell ~= nil  then
						npcToPickUp = targetShell
					end
					
					
					if  npcToPickUp ~= nil  then
						--calleocaActor:stopFollowing ()
						calleocaActor:followNPC (npcToPickUp, 6, 0, false)
						calleocaActor.shouldFacePlayer = false
						followPlayerCheck = false
						
						if  calleocaActor:distancePos (npcToPickUp.x + (npcToPickUp.width*0.5), npcToPickUp.y + (npcToPickUp.height*0.5)) < 48  and  calleocaCarryDelay < 1  then
							
							calleocaActor.carryStyle = 1
							if  math.random(0,100) < 50  then
								calleocaActor.carryStyle = 0
							end
								
							calleocaActor:grabNPC (npcToPickUp, 10)
							calleocaCarryDelay = 120
						end
					end
				end
				
				
				-- Break blocks with face
				if  targetBlock ~= nil  then
					if  cinematX.playerActor:dirToX (targetBlock.x)  ==  cinematX.playerActor:getDirection()  then
						--calleocaActor:stopFollowing ()
						calleocaActor:followBlock (targetBlock, 4, 0, false, 1)
						calleocaActor.shouldFacePlayer = false
						
						followPlayerCheck = false
						
						if  calleocaActor:distancePos (targetBlock.x+16, targetBlock.y+16) < 56  then
							targetBlock:remove(true)
						end
					end
				end
				
				if  followPlayerCheck == true  then
					--calleocaActor:stopFollowing ()
					calleocaActor:followActor (cinematX.playerActor, 8, 48, true)
					calleocaActor.shouldFacePlayer = true
				end
			end
		end
	
			
		local courtLeft = -159830 + 64
		local courtRight = -158859 - 88
		

		if  ballActor ~= nil  then
			ballActor.shouldDespawn = false
			bballNpc = ballActor.smbxObjRef
			--Text.print ("Actor does not equal nil", 80,180)			
		end
		
		if  bballNpc ~= nil		then
			--Text.print (tostring(cinematX.ID_MEM) .. ": " .. tostring(bballNpc:mem (cinematX.ID_MEM, cinematX.ID_MEM_FIELD)), 80,100)
			--Text.print ("0x12C: " .. tostring(bballNpc:mem (0x12C, FIELD_WORD)), 80,120)
			--Text.print ("0x12E: " .. tostring(bballNpc:mem (0x12E, FIELD_WORD)), 80,140)
			--Text.print ("0x136: " .. tostring(bballNpc:mem (0x136, FIELD_WORD)), 80,160)
		end
		
		
		leftBballCarryDelay = leftBballCarryDelay - 1
		rightBballCarryDelay = rightBballCarryDelay - 1
		
		
		
		if leftBballActor ~= nil then	
			leftBballActor.shouldDespawn = false
			leftBballActor.shouldFacePlayer = false
			
			bballNpc = leftBballActor:closestNPC (NPCID.SATURN, 9999)
			
			--[[
			if  leftBballActor.x > courtRight+32  then
				leftBballActor.x = courtRight+32
			end
			if  leftBballActor.x < courtLeft-32  then
				leftBballActor.x = courtLeft-32
			end]]
			
			if  leftBballActor:getX() > courtRight+32  then
				leftBballActor:setX(courtRight+32)
			end
			if  leftBballActor:getX() < courtLeft-32  then
				leftBballActor:setX(courtLeft-32)
			end
			
			
			-- Go after ball
			if  leftBballActor.isCarrying == true  then
					
					leftBballActor:walk (-6)

					if  leftBballCarryDelay < 1  then
						leftBballActor:throwCarried ()
						leftBballCarryDelay = 30
					end

				else
					if  bballNpc ~= nil  then
						leftBballActor:stopFollowing ()
						leftBballActor:followNPC (bballNpc, 6, 0, false, 1)

						if  leftBballActor:distancePos (bballNpc.x, bballNpc.y) < 48  and  leftBballCarryDelay < 1  then
							
							leftBballActor.carryStyle = 1
							if  math.random(0,100) < 50  then
								leftBballActor.carryStyle = 0
							end
								
							leftBballActor:grabNPC (bball, true, false)
							leftBballCarryDelay = math.random (60, 120)
						end
					end
				end
		end
		
		
		if rightBballActor ~= nil then
			rightBballActor.shouldDespawn = false
			rightBballActor.shouldFacePlayer = false		
			rightBballActor:overrideAnimation (animData_Calleoca)

			
			bballNpc = rightBballActor:closestNPC (NPCID.SATURN, 9999)
			
			
			if  rightBballActor:getX() > courtRight+32  then
				rightBballActor:setX(courtRight+32)
			end
			if  rightBballActor:getX() < courtLeft-32  then
				rightBballActor:setX(courtLeft-32)
			end
			
			
			-- Go after ball
			Text.print (tostring(rightBballActor.isCarrying), rightBballActor:getCenterX(), rightBballActor:topOffsetY(40))
			if  rightBballActor.isCarrying == true  then
					
				rightBballActor:walk (6)
				
				if  rightBballCarryDelay < 1  then
					rightBballActor:throwCarried ()
					rightBballCarryDelay = 30
				end
				
			else
				if  bballNpc ~= nil  then
					rightBballActor:stopFollowing ()
					rightBballActor:followNPC (bballNpc, 6, 0, false, 1)

					if  rightBballActor:distancePos (bballNpc.x, bballNpc.y) < 48  and  rightBballCarryDelay < 1  then
						
						rightBballActor.carryStyle = 1
						if  math.random(0,100) < 50  then
							rightBballActor.carryStyle = 0
						end
							
						rightBballActor:grabNPC (bballNpc, 9)
						rightBballCarryDelay = math.random (30,40)--60, 120)
					end
				end
			end

		end
		
		
		-- Restore music 
		if  player.section == 0  then
			--Audio.MusicPlay()
		end
		
		
		-- Hide bookshelf at runtime
		if  bookshelfActor ~= nil  then
			bookshelfActor.smbxObjRef.animationFrame = 1
		end
		
		-- Constant earthquake
		if  constantEarthquake == true  then
			Defines.earthquake = 10
		end
		
		
		-- DRAW FOREGROUND
		local fgX = 0
		local fgY = 0
		
		-- Trees
		if  player.section == 0  then
			fgX = (-1.2*(Camera.get()[1].x + 200000) + 100) % 1014			
			fgY =-1.1*(Camera.get()[1].y + 200000) - 1040

			local fgX1 = fgX + 1014
			local fgX2 = fgX - 1014

			local fgX3 = (-1.3*(Camera.get()[1].x + 200000) + 100) % 1014
			local fgX4 = fgX3 - 1014
			local fgX5 = fgX3 - 1014
			local fgY2 = -1.2*(Camera.get()[1].y + 200000) - 200

			
			Graphics.drawImageWP(fgTreeImage, fgX, fgY, 0.9)
			Graphics.drawImageWP(fgTreeImage, fgX1, fgY, 0.9)
			Graphics.drawImageWP(fgTreeImage, fgX2, fgY, 0.9)
			
			Graphics.drawImageWP(fgGrassImage, fgX3, fgY2, 0.9)
			Graphics.drawImageWP(fgGrassImage, fgX4, fgY2, 0.9)
			Graphics.drawImageWP(fgGrassImage, fgX5, fgY2, 0.9)
		end
		
		-- Shadows
		if  player.section == 3  then
			fgX = player.screen.left-800+12
			fgY = player.screen.top-800
			
			Graphics.drawImageWP(fgShadowImage, fgX, fgY, 0.9)
		end
	end
end
--]]

 
local snow = particles.Emitter(0, 0, Misc.resolveFile("particles/p_leaf.ini"), 1)
snow:AttachToCamera(Camera.get()[1]);

function onCameraUpdate()
	if  player.section == 0  then
		snow:Draw();
	end
end




--***************************************************************************************
-- 																						*
-- CINEMATX STUFF																		*
-- 																						*
--***************************************************************************************

--[[ This function acts as an additional filter, allowing you to specify the conditions
	  under which NPCs in your level become actors]]


--[[	  
cinematX.actorCriteria = function (myNPC)
	if myNPC.id == NPCID.SIGN then
		return false
	else
		return true
	end
end
]]



--***************************************************************************************
-- 																						*
-- COROUTINE SEQUENCES																	*
-- 																						*
--***************************************************************************************
do 
	function cutscene_Elevator ()
		--Audio.SeizeStream(-1)
		Audio.MusicStop()
		
		cinematX.waitSeconds(1)
		Audio.MusicOpen("Netarou Village Intro.ogg")
		Audio.MusicPlay()
		
		local timeAmt = 0
		while  (timeAmt < 7.5)  do
			Audio.MusicVolume(64 * (timeAmt/7.5))
			
			timeAmt = timeAmt + cinematX.deltaTime
			cinematX.yield()
		end
		Audio.MusicStop()
	end


	function cutscene_Calleoca ()

		-- Disable interactions with Calleoca
		calleocaActor.isInteractive = false
				
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
		
		-- Position the player
		cinematX.playerActor:positionToTalk (calleocaActor, 64, true)
		--[[
		cinematX.playerActor:walkToX (calleocaActor:forwardOffsetX(64), 4, 1, 2)
		cinematX.waitSeconds (0.5)
		
		cinematX.playerActor:lookAtActor (calleocaActor)
		cinematX.playerActor:walk (0)
		]]
		
		-- Calleoca speaks
		cinematX.startDialog  (calleocaActor, "Calleoca", "Hey there! I'mma follow you around a bit, hope you don't mind!", 30, 30, "")
		cinematX.waitForDialog ()
		
		-- Calleoca starts following the player
		calleocaShouldFollowPlayer = true
		calleocaActor:followActor (cinematX.playerActor, 8, 48, true)
		
		-- End cutscene
		--playSFX (VOICEID_CAL_03)
		cinematX.endCutscene ()
	end


	function routine_Welcome ()
				
		-- Get references for the actor I'm speaking to
		goopaActor = cinematX.getActorFromKey("goopaout1")
		goopaActorName = cinematX.getActorName_Key("goopaout1")
	
	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		-- Display dialogue
		local bubble = cinematX.startSpeech ("Welcome to our humble village! Please enjoy your stay!", {actor=goopaActor})
		cinematX.waitForTextblockClosed (bubble)
		--cinematX.startDialog  (goopaActor, goopaActorName, "Welcome to our humble village! Please enjoy your stay!", 140, 120, "")
		--cinematX.waitForDialog ()
	end

	
	function cutscene_Welcome ()
				
		-- Get references for the actor I'm speaking to
		goopaActor = cinematX.getActorFromKey("goopaout1")
		goopaActorName = cinematX.getActorName_Key("goopaout1")
	
	
		-- Position player and Calleoca	
		cinematX.playerActor:positionToTalk (goopaActor)

		cinematX.waitSeconds (0.01)
		
		if  calleocaShouldFollowPlayer == true  then
			calleocaActor:positionToTalk (goopaActor, 96, true, 0.5)
		else
			cinematX.waitSeconds (0.74)
		end

	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		-- Display dialogue
		local bubble = cinematX.startSpeech ("Welcome to our humble village! Please enjoy your stay!", {actor=goopaActor})
		cinematX.waitForTextblockClosed (bubble)
		--cinematX.startDialog  (goopaActor, goopaActorName, "Welcome to our humble village! Please enjoy your stay!", 140, 120, "")
		--cinematX.waitForDialog ()
	
		cinematX.endCutscene ()
	end

	function cutscene_Lore ()
		cinematX.waitSeconds (1)
		-- Placeholder
		cinematX.endCutscene ()
	end
	
	function cutscene_Silly ()
		cinematX.waitSeconds (1)
		-- Placeholder
		cinematX.endCutscene ()
	end

	
	function cutscene_SportsballInvite ()
		
		-- Get references for the actor I'm speaking to
		goopaActor = cinematX.getActorFromKey("goopastadium1")
		goopaActorName = cinematX.getActorName_Key("goopastadium1")
	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		-- Display dialogue
			cinematX.setDialogInputWait (true)
			cinematX.setDialogSkippable (false)
			cinematX.startQuestion  (goopaActor, goopaActorName, "Hey there, guy!  Wanna basket some sportsball?")
			cinematX.waitForDialog ()
			
			if  (cinematX.getResponse() == true)  then
				cinematX.startDialog  (goopaActor, goopaActorName, "Well tough luck, this minigame's not done yet!")
				cinematX.waitForDialog ()
			
			else
				cinematX.startDialog  (goopaActor, goopaActorName, "Arrighty then.  Have a nice day!")
				cinematX.waitForDialog ()
			end
	
		cinematX.endCutscene ()
	end
	
	

	
	function cutscene_BaseGuard ()
		
		-- Get references for the actor I'm speaking to
		goopaActor = cinematX.getActorFromKey("goopahouse1")
		goopaActorName = cinematX.getActorName_Key("goopahouse1")
	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		-- Display dialogue
		if  baseRevealed == false  then
			cinematX.startDialog  (goopaActor, goopaActorName, "Hello there, fellow law-abiding citizen!  What sort of completely legal merchandise can I get for you at our fine establishment that is not at all a...")
			cinematX.waitForDialog ()
			
			cinematX.startDialog  (goopaActor, goopaActorName, "...cover-up for the hideout of a secret organization?")
			cinematX.waitForDialog ()

			cinematX.startDialog  (goopaActor, goopaActorName, "How about a delicious FURBATAIL?  It can be yours today for the low, low price of only 9,999,999,999,992 raocoins!")
			cinematX.waitForDialog ()

			cinematX.startDialog  (goopaActor, goopaActorName, "...No?  Then scram, I ain't got no time for window shoppers.")
			cinematX.waitForDialog ()

			cinematX.startDialog  (goopaActor, goopaActorName, "And whatever you do, don't go snooping around near that bookshelf behind me!")
			cinematX.waitForDialog ()

			cinematX.startDialog  (goopaActor, goopaActorName, "Because it's a completely normal bookshelf.  There's nothing strange about it and it'd be a total waste of your time to examine it.  I guarantee it.")
			cinematX.waitForDialog ()
		else

			cinematX.startDialog  (goopaActor, goopaActorName, "Oh, hey, look at that!  I, uh, I wonder who put that secret room there huh? Ehehehehe...")
			cinematX.waitForDialog ()		
			
			cinematX.startDialog  (goopaActor, goopaActorName, "...the boss is gonna have my shell on a stake for this.")
			cinematX.waitForDialog ()		
		end
		
		cinematX.endCutscene ()
	end
	
	
	function cutscene_SecretRoom ()
		Audio.SeizeStream(-1)
		Audio.MusicPause()
		playSFX(28)
		cinematX.waitSeconds (1)
		playSFX(25)
		constantEarthquake = true
		cinematX.fadeScreenOut(0.5)
		cinematX.waitSeconds (0.5)
		
		triggerEvent("Goopinati Wall Reveal")
		cinematX.waitSeconds (0.5)
		
		constantEarthquake = false
		
		cinematX.fadeScreenIn(0.5)
		cinematX.waitSeconds (1.0)
		
		cinematX.endCutscene ()
		baseRevealed = true
	end
	
	
	function cutscene_Stephen ()
		-- Get references for the actor I'm speaking to
		feedActor = cinematX.getActorFromKey("feed")
		feedActorName = cinematX.getActorName_Key("feed")
	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		local bubble 
		
	
		-- Display dialogue		
		if  cinematX.playerNameASXT() == "Sheath"  then
			bubble = cinematX.startSpeech ("Hey, "..cinematX.playerNameASXT()..",  be careful out there.  Don't go jumping into random lava pits or anything.", {actor=feedActor})
			cinematX.waitForTextblockClosed (bubble)
			bubble = cinematX.startSpeech ("Orbit would be heartbroken if your juicy, tender meat got overcooked.", {actor=feedActor})
			cinematX.waitForTextblockClosed (bubble)
		else
			bubble = cinematX.startSpeech ("It's nice and quiet here, though I wish they had a butcher shop or something.  My little Orbit's not getting his daily nutrition.", {actor=feedActor})
			cinematX.waitForTextblockClosed (bubble)
		end
	
		cinematX.endCutscene ()
	end
	
	
	function cutscene_GenClerkA ()
		-- Get references for the actor I'm speaking to
		local actorRef = cinematX.getActorFromKey("genClerkA")
		local actorName = actorRef.nameString
	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		-- Display dialogue
		cinematX.startQuestion  (actorRef, actorName, "Welcome to Talkmart!  Is this your first time here?")
		cinematX.waitForDialog ()
		
		if  (cinematX.getResponse() == true)  then
			cinematX.startDialog  (actorRef, actorName, "We stock only the finest vegetables this side of the [insert level name here]!  Our produce is the pride of this pvillage!")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "In fact, we've been doing so well that we've adopted a new business model: for a one-time fee per product, we'll give you a lifetime supply of that item at this store!")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "(I know that doesn't sound like a sustainable business model, but trust me, it works out.)")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "Of course, if your finances are tight or you don't need that many, you can still buy a single item for a much lower cost.")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "If you see something you like, you can press and hold [DOWN] to make the purchase.")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "We no longer accept coins due to the NSMB-2 incident, but we will take a variety of other currencies including zenny, bottlecaps, golden puzzle pieces, giant stone wheels...")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "...karma, monopoly money, souls of the damned, bitcoin and, of course, raocoins.")
			cinematX.waitForDialog ()
		
			cinematX.startDialog  (actorRef, actorName, "Well then, I believe that's everything!  Thank you for shopping at Talkmart!, and we hope you have a gooptacular day!")
			cinematX.waitForDialog ()
		else
		
			cinematX.startDialog  (actorRef, actorName, "Thank you for shopping at Talkmart!  Have a gooptacular day!")
			cinematX.waitForDialog ()
		end	
		
		cinematX.endCutscene ()
	end
	
	function cutscene_clothClerkA ()
		-- Get references for the actor I'm speaking to
		local actorRef = cinematX.getActorFromKey("clothClerkA")
		local actorName = actorRef.nameString
	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		-- Display dialogue
		cinematX.startDialog  (actorRef, actorName, "[Insert costume shop info here]")
		cinematX.waitForDialog ()
		
		
		--[[
		cinematX.startQuestion  (actorRef, actorName, "Hi there!  Is this your first time here?")
		cinematX.waitForDialog ()
		
		if  (cinematX.getResponse() == true)  then
			cinematX.startDialog  (actorRef, actorName, "Here you can purchase a variety!")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "...karma, monopoly money, souls of the damned, bitcoin and, of course, raocoins.")
			cinematX.waitForDialog ()
		
			cinematX.startDialog  (actorRef, actorName, "Well then, I believe that's everything!  Thank you for shopping at Goopmart!, and we hope you have a gooptacular day!")
			cinematX.waitForDialog ()
		else
		
			cinematX.startDialog  (actorRef, actorName, "Thank you for shopping at Goopmart!  Have a gooptacular day!")
			cinematX.waitForDialog ()
		end	
		]]
		cinematX.endCutscene ()
	end
	
	
	local firstMessage = false
	
	function cutscene_MountRental ()
		local actorRef = cinematX.getActorFromKey("catowner")
		local actorName = actorRef.nameString
	
		-- Configure dialogue
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		-- Display dialogue
		cinematX.startDialog  (actorRef, actorName, "Why, howdy there!  Interested in renting out one of our fine furry friends?")
		cinematX.waitForDialog ()
		
		
		if  cinematX.playerNameASXT() == "Kood"  then
			cinematX.startDialog  (actorRef, actorName, "Oh, that fear in your eyes... there's no mistaking it!  You've got the eyes of someone who's deathly allergic to catllamas!")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "Best skedaddle on out of here all quick-like before alla the dander in the air gets to ya!  I've seen what happens, it ain't pretty.")
			cinematX.waitForDialog ()
			
			cinematX.endCutscene ()
			return
		end
			
		if  cinematX.playerNameASXT() == "raocow"  then
			cinematX.startDialog  (actorRef, actorName, "Oh, that glare in your eyes... there's no mistaking it!  You've got the eyes of someone who's had a bad history with horselizards!")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "And I hear ya, they are indeed entirely different creatures from catllamas.  Still can't risk letting you ride our kits.  Sorry, pardner, company policy.")
			cinematX.waitForDialog ()
			
			cinematX.endCutscene ()
			return
		end
		
		if  cinematX.playerNameASXT() == "Sheath"  then
			cinematX.startDialog  (actorRef, actorName, "Oh, that inattentive look in your eyes... there's no mistaking it!  You've got the eyes of someone wholly unprepared to ride a catllama!")
			cinematX.waitForDialog ()
			cinematX.startDialog  (actorRef, actorName, "I appreciate your enthusiasm, little lady, but it'll take more than that to handle one 'o our girls!  Feel free to pet 'em as much as you like, though, they love the attention!")
			cinematX.waitForDialog ()
			
			cinematX.endCutscene ()
			return
		end
		
		
		-- Initial freebie
		local hadFirstFree = loadProgress ("hadFreeCatllama")
		local rented = false
		
		if  hadFirstFree ~= 1  then
			if  cinematX.playerNameASXT() == "Demo"  then
				if  firstMessage == false  then
					cinematX.startDialog  (actorRef, actorName, "Oh, that look in your eye... there's no mistaking it!  You've got the eye of someone who has a sister who really understands catllamas!")
					cinematX.waitForDialog ()
					cinematX.startQuestion  (actorRef, actorName, "Want to rent one out?  Normally we charge customers 4 raocoins, but I'll let you take one out for free just this once!  You share blood with a catllama aficionado, so I trust you'll treat our darlin's well!")
				else
					cinematX.startQuestion  (actorRef, actorName, "Normally we charge customers 4 raocoins, but I'll let you take one out for free just this once!  You share blood with a catllama aficionado, so I trust you'll treat our darlin's well!")
				end
				cinematX.waitForDialog ()
			end
			
			if  cinematX.playerNameASXT() == "Iris"  then
				if  firstMessage == false  then
					cinematX.startDialog  (actorRef, actorName, "Oh, that gleam in your eye... there's no mistaking it!  You've got the eye of someone who really understands catllamas!")
					cinematX.waitForDialog ()
					cinematX.startQuestion  (actorRef, actorName, "Want to rent one out?  Normally we charge customers 4 raocoins, but for you I'll make an exception, just this once!  Consider it a token of appreciation from one catllama fan to another!")
				else
					cinematX.startQuestion  (actorRef, actorName, "Normally we charge customers 4 raocoins, but I'll let you take one out for free just this once!  Consider it a token of appreciation from one catllama fan to another!")
				end
				cinematX.waitForDialog ()
			end

			
			-- Took it
			if  (cinematX.getResponse() == true)  then
				rented = true
				saveProgress ("hadFreeCatllama", 1)
			
			else
				cinematX.startDialog  (actorRef, actorName, "Okie-doke, slowpoke.  Don't worry, my offer has no expiration date, so mosey back on over here whenever you're ready!")
				cinematX.waitForDialog ()
				firstMessage = true
			end			
	
	
		-- Subsequent rentals
		else
			cinematX.startQuestion  (actorRef, actorName, "For a measly 4 raocoins you can ride out of this here stable with whichever li'l catllama tickles your fancy!  So how 'bout it, pardner?")
			cinematX.waitForDialog ()
			
			if  (cinematX.getResponse() == true)  then
				-- Check raocoins
				if  true  then
					rented = true
				else
					cinematX.startDialog  (actorRef, actorName, "Sorry, li'l missy, but it looks like you're a tiny bit short on funds!  I can't keep handin' out freebies or else I won't be able to feed the li'l rascals!")
					cinematX.waitForDialog ()						
				end
			else
				cinematX.startDialog  (actorRef, actorName, "Suit yourself.  We're always here if you happen to change your mind!")
				cinematX.waitForDialog ()						
				
			end			
		
		end
		

		-- Once rented
		if  rented == true  then
			cinematX.startDialog  (actorRef, actorName, "Arrighty, just head on in there and pick out whichever one you like!")
			cinematX.waitForDialog ()		
			cinematX.startDialog  (actorRef, actorName, "You'll be able to ride 'er as long as you can keep her around, but don't worry too much if you lose track of her; our catllamas always seem to find their way back safe and sound.")
			cinematX.waitForDialog ()		
			cinematX.startDialog  (actorRef, actorName, "That being said, we do like to recognize folks who personally return our li'l catnips, so if you bring her back once you're done with her we'll refund half of your initial payment.")
			cinematX.waitForDialog ()		
		end
		
		cinematX.endCutscene ()
	end
	
	
	function cor_catllama1 ()
		Audio.playSFX(Misc.resolveFile("yoshi-swallow.ogg"))
	end
	
	
	function coroutine_Sign1 ()
		cinematX.panToObj (1, cinematX.getActorFromKey("goopasib3").smbxObjRef, 24, false)
		
		cinematX.setDialogSkippable (false)
		cinematX.setDialogInputWait (false)
		cinematX.startDialog (nil, "The sign says", "Hello! I'm a sign!", 160)
		cinematX.waitSeconds (2)
		cinematX.endDialogLine ()
		--cinematX.waitForDialog ()
		
		if  testSpawnedActor == nil  then
			prevTestSpawnedActor = cinematX.playerActor
		else
			prevTestSpawnedActor = testSpawnedActor
		end
		
		testSpawnedActor = cinematX.spawnNPCActor (293, player.x,player.y-128, 1, "{key=spawned, name=HERBERT, icon=0, priority=1, sub= }")
		--windowDebug (tostring(testSpawnedActor.uid))
		--cinematX.endCutscene ()
	end
	
	function coroutine_Sign2 ()
		
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
		cinematX.startDialog  (nil, "The sign says", "Ye Olde Generale Grocherie Goodes Shoppe")
		cinematX.waitForDialog ()
		
		cinematX.endCutscene ()
	end
	
	function coroutine_Sign3 ()
		
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
		cinematX.startDialog  (nil, "The sign says", "Totally legit souvenir shop.  Nothing suspicious about it, no need to be alarmed.")
		cinematX.waitForDialog ()
		
		cinematX.endCutscene ()
	end
	
	function cutscene_Sign4 ()
		
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
		cinematX.startDialog  (nil, "The sign says", "Shop")
		cinematX.waitForDialog ()
		
		cinematX.endCutscene ()
	end
		
	function cutscene_Sign11 ()
		
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
		cinematX.startDialog  (nil, "The sign says", "Goopinati HQ secret entrance.  If you're not a Goopa, we'd greatly appreciate it if you could inform the idiot guarding this place that the boss is going to have his shell on a stake for this.")
		cinematX.waitForDialog ()
		
		cinematX.endCutscene ()
	end
	
	
	function cutscene_TestQuest ()	
		--cinematX.setDialogSkippable (true)
		--cinematX.setDialogInputWait (true)
	
		--cinematX.waitSeconds (1)
		
		local actorName = cinematX.getActorName_Key("goopasib1")
		local actorRef = cinematX.getActorFromKey("goopasib1")
		
		if  	(cinematX.isQuestStarted("test") == false)   then
			cinematX.setDialogInputWait (true)
			cinematX.setDialogSkippable (false)
			cinematX.startQuestion  (actorRef, actorName, "Can you do me a favor?", 140, 120, "")
			cinematX.waitForDialog ()
			
			if  (cinematX.getResponse() == true)  then
				cinematX.beginQuest ("test")
				cinematX.panToObj (1, cinematX.getActorFromKey("goopasib3").smbxObjRef, 4, true)
				cinematX.startDialog  (actorRef, actorName, "Go talk to my bro, "..cinematX.getActorName_Key("goopasib3")..".", 140, 120, "")
				cinematX.waitForDialog ()
				cinematX.resetNPCMessageNew_Key ("goopasib2")
				cinematX.resetNPCMessageNew_Key ("goopasib3")
				
				cinematX.panToObj (1, player, 8, true)
			else
				cinematX.startDialog  (actorRef, actorName,  "Well, fine then! Be that way, jerk!", 140, 120, "")
				cinematX.waitForDialog ()
			end
		
		elseif 	(cinematX.isQuestFinished("test") == false)   then
			--windowDebug ("Test B")
			cinematX.startDialog  (actorRef, actorName,  "Go talk to my bro, "..cinematX.getActorName_Key("goopasib3")..".", 140, 120, "")		
			cinematX.waitForDialog ()
		
		else
			--windowDebug ("Test C")
			cinematX.startDialog  (cactorRef, actorName,  "You completed the quest, now you can rest!", 140, 120, "")			
			cinematX.waitForDialog ()
		end
		
		cinematX.endCutscene ()
	end
	

	function cutscene_TestQuest2 ()
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		--cinematX.waitSeconds (1)

		local actorName = cinematX.getActorName_Key("goopasib3")
		local actorRef = cinematX.getActorFromKey("goopasib3")
		
		if 		(cinematX.isQuestFinished ("test"))  then
			cinematX.startDialog  (actorRef, actorName,  "You don't need to talk to me anymore.", 140, 120, "")
			cinematX.waitForDialog ()
		
		elseif  (cinematX.isQuestStarted ("test"))  then
			cinematX.finishQuest ("test")
			cinematX.startDialog  (actorRef, actorName,  "Quest complete! Yaaaay!", 140, 120, "")
			cinematX.waitForDialog ()
			cinematX.resetNPCMessageNew_Key ("goopasib1")
			cinematX.resetNPCMessageNew_Key ("goopasib2")
			cinematX.resetNPCMessageNew_Key ("goopasib3")
			
		else
			cinematX.startDialog  (actorRef, actorName,  "Talk to my sister, "..cinematX.getActorName_Key("goopasib1")..", first.", 140, 120, "")
			cinematX.waitForDialog ()
		end
			
		cinematX.endCutscene ()
	end	
	
	
	function cutscene_TestQuest3 ()
		cinematX.setDialogSkippable (true)
		cinematX.setDialogInputWait (true)
	
		--cinematX.waitSeconds (1)
		local actorName = cinematX.getActorName_Key("goopasib2")
		local actorRef = cinematX.getActorFromKey("goopasib2")
		
		
		if  	(cinematX.isQuestFinished("test") == true)   then
			cinematX.startQuestion  (actorRef, actorName,  "Would you like to reset the quest?", 140, 120, "")
			cinematX.waitForDialog ()
			
			if  (cinematX.getResponse() == true)  then
				cinematX.initQuest ("test")
				cinematX.startDialog  (actorRef, actorName,  "Done, you may now test the quest again.", 140, 120, "")
				cinematX.waitForDialog ()
				cinematX.resetNPCMessageNew_Key ("goopasib1")
				cinematX.resetNPCMessageNew_Key ("goopasib2")
				cinematX.resetNPCMessageNew_Key ("goopasib3")
			end
		
		else
			cinematX.startDialog  (actorRef, actorName,  "Please finish the quest before talking to me.", 140, 120, "")			
			cinematX.waitForDialog ()
		end
			
		cinematX.endCutscene ()
	end
	
	
	function cutscene_GoopaSiblingOther()
		cinematX.waitSeconds (1)
		-- Placeholder
		cinematX.endCutscene ()
	end
	
	
end