package.path = package.path .. ";./worlds/cinematX_World/?.lua" .. ";./?.lua"
local cinematX = loadSharedAPI("cinematX")
local mathX = loadSharedAPI("mathematX")
--cinematX.showDebugInfo = true --config (true, false, true, true, true)
NPCID = loadSharedAPI("npcid")


-- Active coroutine reference
activeRaceRoutine = nil


do
	-- Individual NPC animation settings
	animData_Calleoca = cinematX.readAnimData("calleoca.anim");
	--[[
	animData_Calleoca [cinematX.ANIMSTATE_NUMFRAMES] = 40
	animData_Calleoca [cinematX.ANIMSTATE_IDLE] = "4-9"
	animData_Calleoca [cinematX.ANIMSTATE_TALK] = "15-15"
	animData_Calleoca [cinematX.ANIMSTATE_WALK] = "16-17"
	animData_Calleoca [cinematX.ANIMSTATE_RUN] = "20-23"
	animData_Calleoca [cinematX.ANIMSTATE_JUMP] = "26-26"
	animData_Calleoca [cinematX.ANIMSTATE_FALL] = "32-32"
	]]
	NPCID_CALLEOCA = 101

	
	-- Data management
	raceData = Data (Data.DATA_WORLD, "calleocaRace", true)

	raceStarted = false
	racerActor = cinematX.getActorFromKey ("racer")
	raceEndX = Section (0).boundary.right-512

	
	function saveRaceData (key, value)
		raceData:set (key, tostring(value))
		raceData:save ()
	end

	function loadRaceData (key)
		local loadedData = raceData:get(key)
		local returnVal = 0
	   
		if  loadedData ~= ""  then
			returnVal = tonumber (loadedData)
		end
	   
		return returnVal
	end

	cheated = false
	uncheated = false
	allDagadons = false
	gotHit = false
	attempts = loadRaceData ("attempts")
	wins = loadRaceData ("wins")
	losses = loadRaceData ("losses")
	perfects = loadRaceData ("perfects")
	annoyance = loadRaceData ("annoyance")
	forcewin = loadRaceData ("forcewin")
	
	saveRaceData ("annoyance", annoyance)
	saveRaceData ("forcewin", forcewin)

	
	
	function onStart ()
		-- Filter to big and no mount
		player.powerup = PLAYER_BIG
		player:mem(0x108, FIELD_WORD, 0)
		gotHit = false
	end
		
	
	
	function onLoop ()				
	
		if  player.powerup == PLAYER_SMALL  and  player:mem(0x122, FIELD_WORD) == 0   then
			player.powerup = PLAYER_BIG
			gotHit = true
		end
		
		if  player:mem(0x122, FIELD_WORD) == 2  then
			if  player:mem (0x106, FIELD_WORD) == -1  then
				player.speedX = 6
			else
				player.speedX = -6
			end
		end
	
	
		if  #NPC.get(NPCID.DRAGONCOIN, -1) == 0  then
			if  allDagadons == false  then
				triggerEvent ("Show Perfect Star")
			end
			allDagadons = true
		end
	
		racerActor = cinematX.getActorFromKey ("racer")
		endRacerActor = cinematX.getActorFromKey ("endRacer")
		debugActor = cinematX.getActorFromKey ("debug")
		
		raceEndX = Section(player.section).boundary.right-512
		
		if (racerActor ~= nil) then
			racerActor.shouldDespawn = false
			racerActor:overrideAnimation (animData_Calleoca)
		end
		
		if (endRacerActor ~= nil) then
			endRacerActor.shouldDespawn = false
			endRacerActor:overrideAnimation (animData_Calleoca)
		end
	end

	
	
	function scene_eraseMemory ()
		cinematX.playerActor:positionToTalk (debugActor, 64, true)
		
		cinematX.startDialog  (debugActor, debugActor.nameString, "Hi there, welcome to the super-secret debug room the level creator may or may not have left in by mistake!")
		cinematX.waitForDialog ()
		
		cinematX.startQuestion  (debugActor, debugActor.nameString, "Would you like to reset Calleoca's memory?.")
		cinematX.waitForDialog ()
		
		if  (cinematX.getResponse() == true)  then			
			cinematX.startDialog  (debugActor, debugActor.nameString, "Okie-dokie!  I'll just wipe all of her memories of her encounters with you in this level.")
			cinematX.waitForDialog ()
			cinematX.startDialog  (debugActor, debugActor.nameString, "Memories she will never get back.")
			cinematX.waitForDialog ()		
			cinematX.startDialog  (debugActor, debugActor.nameString, "Ever.")
			cinematX.waitForDialog ()
			cinematX.startDialog  (debugActor, debugActor.nameString, "But it's just for the sake of testing and debugging and all that, right?  It's not like you're doing it for some petty reason, like, say...")
			cinematX.waitForDialog ()
			
			if  annoyance > 0  then
				cinematX.startDialog  (debugActor, debugActor.nameString, "You feel guilty for upsetting her, or you just want her to keep being nice to you.")
				cinematX.waitForDialog ()
				cinematX.startDialog  (debugActor, debugActor.nameString, "You can't undo stuff like that in real life, you know.  As the old cliche goes, " .. '"'.."there's no reset button."..'"')
				cinematX.waitForDialog ()
			
			elseif  losses > wins  then
				cinematX.startDialog  (debugActor, debugActor.nameString, "You want to erase all traces of some embarassing losses.")
				cinematX.waitForDialog ()
				cinematX.startDialog  (debugActor, debugActor.nameString, "You can't undo stuff like that in real life, you know.  As the old cliche goes, " .. '"'.."there's no reset button."..'"')
				cinematX.waitForDialog ()

			else
				cinematX.startDialog  (debugActor, debugActor.nameString, "You like maintaining a certain level of control over your peers.")
				cinematX.waitForDialog ()
				cinematX.startDialog  (debugActor, debugActor.nameString, "You're not the type to manipulate those close to you, right?")
				cinematX.waitForDialog ()
			end
			
			cinematX.startDialog  (debugActor, debugActor.nameString, "But hey, I get it.  Maybe you're just here to enjoy a silly action platformer game, and you've already had your fill of video games guilt-tripping you.")
			cinematX.waitForDialog ()
			cinematX.startDialog  (debugActor, debugActor.nameString, "These aren't real people, right?  They don't have free will, they're all just fictional characters following pre-programmed routines.  So why should you care about them?")
			cinematX.waitForDialog ()			
			cinematX.startDialog  (debugActor, debugActor.nameString, "So, from one NPC to another...")
			cinematX.waitForDialog ()
			cinematX.startDialog  (debugActor, debugActor.nameString, "...have a nice day and a clear conscience!")
			cinematX.waitForDialog ()
			
			saveRaceData ("attempts", 0)
			saveRaceData ("wins", 0)
			saveRaceData ("losses", 0)
			saveRaceData ("perfects", 0)
			saveRaceData ("annoyance", 0)

		else
			cinematX.startDialog  (debugActor, debugActor.nameString, "Okie-dokie, then!  Have a nice day and a clear conscience!")
			cinematX.waitForDialog ()		
		end
		
		cinematX.endCutscene ()
	end
	
	
	function scene_startRace ()	
		cinematX.playerActor:positionToTalk (racerActor, 64, true)
		racerActor.isInteractive = false
	
		if  annoyance > 0  then
			if  annoyance > 1  then
				cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "You know, I'm tempted to just let you keep your normal damage system...")
				cinematX.waitForDialog ()
				cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "But the guy who made this level doesn't want to put in the extra effort.  He'd rather just write more dialogue branches.")
				cinematX.waitForDialog ()				
			end

			cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Poof.  You can't be killed now.  Yay for you.")
			cinematX.waitForDialog ()
			racerActor:setDirection (DIR_RIGHT)
		
		else
			if  attempts > 0  then
				cinematX.startDialog  (racerActor, racerActor.nameString, "Hey there!  Ready for a rematch?")
				cinematX.waitForDialog ()						
			
			else
				cinematX.startDialog  (racerActor, racerActor.nameString, "<wave>Heeeeeey</wave>, guess what's at the end of this spooky, flooded, baddie-infested cave?")
				cinematX.waitForDialog ()		
				cinematX.startDialog  (racerActor, racerActor.nameString, "That's right, a leek!  Ya wanna race for it?")
				cinematX.waitForDialog ()
				
				cinematX.waitSeconds (0.5)
				racerActor:setDirection (DIR_RIGHT)
				
				cinematX.startDialog  (racerActor, racerActor.nameString, "...okay, I mean, it's not like you have a choice in the matter, just, you know, figured I should ask anyway!")
				cinematX.waitForDialog ()
				
				racerActor:setDirection (DIR_LEFT)
				
				cinematX.startDialog  (racerActor, racerActor.nameString, "<shake box>Don't worry, though!  I'll share a bit of my magical anime powers with you to make this more of a fair competition!")
				cinematX.waitForDialog ()
			end
				
			-- Magic animu powers		
			racerActor:setAnimState (cinematX.ANIMSTATE_ATTACK1)
			
			local i = 15
			math.randomseed( os.time() )
			
			while (i > 0)  do
				Audio.playSFX (Misc.resolveFile("sound\\zelda-sword-beam.ogg"))
				cinematX.playerActor:jump (4)
				Animation.spawn(131, cinematX.playerActor:getX() + math.random (-12,12), cinematX.playerActor:getSpeedY() + mathX.lerp (cinematX.playerActor:getY(), cinematX.playerActor:getBottomY()-16, math.random(0,1)))
				i = i -1
				cinematX.waitSeconds (0.25)
			end
			racerActor:setAnimState (cinematX.ANIMSTATE_IDLE)
			cinematX.waitSeconds (1)
			
			
			-- Explanation of the mechanics
			if  attempts > 0  then
				cinematX.startDialog  (racerActor, racerActor.nameString, "Again, you can't be killed but enemies can still knock you back.")
				cinematX.waitForDialog ()
				cinematX.waitSeconds (0.5)
				racerActor:setDirection (DIR_RIGHT)

				cinematX.startDialog  (racerActor, racerActor.nameString, "Okay, let's get started!")
				cinematX.waitForDialog ()
				
			else
				cinematX.startDialog  (racerActor, racerActor.nameString, "There we go!  You won't take any lasting damage, but hits will still stun you and probably knock you back!")
				cinematX.waitForDialog ()
				cinematX.startDialog  (racerActor, racerActor.nameString, "Now you have no excuse to not finish the race!  So I'll be waiting for you at the finish line, <wave>m'kay?</wave>")
				cinematX.waitForDialog ()

				cinematX.waitSeconds (0.5)
				racerActor:setDirection (DIR_RIGHT)
				
				cinematX.startDialog  (racerActor, racerActor.nameString, "Okie dokie, then... <shake box>on the count of 3!")
				cinematX.waitForDialog ()
			end
		end
		
		Audio.MusicStopFadeOut (1000)
		cinematX.endCutscene ()
		cinematX.waitSeconds (1)
		Audio.MusicVolume(0)
		
		cinematX.waitSeconds (1.5)
		
		Audio.playSFX (Misc.resolveFile("racecount_1.ogg"))
		triggerEvent ("Show One")
		cinematX.waitSeconds (1)
		
		Audio.playSFX (Misc.resolveFile("racecount_1.ogg"))
		triggerEvent ("Show Two")
		cinematX.waitSeconds (1)
		
		Audio.playSFX (Misc.resolveFile("racecount_1.ogg"))
		triggerEvent ("Show Three")
		cinematX.waitSeconds (1)
		
		Audio.playSFX (Misc.resolveFile("racecount_2.ogg"))
		triggerEvent ("Show Go")
		cinematX.waitSeconds (1)
		
		Audio.MusicVolume(128)
		raceStarted = true
		triggerEvent ("Race Start")
		
		attempts = attempts + 1
		saveRaceData ("attempts", attempts)

		activeRaceRoutine = cinematX.beginRace (racerActor, racerActor:getX (), raceEndX, 
												coroutine_racerPath, coroutine_LoseRace, coroutine_WinRace)
	end
	
	
	function coroutine_racerPath ()
		triggerEvent("Race Start")
		racerActor:walkToX (raceEndX, 5)
	
		cinematX.waitSeconds (1.0)
		racerActor:jump (8)
				
		cinematX.waitSeconds (1.2)
		racerActor:jump (9)	
		
		cinematX.waitSeconds (1.1)
		racerActor:jump (8)	
		
		--cinematX.startDialog (racerActor, racerActor.nameString, "Last one there's a rotten egg!")
		
		cinematX.waitSeconds (1.0)
		racerActor:jump (4)	
		
		cinematX.waitSeconds (1)--1.0)
		racerActor:jump (4)	
		
		-- In water
		cinematX.waitSeconds (0.8)
		
		while (racerActor:getX() < -197000)  do
			--racerActor:walkToX (raceEndX, 8)
			--racerActor:setSpeedX (8)
			racerActor:walkForward (0)
			racerActor.smbxObjRef.x = racerActor.smbxObjRef.x + 2
			if  racerActor:getY() > -200100  then
				--racerActor:walkForward (8)
				--racerActor:setSpeedX (8)
				racerActor:jump (1)	
			end
			cinematX.yield ()
		end

		-- In water
		while (racerActor:getX() < -196800)  do
			if  racerActor.isUnderwater == true  then
				cinematX.waitSeconds (0.1)
				racerActor:jump (6)	
			end
			racerActor:walkToX (raceEndX, 2)
			racerActor:setSpeedX (2)
			cinematX.yield ()
		end
		
		racerActor:walkToX (raceEndX, 6)
		cinematX.waitSeconds (0.75)
		
		racerActor:walkToX (raceEndX, 5)
		racerActor:jump (5)	
		
		cinematX.waitSeconds (0.75)
		racerActor:walkToX (raceEndX, 6)
		racerActor:jump (6)	
		
		-- Jump up the zigzag
		cinematX.waitSeconds (0.5)
		racerActor:walkToX (raceEndX, 5)
		racerActor:jump (10)	
		
		cinematX.waitSeconds (0.8)
		racerActor:walkToX (raceEndX, -3)
		racerActor:jump (8)	
		
		cinematX.waitSeconds (0.8)
		racerActor:walkToX (raceEndX, 1)
		racerActor:jump (9)	
		
		cinematX.waitSeconds (0.75)
		racerActor:walkToX (raceEndX, 4)
		
		cinematX.waitSeconds (0.5)
		racerActor:walkToX (raceEndX, 3.5)
		racerActor:jump (9.25)

		cinematX.waitSeconds (0.57)
		racerActor:walkToX (raceEndX, 3)
		cinematX.waitSeconds (0.035)
		racerActor:walkToX (raceEndX, 1)
		cinematX.waitSeconds (0.145)
		racerActor:jump (8)
		
		-- Spike section
		cinematX.waitSeconds (0.45)
		racerActor:walkToX (raceEndX, 4)

		cinematX.waitSeconds (0.25)
		racerActor:jump (8)
		
		cinematX.waitSeconds (0.75)
		--racerActor:walkToX (raceEndX, 5)
		cinematX.waitSeconds (0.2)
		racerActor:jump (6)
		
		cinematX.waitSeconds (1.15)
		racerActor:walkToX (raceEndX, 5)
		racerActor:jump (7)
		
		while (racerActor:getX() < -190030)  do
			racerActor:walkForward (0)
			racerActor.smbxObjRef.x = racerActor.smbxObjRef.x + 3
			if  racerActor:getY() > -200100  then
				--racerActor:walkForward (8)
				--racerActor:setSpeedX (8)
				racerActor:jump (1)	
			end
			cinematX.yield ()
		end
		
		-- Resurface
		while (racerActor:getX() < -189940)  do
			if  racerActor.isUnderwater == true  then
				cinematX.waitSeconds (0.1)
				racerActor:jump (6)	
			end
			racerActor:walkToX (raceEndX, 2)
			racerActor:setSpeedX (2)
			cinematX.yield ()
		end
		
		-- Jump into last water
		racerActor:walkToX (raceEndX, 5)
		cinematX.waitSeconds (1)
		racerActor:jump (5)
		
		-- Last swim
		while (racerActor:getX() < -189060)  do
			racerActor:walkForward (0)
			racerActor.smbxObjRef.x = racerActor.smbxObjRef.x + 3
			if  racerActor:getY() > -200100  then
				--racerActor:walkForward (8)
				--racerActor:setSpeedX (8)
				racerActor:jump (1)	
			end
			cinematX.yield ()
		end
		
		-- Last resurface
		while (racerActor:getX() < -188900)  do
			if  racerActor.isUnderwater == true  then
				cinematX.waitSeconds (0.1)
				racerActor:jump (6)	
			end
			racerActor:walkToX (raceEndX, 2)
			racerActor:setSpeedX (2)
			cinematX.yield ()
		end
		
		
		-- Second-to-last dash
		while (racerActor:getX() < -187880)  do
			racerActor:walkForward (5)
			cinematX.yield ()
		end

		
		-- Jump up to the final dash
		racerActor:walkToX (raceEndX, 1)
		racerActor:jump (9)	
		
		cinematX.waitSeconds (1)
		racerActor:walkToX (raceEndX, 0)
		racerActor:jump (9)	
		
		cinematX.waitSeconds (0.75)
		racerActor:walkToX (raceEndX, 2)
		racerActor:jump (8)	
		
		cinematX.waitSeconds (0.8)
		racerActor:walkToX (raceEndX+96, 5)
		
		
		--racerActor:walk (0)

		-- Now in water
		--racerActor:jump (4)	
	end
	
	
	function coroutine_WinRace ()
		cinematX.abortCoroutine (activeRaceRoutine)
		activeRaceRoutine = nil
		cinematX.runCutscene (cutscene_Win)
	end
	
	
	function cutscene_Win ()
		-- Play victory fanfare
		cinematX.waitSeconds (1)
			
				
		-- Change sections
		cinematX.fadeScreenOut (0.5)
		cinematX.waitSeconds (0.5)
		cinematX.changeSection (1, 0, 1)
		player.x = -179672
		player.y = -180254
		player.speedX = 0
		player.direction = DIR_RIGHT
		
		endRacerActor = cinematX.getActorFromKey ("endRacer")
		--endRacerActor:setX(player.x+32)
		--endRacerActor:setY(player.x+32)
		
		cinematX.waitSeconds (2)
		
		
		-- If the player cheated, don't count it
		if  Defines.player_hasCheated == true  or  uncheated == true  then
			
			if  annoyance > 0  then
				cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Sorry, no cheating allowed.")
				cinematX.waitForDialog ()
			
			else
				if  	perfects >= 1  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Why are you cheating!?  You already got a perfect run!")
					cinematX.waitForDialog ()

				elseif	wins >= 1  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "So desperate to get a perfect run that you'd resort to cheating, huh?")
					cinematX.waitForDialog ()				
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "I won't accept this run, but keep at it and I'm sure you'll get it!")
					cinematX.waitForDialog ()	
				
				else
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Ahahaha!  Nice try, but I can tell when someone's been cheating!")
					cinematX.waitForDialog ()
					
					if  uncheated == true  then
						cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Not only that, but you tried to trick me by entering THAT ONE CODE before crossing the finish line!")
						cinematX.waitForDialog ()
					end
					
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Come back when you're ready to play fair, m'kay?")
					cinematX.waitForDialog ()
				end
			end
			
			player:kill()
		
		-- If the player hasn't cheated
		else
			wins = wins + 1
			saveRaceData ("wins", wins)	
		
			
			-- If the player got a perfect run
			if  (gotHit == false  and  allDagadons == true)  or  forcewin == 1  then
				perfects = perfects + 1
				saveRaceData ("perfects", perfects)	

				
				if	perfects >= 6  then
					annoyance = annoyance + 1
					saveRaceData ("annoyance", annoyance)	
				end

				
				if  	perfects == 1  then
					endRacerActor:setAnimState (cinematX.ANIMSTATE_HURT)
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Oh, wow...")
					cinematX.waitForDialog ()
					endRacerActor:setAnimState (cinematX.ANIMSTATE_TALK1)
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Not only did you get all the raocoins, but you didn't get hit once!  That's... kind of incredible!")
					cinematX.waitForDialog ()
					
					if  	attempts <= 1  then
						cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "And on your first try, too!  Like, seriously, you're a spectacular player!")
					elseif  attempts == 2  then
						cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "And on your second attempt, too!  That's quite an accomplishment!")
					elseif  attempts == 3  then
						cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "I guess third time's the charm, hmm?")
					elseif  attempts == 4  then
						cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "And it only took you four tries!  Nice job!")
					elseif  attempts == 5  then
						cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "It seems five is your lucky number, huh?")
					else
						cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "It took some perseverence, but all that practice finally paid off!")
					end
					cinematX.waitForDialog ()
					
				elseif	perfects <= 2  then
					endRacerActor:setAnimState (cinematX.ANIMSTATE_TALK1)
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Congrats on another perfect run!  I don't have any extra rewards, but know that this cyclops is truly impressed!")
					cinematX.waitForDialog ()
				
				elseif	perfects == 3  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Your third perfect run!  That's worth some bragging rights, I suppose?")
					cinematX.waitForDialog ()			
				
				elseif	perfects == 4  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Wow, uh, you must really like this level enough to get four perfect runs!")
					cinematX.waitForDialog ()			
					endRacerActor:setAnimState (cinematX.ANIMSTATE_TALK1)
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "But there's a lot more to this game than just racing me!  Why not go enjoy the rest of it?")
					cinematX.waitForDialog ()					
				
				elseif	perfects == 5  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Yet another perfect run... don't you have anything better to do?")
					cinematX.waitForDialog ()			
								
				elseif	perfects == 6  then	
					endRacerActor:setAnimState (cinematX.ANIMSTATE_TALK2)
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Yeah, okay, this is getting ridiculous. It's time to move on.")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "You're spending an unhealthy amount of time on this level when you could be spending an unhealthy amount of time on some other level!")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Have you beaten the final boss yet?  Why not go do THAT like a bajillion times?")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "I don't know, just... do something else.  Please.")
					cinematX.waitForDialog ()			
				
				elseif	perfects == 7  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Okay, now you're just showing off.  Like, yeah, we get it, you're amazing, woohoo.")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Just take the leek already, I don't even care anymore.")
					cinematX.waitForDialog ()			
					
				
				elseif	perfects == 8  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Seriously, WHY!?  What do you want, player!?  Are you going for some world record?  Do you want to hear everything I have to say?")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Are you trying to prove something?  Are you trying to SPITE me!?  Do you think this is FUNNY!?")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "There's no reward for annoying me!  There's no hidden leek or costume or card or achievement or brownie points or anything!")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "All I wanted to do was have a little fun in a deadly flooded mine, but NO!  You had to go ruin it with this weird obssession or vendetta whatever this is!")
					cinematX.waitForDialog ()			
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Well, I hope you got what you wanted!  I hope all of this was worth it!")
					cinematX.waitForDialog ()			
								
				elseif	perfects == 8  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "You're a butt.")
					cinematX.waitForDialog ()			
				
				else
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "...")
					cinematX.waitForDialog ()			
				end
			
			
			elseif  annoyance == 0  then
				
				-- Got hit but got all durgen kurgens
				if 	(gotHit == true  and  allDagadons == true)  or  forcewin == 2  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Not too shabby!")
					cinematX.waitForDialog ()
					
					endRacerActor:setAnimState (cinematX.ANIMSTATE_TALK1)
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Pretty impressive getting all those raocoins, even if you didn't make it through completely unscathed!")
					cinematX.waitForDialog ()
					
					
				-- Didn't get all dorgelheimers but no damage taken
				elseif 	(gotHit == false  and  allDagadons == false)  or  forcewin == 2  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "That was some pretty great dodging skills there!  Shame you weren't able to collect all the raocoins, though.")
					cinematX.waitForDialog ()
				
				
				-- Won without either accomplishment
				else
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "That was fun!  We should race again sometime!")
					cinematX.waitForDialog ()
				end
				
				
				cinematX.waitSeconds (0.5)
				endRacerActor:setDirection (DIR_RIGHT)
				endRacerActor:setAnimState (cinematX.ANIMSTATE_IDLE)
				
				cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Well, that leek is all yours, now.  You won it fair and square!")
				cinematX.waitForDialog ()
				
				cinematX.waitSeconds (0.5)
				endRacerActor:setDirection (DIR_LEFT)
				
				cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "And with that, I'm outta here.  Later, alligator!")
				cinematX.waitForDialog ()
				
			else	
				endRacerActor:setAnimState (cinematX.ANIMSTATE_TALK2)
				
				if  annoyance == 1  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Congrats.")
					cinematX.waitForDialog ()		
					
				elseif  annoyance == 2  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "Just take the leek already, I don't even care anymore.")
					cinematX.waitForDialog ()
					
				elseif  annoyance >= 3  then
					cinematX.startDialog  (endRacerActor, endRacerActor.nameString, "...")
					cinematX.waitForDialog ()
				end
			end
			
			
			-- Fly off into the sunset like a majestic anti-gravity tow truck
			while (endRacerActor:getY() > Section (1).boundary.top - 64)  do
				endRacerActor:jump (8)
				endRacerActor:setSpeedX (math.random (-4,4))
				cinematX.waitSeconds (0.5)
				cinematX.yield ()
			end
			
			endRacerActor:setX (Section (1).boundary.right + 128)		
		end
		
		--triggerEvent ("Win Race")
		cinematX.endCutscene ()
	end
	
	function coroutine_LoseRace ()
		player:kill()
	end
end


