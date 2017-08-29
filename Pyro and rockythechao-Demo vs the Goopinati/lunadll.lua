local wrapTable = {}
wrapTable[0] = -200608;
wrapTable[1] = -180608;
wrapTable[2] = -160608;
wrapTable[4] = -120608;
wrapTable[5] = -100608;

local multipoints = API.load("multipoints");
multipoints.addLuaCheckpoint(-139424, -140224, 3);
multipoints.addLuaCheckpoint(-97024+32, -100320, 5);

cinematX = loadSharedAPI("cinematX")
cinematX.config (true, false, false, true, false)
cinematX.textbloxSubtitle = false

local eventu = API.load("eventu")
local rng = API.load("rng")

local doCos = true;

colliders = loadSharedAPI("colliders");
NPCID = loadSharedAPI("npcid")

local initialRun = false;

do
	animData_Noctel = {}
	animData_Noctel [cinematX.ANIMSTATE_NUMFRAMES] = 22
	animData_Noctel [cinematX.ANIMSTATE_IDLE] = "0-0"
	animData_Noctel [cinematX.ANIMSTATE_TALK] = "1-2"
	animData_Noctel [cinematX.ANIMSTATE_WALK] = "1-2" --For the battle, change this to "5-6"
	animData_Noctel [cinematX.ANIMSTATE_RUN] = "4-5"
	animData_Noctel [cinematX.ANIMSTATE_JUMP] = "8-8"
	animData_Noctel [cinematX.ANIMSTATE_FALL] = "10-10"
	animData_Noctel [cinematX.ANIMSTATE_HURT] = "13-13"
	animData_Noctel [cinematX.ANIMSTATE_DEFEAT] = "13-13"
	animData_Noctel [cinematX.ANIMSTATE_ATTACK1] = "14-14"
	animData_Noctel [cinematX.ANIMSTATE_ATTACK2] = "15-18"
	animData_Noctel [cinematX.ANIMSTATE_ATTACK3] = "20-20"


	-- Collision stuff
	bossCollider = colliders.Box(-99, -99, 32, 36);
	--bossCollider:Debug(true);
	playerBouncedOnBoss = false
	playerSpinjumped = false
	playerCollidedWithBoss = false
	bossVulnerable = true
	bossCollisionOn = true
	
	bombCollision = false;
end

function characterChooseDialog(demoText,irisText,koodText,raocowText,sheathText)
	if player:mem(0xF0,FIELD_WORD) == 1 then
		cinematX.startDialog(noctel,"Demo",demoText,30,1,"")
	elseif player:mem(0xF0,FIELD_WORD) == 2 then
		cinematX.startDialog(noctel,"Iris",irisText,30,1,"")
	elseif player:mem(0xF0,FIELD_WORD) == 3 then
		cinematX.startDialog(noctel,"Kood",koodText,30,1,"")
	elseif player:mem(0xF0,FIELD_WORD) == 4 then
		cinematX.startDialog(noctel,"raocow",raocowText,30,1,"")
	elseif player:mem(0xF0,FIELD_WORD) == 5 then
		cinematX.startDialog(noctel,"Sheath",sheathText,30,1,"")
	end
end

function multipoints.onLevelStart()
	if initialRun == false then
		initialRun = true
		if player.section == 0 then
			cinematX.runCutscene (startLevelCutscene)
		end
	end
end

