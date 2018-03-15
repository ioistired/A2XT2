local airmeter = 1950 --Air Meter
local reserveitem = 0 --Reserve Item ID
local reservefall = 0 --Falling Reserve Item ID
local reservetimer = 0 --Reserve Item Air Heal Delay
local startcheck = true --Check for Start of Level
local corndist1 = 0 --Distance From Corn1
local corndist2 = 0 --Distance From Corn2
local corndist3 = 0 --Distance From Corn3
local corndist5 = 0 --Distance From Corn5
local liftcheck = true --Check for Second Lift
local corn1check = false --Check for Corn1 in Section 5
local corn2check = false --Check for Corn2 in Section 5
local corn1lift = false --Check for Corn1 on second lift
local corn2lift = false --Check for Corn2 on second lift
local layercheck = false --Check for Hidden Second Lift Switch
local secondswitchcheck = true --Check for stopping the second lift
local booairmeter = 180 --Big Boo's Air Meter
local nocornallowed1 = false --Check if Corn1 is in a restricted area
local nocornallowed2 = false --Check if Corn2 is in a restricted area

local cornImg = Graphics.loadImage("cornshield.png") --Corn Shield Image
local gasImg = Graphics.loadImage("Gas.png") --Gas Image
local fade = loadAPI("fade")

 --Draw air meter, corn shield, and green overlay