function bossLoop()
	for k,v in pairs(NPC.get(101,-1)) do
		v:mem(0x12A,FIELD_WORD,180)
		
		for _, b in pairs(Block.getIntersecting(v.x - 64, v.y, v.x + 64, v.y)) do
			noctel:walkToX(player.x,4)
			noctel:setAnimState (cinematX.ANIMSTATE_ATTACK2)
		end
	end

	if (noctel ~= nil) and (noctel.smbxObjRef ~= nil) then
		bossCollider = colliders.getSpeedHitbox(noctel.smbxObjRef)
		--bossCollider:Draw (0x00FF2299)
	
		playerBouncedOnBoss,playerSpinjumped = colliders.bounce(player, bossCollider);
		playerCollidedWithBoss = colliders.speedCollide (player,bossCollider)
			
		if  bossCollisionOn == true and bossVulnerable == true then		
			if playerCollidedWithBoss == true then
				if playerBouncedOnBoss == true then
					colliders.bounceResponse (player)
					--player.speedX = player.speedX + (math.max(1.5, math.abs (bossDistToPlayerX*0.2)) * bossDirToPlayerX)
					bossTakeDamage ()
				else
					player:harm ()
				end
			end
			
			listofnpcs = {13,265,108,291,266,292,171,237}
			
			local _,_,list = colliders.collideNPC(listofnpcs,bossCollider);
			for _,v in ipairs(list) do
				v:kill();
				playSFX(36)
			end
			
			local _,_,list = colliders.collideNPC(134,bossCollider);
			for _,v in ipairs(list) do
				v:kill();
				bossTakeDamage ()
				playSFX(43)
			end
			
		end
		
	end
end

function onLoop()

	-- FILTER SHEATH
	
	if player:mem(0xF0,FIELD_WORD) == 5 then
		player:mem(0xF0,FIELD_WORD,1)
	end
	
	-- WRAP PLAYER

	for _, b in pairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
		if b.id == 99 then
			player.y = wrapTable[player.section]-64;
			Audio.playSFX("GravityFlip.wav")
		end
	end
	
	-- WRAP ENEMIES
	
	wrapEnemies = NPC.get()
	for _,v in pairs(wrapEnemies) do
		for _, b in pairs(BGO.getIntersecting(v.x, v.y - 4, v.x + 32, v.y + 36)) do
			if b.id == 120 then
				v.y = wrapTable[v:mem(0x146,FIELD_WORD)];
				Audio.playSFX("GravityFlip.wav")
			end
		end
	end
	
	-- LOWER FIREBALLS
	
	fireballs = NPC.get(246,1)
	for _,v in pairs(fireballs) do
		v.speedY = 2;
	end
	
	-- GOOPA BOMBS

	for _,v in pairs(NPC.get(155,player.section)) do
		if v:mem(0x0A,FIELD_WORD) == 2 then
			v:kill()
			a = NPC.spawn(120, v.x - 32, v.y, player.section)
			a:mem(0x118,FIELD_FLOAT,-1)
			a.speedY = -7;
			a.speedX = -2;
			a = NPC.spawn(120, v.x + 32, v.y, player.section)
			a:mem(0x118,FIELD_FLOAT,1)
			a.speedY = -7;
			a.speedX = 2;
		end
	end
	
	-- CINEMATX
	goopa = cinematX.getActorFromKey("goopa1")
	sign1 = cinematX.getActorFromKey("sign1")
	noctel = cinematX.getActorFromKey("noctel")
	
	if  noctel ~= nil  then  
		noctel:overrideAnimation (animData_Noctel) 
		
		noctX = noctel:getX()
		noctY = noctel:getY()
		
		if bossVulnerable == false then
			noctel:setAnimState (cinematX.ANIMSTATE_HURT)
		end
	end
	
	bossLoop()
	
	-- KILL LUA MUSIC WHEN DEAD
	
	if player:mem(0x13E,FIELD_WORD) ~= 0 then
		Audio.MusicStop()
	end
	
	-- KILL ENEMIES IN CUTSCENE
	if doCos == false then
		for _,v in pairs(NPC.get(155,player.section)) do
			v:kill()
		end
		for _,v in pairs(NPC.get(134,player.section)) do
			v:kill()
		end
		for _,v in pairs(NPC.get(120,player.section)) do
			v:kill()
		end
		for _,v in pairs(NPC.get(30,player.section)) do
			v:kill()
		end
	end
	
end

function onLoadSection6()
	cinematX.runCutscene (noctelBeginFight)
end

-- CINEMATX CUTSCENES

function startLevelCutscene()
	cinematX.setDialogSkippable (true)
	cinematX.setDialogInputWait (true)
	cinematX.waitSeconds (1)
		
	cinematX.startDialog(goopa,"???","Oh no, guys, they're here!!",30,30,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(goopa,"???","Run!! Prepare the defenses!!",30,30,"")
	cinematX.waitForDialog ()
	
	triggerEvent("goopinati 3")

	cinematX.waitSeconds (0.5)
	
	cinematX.endCutscene ()
end

function signread1()
	cinematX.setDialogSkippable (true)
	cinematX.setDialogInputWait (true)
	
	cinematX.startDialog(sign1,"Sign","We've been doing some experiments on the Goopas lately. So far, we've created a Goopa that ignores the laws of gravity.",30,30,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(sign1,"Sign","Further tests will be conducted.",30,30,"")
	cinematX.waitForDialog ()
	
	cinematX.endCutscene ()
end

function signread2()
	cinematX.setDialogSkippable (true)
	cinematX.setDialogInputWait (true)
	
	cinematX.startDialog(sign1,"Sign","Another experimental success. We've made a sort of vertical wrapping field. How this physically even works, we still don't know.",30,30,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(sign1,"Sign","For reference, members - the fields are where the arrows are.",30,30,"")
	cinematX.waitForDialog ()
	
	cinematX.endCutscene ()
end

function signread3()
	cinematX.setDialogSkippable (true)
	cinematX.setDialogInputWait (true)
	
	cinematX.startDialog(sign1,"Sign","We've successfully made a Goopa shell that splits into more Goopas when it hits the ground. Our armies are destined to be ENDLESS!",30,30,"")
	cinematX.waitForDialog ()
	
	cinematX.endCutscene ()
end

function signread4()
	cinematX.setDialogSkippable (true)
	cinematX.setDialogInputWait (true)
	
	cinematX.startDialog(sign1,"Sign","Finally, a way to keep intruders out! We've invented a special dotted barrier that only us Goopas can get through.",30,30,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(sign1,"Sign","Unfortunately, they're hilariously expensive. Still, though. MWAHAHAHA.",30,30,"")
	cinematX.waitForDialog ()
	
	cinematX.endCutscene ()
end

function noctelBeginFight()
	cinematX.setDialogSkippable (true)
	cinematX.setDialogInputWait (true)
	
	noctel:setAnimState (cinematX.ANIMSTATE_IDLE)
	
	cinematX.startDialog(noctel,"???","Nyehehe...We've been expecting you...",30,30,"")
	cinematX.waitForDialog ()
	characterChooseDialog("Who the heck are you?","Wha...who the heck are you?","Who are you and what do you want?!","Um...who are you?","Um...who are you?")
	--cinematX.startDialog(noctel,playerNameASXT,"Wha...who the heck are you?",30,30,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel","I am the leader of the organization that knows everything...Noctel.",30,40,"")
	cinematX.waitForDialog ()
	characterChooseDialog("That's a stupid name.","That name is one of the dumbest names ever.","That name REEKS of tyranny and terror.","That name is...kinda dumb.","Oh.")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel","You clearly don't know ANYTHING about the great Goopinati Organization. We strike fear in the citizens of Grass Place Town.",30,60,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel","We control everything. The shops, the banks, the economy, the events of the world...the lives of the people here.",30,60,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel","We enforce the Goopa rule. We use Furba corpses for an energy-efficent power source.",30,50,"")
	cinematX.waitForDialog ()
	characterChooseDialog("Oh, ew.","That's insane!","You monsters!","Woah...why would you murder Furbas like that?!","Oh...")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel","Heh...I can see you're already afraid. And just to let you know...",30,40,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel","...I have one of those Super Leeks you're looking for.",30,40,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel","I know you want it...and we'll battle for it. En guarde!",30,40,"")
	cinematX.waitForDialog ()
	Audio.SeizeStream(-1)
	Audio.MusicOpen("a2xt_NoctelFight_WIP2.ogg")
	Audio.MusicPlay()
	animData_Noctel [cinematX.ANIMSTATE_WALK] = "5-6"
	animData_Noctel [cinematX.ANIMSTATE_IDLE] = "5-6"
	animData_Noctel [cinematX.ANIMSTATE_TALK] = "5-6"
	
	noctel.closeIdleAnim = cinematX.ANIMSTATE_IDLE
	noctel.farIdleAnim = cinematX.ANIMSTATE_IDLE
	noctel.talkAnim = cinematX.ANIMSTATE_TALK
	noctel.walkAnim = cinematX.ANIMSTATE_WALK
	noctel.runAnim = cinematX.ANIMSTATE_RUN
	
	noctel:setAnimState (cinematX.ANIMSTATE_JUMP)
	noctel:setSpeedY(-9)
	
	BUTTS = NPC.spawn(142,noctX,noctY,player.section)
	BUTTS.speedX = 5;
	BUTTS.speedY = -8;
	
	cinematX.endCutscene ()
	cinematX.beginBattle ("Grand High Ingoopitor Noctel", 10, cinematX.BOSSHPDISPLAY_BAR2, battleStartCoroutine)
end

function battleStartCoroutine()
	if doCos == true then
	cinematX.waitSeconds(1)
	noctel:walkToX(player.x,9)
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK2)
	cinematX.waitSeconds(1)
	noctel:setAnimState (cinematX.ANIMSTATE_JUMP)
	noctel:setSpeedY(-9)
	cinematX.waitSeconds(1)
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK3)
	a = NPC.spawn(120, noctX - 32, noctY, player.section)
	a:mem(0x118,FIELD_FLOAT,-1)
	a.speedY = -7;
	a.speedX = -2;
	a = NPC.spawn(120, noctX + 32, noctY, player.section)
	a:mem(0x118,FIELD_FLOAT,1)
	a.speedY = -7;
	a.speedX = 2;
	playSFX(22)
	cinematX.waitSeconds(.5)
	noctel:setAnimState (cinematX.ANIMSTATE_IDLE)
	cinematX.waitSeconds(1.5)
	noctel:walkToX(player.x,9)
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK2)
	cinematX.waitSeconds(1)
	noctel:setAnimState (cinematX.ANIMSTATE_JUMP)
	noctel:setSpeedY(-9)
	cinematX.waitSeconds(1)
	
	radicola = rng.randomInt(1,4)
	if radicola == 1 then
		bossAttack1()
	elseif radicola == 2 then
		bossAttack2()
	elseif radicola == 3 then
		bossAttack3()
	elseif radicola == 4 then
		bossAttack4()
	elseif radicola == 5 then
		bossAttack5()
	end
	end
end

function bossAttack1()
	if doCos == true then
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK1)
	noctelBananaSpray()
	cinematX.waitSeconds(.5)
	noctel:setAnimState (cinematX.ANIMSTATE_IDLE)
	noctel:walkForward(1)
	cinematX.waitSeconds(.5)
	noctelBananaSpray()
	cinematX.waitSeconds(.5)
	noctelBananaSpray()
	cinematX.waitSeconds(1)
	noctelCooldown()
	end