function onHUDDraw()
	 --Find corn in the player's section
	local corn1 = NPC.get(154, player.section) --Corn at start
	local corn2 = NPC.get(155, player.section) --Corn at midpoint
	local corn3 = NPC.get(156, player.section) --NPC Corn (can't pick up, but still works)
	local corn4 = NPC.get(157, player.section) --Extra Corn (doesn't work) (used with stuck NPC and in goal area)
	local corn5 = NPC.get(31, player.section) --Corn, the Corn (still growing, can't pluck) (still works) (used in corn farm)
	
	 --Display air	
	Text.print("Air: ", 328, 76)
	Text.print(string.format("%.1f", airmeter / 65), 408, 76)
	
	 --Show corn shields
	for i,npc in pairs(corn1) do
		if (player.section >= 3) then
			Graphics.drawImageToSceneWP(cornImg, (npc.x - 96), (npc.y - 96), 0.8, 3.0)
		end
	end
	for i,npc in pairs(corn2) do
		if (player.section >= 3) then
			Graphics.drawImageToSceneWP(cornImg, (npc.x - 96), (npc.y - 96), 0.8, 3.0)
		end
	end
	for i,npc in pairs(corn3) do
		if (player.section >= 3) then
			Graphics.drawImageToSceneWP(cornImg, (npc.x - 96), (npc.y - 96), 0.8, 3.0)
		end
	end
	for i,npc in pairs(corn4) do
		if (player.section >= 3) then
			Graphics.drawImageToSceneWP(cornImg, (npc.x - 96), (npc.y - 96), 0.8, 3.0)
		end
	end
	for i,npc in pairs(corn5) do
		if (player.section >= 3) then
			Graphics.drawImageToSceneWP(cornImg, (npc.x - 96), (npc.y - 96), 0.8, 3.0)
		end
	end
	
	 --Draw gas
	if (player.section >= 3) then
		Graphics.drawImage(gasImg, 0, 0)
	end
end

 --Trigger Corn 2 if you enter Section 3 after getting midpoint with Corn 1
function onLoadSection2()
	if (UserData.getValue("gameguy888_midpoint") == 1) then
		triggerEvent("Corn 2")
	end
end
	
 --Every frame
function onLoop()
	 --Find corn everywhere
	local corn1 = NPC.get(154, -1) --Corn at start
	local corn2 = NPC.get(155, -1) --Corn at midpoint
	local corn3 = NPC.get(156, -1) --NPC Corn (can't pick up, but still works)
	local corn5 = NPC.get(31, -1) --Corn, the Corn (still growing, can't pluck) (still works) (used in corn farm)

	 --Set midpoint flag if at level start
	if (UserData.getValue("gameguy888_midpoint") == nil) or ((startcheck) and (player.section == 0)) then 
		UserData.setValue("gameguy888_midpoint", 0) UserData.save()
	end
	 --Trigger Corn 2 if starting at midpoint and midpoint flag is set
	if (UserData.getValue("gameguy888_midpoint") == 1) and startcheck then
		triggerEvent("Corn 2")
	end
	
	 --Reset level start flag
	startcheck = false
	
	 --Corn1 checks and updates
	for i,npc in pairs(corn1) do
		 --Never despawn corn1
		npc:mem(0x12A, FIELD_WORD, 120)
		 --Update corn1 distance
		corndist1 = (math.sqrt((((npc.x + (npc.width / 2)) - (player.x + (player.width / 2)))^2) + (((npc.y + (npc.height / 2)) - (player.y + (player.height / 4)))^2)))
		 --Set Midpoint flag if corn1 is in the midpoint section
		if (npc:mem(0x146, FIELD_WORD) == 2) then
			UserData.setValue("gameguy888_midpoint", 1) UserData.save()
		end
		 --Checks if corn1 is on the second lift
		local corn1onlift = BGO.getIntersecting(npc.x, npc.y, (npc.x + npc.width), (npc.y + npc.height))
		for i,bgo in pairs(corn1onlift) do
			if (bgo.id == 19) then
				corn1lift = true
			else
				corn1lift = false
			end
		end
		 --Is corn1 section 5?
		if (npc:mem(0x146, FIELD_WORD)) == 4 then
			corn1check = true
		else
			corn1check = false
		end
		 --Check for No Corn Allowed sign
		if ((((npc.x > -131994) and (npc.x < -131528)) and ((npc.y > -140194) and (npc.y < -139615)))
		or (((npc.x > -116082) and (npc.x < -115653)) and ((npc.y > -119809) and (npc.y < -119409)))
		or (((npc.x > -112525) and (npc.x < -112232)) and ((npc.y > -119827) and (npc.y < -119479)))) then
			if (nocornallowed1 == false) then
				triggerEvent("No Corn Allowed")
				nocornallowed1 = true
			end
		else
			if (nocornallowed1 == true) then
				triggerEvent("Corn Allowed")
				nocornallowed1 = false
			end
		end
	end
	
	 --Corn2 checks and updates
	for i,npc in pairs(corn2) do
		 --Never despawn corn2
		npc:mem(0x12A, FIELD_WORD, 120)
		 --Update corn2 distance
		corndist2 = (math.sqrt((((npc.x + (npc.width / 2)) - (player.x + (player.width / 2)))^2) + (((npc.y + (npc.height / 2)) - (player.y + (player.height / 4)))^2)))
		 --Checks if corn2 is on the second lift
		local corn2onlift = BGO.getIntersecting(npc.x, npc.y, (npc.x + npc.width), (npc.y + npc.height))
		for i,bgo in pairs(corn2onlift) do
			if (bgo.id == 19) then
				corn2lift = true
			else
				corn2lift = false
			end
		end
		 --Is corn2 section 5?
		if (npc:mem(0x146, FIELD_WORD)) == 4 then
			corn2check = true
		else
			corn2check = false
		end
		 --Check for No Corn Allowed sign
		if ((((npc.x > -131994) and (npc.x < -131528)) and ((npc.y > -140194) and (npc.y < -139615)))
		or (((npc.x > -116082) and (npc.x < -115653)) and ((npc.y > -119809) and (npc.y < -119409)))
		or (((npc.x > -112525) and (npc.x < -112232)) and ((npc.y > -119827) and (npc.y < -119479)))) then
			if (nocornallowed2 == false) then
				triggerEvent("No Corn Allowed")
				nocornallowed2 = true
			end
		else
			if (nocornallowed2 == true) then
				triggerEvent("Corn Allowed")
				nocornallowed2 = false
			end
		end
	end
	
	 --Corn3 checks and updates
	for i,npc in pairs(corn3) do
		 --Update corn3 distance
		corndist3 = (math.sqrt((((npc.x + (npc.width / 2)) - (player.x + (player.width / 2)))^2) + (((npc.y + (npc.height / 2)) - (player.y + (player.height / 4)))^2)))
	end
	
	 --Corn5 checks and updates
	for i,npc in pairs(corn5) do
		 --Update corn3 distance
		corndist5 = (math.sqrt((((npc.x + (npc.width / 2)) - (player.x + (player.width / 2)))^2) + (((npc.y + (npc.height / 2)) - (player.y + (player.height / 4)))^2)))
	end
	
	 --If no corn1 or corn2 in section 5, show lift switch anyway
	if ((corn1check == false) and (corn2check == false)) or (corn1lift or corn2lift) then
		if (layercheck == false) and liftcheck then
			triggerEvent("Second Lift Switch Show")
			layercheck = true
		end
	else
		if (layercheck == true) then
			triggerEvent("Second Lift Switch Hide")
			layercheck = false
		end
	end
	
	 --Stop second lift at the end of the track
	local secondlift = NPC.get(62, -1)
	for i,npc in pairs(secondlift) do
		if (npc.x >= -108932) and secondswitchcheck then
			triggerEvent("Second Lift Stuck")
			secondswitchcheck = false
		end
	end
	
	 --When not dead and also near corn
	if (player:mem(0x13C, FIELD_FLOAT) == 0) and ((corndist1 <= 112) or (corndist2 <= 112) or (corndist3 <= 112) or (corndist5 <= 112)) then	
		 --Refill air when not in water or empty
		if (player:mem(0x36, FIELD_WORD) == 0) and (airmeter > 0) then
			if (airmeter < 1945) then
				airmeter = airmeter + 5
			 --But don't go over full
			else
				 --Don't cancel out 3up moon effect
				if (airmeter <= 1950) then
					airmeter = 1950
				end
			end
		else
		 --Lose air in water even if near corn
			airmeter = airmeter - 1
		end
		
	else
		 --Don't go negative
		if (airmeter <= 0) then
			 --Hurt if out of air
			player:harm()
			 --If killed
			if (player:mem(0x13C, FIELD_FLOAT) ~= 0) then
				airmeter = 0
			 --If survived
			else
				 --Wait for Tanooki statue, power up, and power down to run out
				if (player:mem(0x4E, FIELD_FLOAT) == 0) and (player:mem(0x128, FIELD_FLOAT) == 0) and (player:mem(0x140, FIELD_FLOAT) == 0) then
					airmeter = 650
				end
			end
		else
			 --If not in water or near corn, deplete air
			if (player:mem(0x36, FIELD_WORD) == 0) then 
				if (player.section  >= 3) then
					airmeter = airmeter - 1
				end
			else
			 --Water depletes more 
				if (airmeter >= 3) then
					airmeter = airmeter - 3
				else
					airmeter = 0
				end
			end
		end
	end
	
	 --Restore air no matter what in safe zones
	if (player.section < 3) then
		if (airmeter < 1940) then
			airmeter = airmeter + 10
		 --But don't go over full
		else
			 --Don't cancel out 3up moon effect
			if (airmeter <= 1950) then
				airmeter = 1950
			end
		end
	end
	
	 --If dead, 0 out air
	if (player:mem(0x13C, FIELD_FLOAT) ~= 0) then
		airmeter = 0
	end
	
	 --Determine dropped item and start timer
	if (player.dropItemKeyPressing == true) and (reserveitem ~= 0) then
		reservefall = reserveitem
		reservetimer = 325
	end
	 --Time down
	if (reservetimer > 0) then
		reservetimer = reservetimer - 1
	end
	 --Time is over
	if (reservetimer == 0) then
		reservefall = 0
	end
	 --Update current reserve item
	reserveitem = player.reservePowerup
	
	 --Big Boo Gag
	local bigboo = NPC.get(44, player.section)
	for i,npc in pairs(bigboo) do
		if ((player.x <= -99140) and (player.y <= -105440))	or (booairmeter < 180) then
			booairmeter = booairmeter - 1
			if (booairmeter <= 0) then
				npc:kill()
			end
		end
	end
end


function onNPCKill(eventObj, killedNPC, killReason)
     --Add air when things are collected, but not when they match a falling reserve item
	if (killReason == 9) then
     --Check if the NPC is on screen, otherwise it must have despawned
        if (killedNPC:mem(0x12A, FIELD_WORD) > 0) then
			 --Is a Radish or Carrot
			if ((killedNPC:mem(0xE2, FIELD_WORD) == 9) or (killedNPC:mem(0xE2, FIELD_WORD) == 250)) and (killedNPC:mem(0xE2, FIELD_WORD) ~= reservefall) then
				if (airmeter > 650) and (airmeter <= 1950) then
					airmeter = 1950
				end
				if (airmeter <= 650) then
					airmeter = airmeter + 1300
				end
			end
			 --Is a Tier 2 Powerup or Red Rupee
			if ((killedNPC:mem(0xE2, FIELD_WORD) == 14) or (killedNPC:mem(0xE2, FIELD_WORD) == 264)
			or (killedNPC:mem(0xE2, FIELD_WORD) == 34) or (killedNPC:mem(0xE2, FIELD_WORD) == 169)
			or (killedNPC:mem(0xE2, FIELD_WORD) == 170) or (killedNPC:mem(0xE2, FIELD_WORD) == 253)) and (killedNPC:mem(0xE2, FIELD_WORD) ~= reservefall) then
				if (airmeter > 1300) and (airmeter <= 1950) then
					airmeter = 1950
				end
				if (airmeter <= 1300) then
					airmeter = airmeter + 650
				end
			end
			 --Is a Coin or Green Rupee
			if (killedNPC:mem(0xE2, FIELD_WORD) == 10) or (killedNPC:mem(0xE2, FIELD_WORD) == 88)
			or (killedNPC:mem(0xE2, FIELD_WORD) == 138) or (killedNPC:mem(0xE2, FIELD_WORD) == 251) then
				if (airmeter > 1917) and (airmeter <= 1950) then
					airmeter = 1950
				end
				if (airmeter <= 1917) then
					airmeter = airmeter + 33
				end	
			end
			 --Is a Blue Rupee or Raocoin
			if (killedNPC:mem(0xE2, FIELD_WORD) == 252) or (killedNPC:mem(0xE2, FIELD_WORD) == 274) then
				if (airmeter > 1787) and (airmeter <= 1950) then
					airmeter = 1950
				end
				if (airmeter <= 1787) then
					airmeter = airmeter + 163
				end	
			end
			 --Is a 1up
			if (killedNPC:mem(0xE2, FIELD_WORD) == 90) then
				if (airmeter <= 1950) then
					airmeter = 1950
				end
			end
			 --Is a Moon
			if (killedNPC:mem(0xE2, FIELD_WORD) == 188) then
				if (airmeter <= 1950) then				
					airmeter = 5850
				end
			end
        end
    end
end


function onEvent(eventName)
	 --For the conversation at the start
	if (eventName == "Guy Text 2") then
		if ((player:mem(0xF0, FIELD_WORD)) == 1) then
			triggerEvent("Demo Response")
		end
		if ((player:mem(0xF0, FIELD_WORD)) == 2) then
			triggerEvent("Iris Response")
		end
		if ((player:mem(0xF0, FIELD_WORD)) == 3) then
			triggerEvent("Kood Response")
		end
		if ((player:mem(0xF0, FIELD_WORD)) == 4) then
			triggerEvent("raocow Response")
		end
		if ((player:mem(0xF0, FIELD_WORD)) == 5) then
			triggerEvent("Sheath Response")
		end
	end
	
	 --Stop checking for Corn at second lift
	if (eventName == "Second Lift Start") then
		liftcheck = false
	end
	
	 --Trigger Fences
	if (eventName == "Fence Switch to Off") then
		triggerEvent("Left Fences Extend")
		triggerEvent("Right Fences Extend")
		triggerEvent("Top Fences Extend")
	end
	
	 --Trigger Corn2 if you reach the top of section 6
	if (eventName == "Corn 2") then
		UserData.setValue("gameguy888_midpoint", 1) UserData.save()
	end
end