end

function bossAttack2()
	if doCos == true then
	noctel:setSpeedY(-10)
	cinematX.waitSeconds(2)
	earthquake(10)
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK3)
	playSFX(22)
	a = NPC.spawn(134, noctX + 32, noctY - 32, player.section)
	a.speedY = rng.randomInt(-15,-7);
	a.speedX = rng.randomInt(-8,8)
	a = NPC.spawn(134, noctX + 32, noctY - 32, player.section)
	a.speedY = rng.randomInt(-15,-7);
	a.speedX = rng.randomInt(-8,8)
	a = NPC.spawn(134, noctX + 32, noctY - 32, player.section)
	a.speedY = rng.randomInt(-15,-7);
	a.speedX = rng.randomInt(-8,8)
	noctelCooldown()
	end
end

function bossAttack3()
	if doCos == true then
	noctel:walk(9)
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK2)
	cinematX.waitSeconds(2)
	noctelCooldown()
	end
end

function bossAttack4()
	if doCos == true then
	a = NPC.spawn(155, noctX + 32, noctY, player.section)
	a.speedY = rng.randomInt(-10);
	playSFX(22)
	noctel:walkToX(player.x,9)
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK2)
	cinematX.waitSeconds(1)
	noctelCooldown()
	end
end

function bossAttack5()
end

function noctelCooldown()
	if doCos == true then
	noctel:walkToX(player.x,9)
	noctel:setAnimState (cinematX.ANIMSTATE_ATTACK2)
	cinematX.waitSeconds(1)
	noctel:setAnimState (cinematX.ANIMSTATE_IDLE)
	cinematX.waitSeconds(1.5)
	radicola = rng.randomInt(1,4)
	if radicola == 1 then
		bossAttack1()
	elseif radicola == 2 then
		bossAttack2()
	elseif radicola == 3 then
		bossAttack3()
	elseif radicola == 4 then
		bossAttack4()
	elseif radicola == 5 then
		bossAttack5()
	end
	end
end

function noctelBananaSpray()
	if doCos == true then
	playSFX(25)
	a = NPC.spawn(30, noctX - 32, noctY, player.section)
	a.speedY = -10;
	a.speedX = rng.randomInt(-5,5);
	a = NPC.spawn(30, noctX - 32, noctY, player.section)
	a.speedY = -10;
	a.speedX = rng.randomInt(-5,5);
	end
end

function bossTakeDamage ()
		cinematX.bossHP = cinematX.bossHP - 1
		playSFX(39)
		--noctel:setAnimState (cinematX.ANIMSTATE_HURT)
		--noctel:setSpeedY(0)
		--noctel:setSpeedX(0)
		bossVulnerable = false;
		eventu.setTimer(2,regainHit)

		-- Speed up the music toward the end
		--if (cinematX.bossHP == 2) then
		--	playMusic (19)
		--end
		
		--collisionActor.smbxObjRef:mem (0xE2, FIELD_WORD, NPCID_COLLISIONA)

		
		-- If the boss is out of health, begin the win sequence and lead into the post-battle cutscene
		if (cinematX.bossHP <= 0) then
			bossVulnerable = false
			bossCollisionOn = false
			
			MusicStopFadeOut (1000)
			playSFX(70)
			doCos = false;
			cinematX.runCutscene(deathCutscene)
		end
end

function regainHit()
	bossVulnerable = true;
end

function deathCutscene()
	for _,v in pairs(NPC.get(155,player.section)) do
		v:kill()
	end
	for _,v in pairs(NPC.get(134,player.section)) do
		v:kill()
	end
	for _,v in pairs(NPC.get(120,player.section)) do
		v:kill()
	end
	for _,v in pairs(NPC.get(30,player.section)) do
		v:kill()
	end
	noctel:setSpeedX(0)
	noctel:setSpeedY(0)
	cinematX.waitSeconds(2)
	cinematX.startDialog(noctel,"Noctel","Noooo...this can;t be hsaappppp%@%$#%$$%#%$#%#$%@##%",30,30,"")
	cinematX.waitForDialog ()
	cinematX.startDialog(noctel,"Noctel?","ABORT! ABORT! ABORT! ABORT!",30,30,"")
	cinematX.waitForDialog ()
	Animation.spawn(108, noctel:getX(), noctel:getY())
	noctel:setX(800)
	triggerEvent("doorAppear")
	cinematX.endCutscene ()
end

--GOOPINATI LOG: We've been doing some experiments on the Goopas lately. So far we've created a Goopa that ignores the laws of gravity. Further tests will be conducted.
--GOOPINATI LOG: Another experimental success. We've made a sort of vertical wrapping field. How this physically even works, we still don't know. For reference, members - the fields are where the arrows are.
--GOOPINATI LOG: We've successfully made a Goopa shell that splits into more Goopas when it hits the ground. Our armies are destined to be ENDLESS!
--GOOPINATI LOG: Finally, a way to keep intruders out. We've invented a special dotted barrier that only us Goopas can get through. Unfortunately, they're hilariously expensive. Still. MWAHAHAHA.