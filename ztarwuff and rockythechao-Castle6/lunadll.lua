local multipoints = loadAPI("multipoints");
local rng = API.load("rng")
local fb = Graphics.CaptureBuffer(800, 600)


local colliders = loadSharedAPI("colliders");
local cinematX = loadSharedAPI("cinematX")
local emote = loadSharedAPI("emote")
local NPCID = loadSharedAPI("npcid")

cinematX.config (true, false, true, true, true, true)


--***************************************************************************************
--                                                                                      *
-- BOSS CONSTANTS AND ENUMS																*
--                                                                                      *
--***************************************************************************************
do

	-- NPC ID enums
	NPCID_BROADSWORD = NPCID.LUIGI
	NPCID_DONUTGEN = NPCID.RINKAGEN
	NPCID_SHOCKWAVEGEN = NPCID.SPARK

	
	shockwaveGenLActor = nil
	shockwaveGenRActor = nil		
	broadswordActor = nil
	collisionActor = nil

	shockwavesOff = true
	
	
	bossDifficulty = 1;
	bossDefVulnTime = 240;
	bossCurrentVulnTime = bossDefVulnTime;
	bossNumPogos = -1;
	
	fxAnim = 0
	
	
	-- Phase IDs
	bossPhase_Dodge = 0
	bossPhase_DashAttack = 1
	bossPhase_Pogo = 3
	bossPhase_ShockStab = 4
	bossPhase_Vuln = 20
	bossPhase_Die = 30
	bossPhase_WindSlash = 40
	
	
	-- References
	bossCurrentCoroutine = nil
	
	bossSectionBounds = Section(1).boundary
	bossRoomCenterX = 0.5 * (bossSectionBounds.left + bossSectionBounds.right)
			
	bossClosestWallX = 0
	bossFacingWallX = 0
			
	bossDirToPlayerX = 0
	bossDirToCenterX = 0
			
	bossDistToPlayerX = 0
	bossDistToWallClosest = 0
	bossDistToWallFacing = 0
	
	
	
	-- Collision stuff
	bossCollider = colliders.Box(-99, -99, 32, 36);
	--bossCollider:Debug(true);
	playerBouncedOnBoss = false
	playerSpinjumped = false
	playerCollidedWithBoss = false
	bossVulnerable = false
	bossCollisionOn = true
	
	
	-- Sound IDs
	SOUNDID_DRAWSWORD = "sword1.wav"
	SOUNDID_SLICE = "sword2.wav"

	
	-- Image IDs
	IMGREF_JUMPSIGN = Graphics.loadImage ("jumpSign.png")
	
	
	local i = cinematX.ANIMSTATE_TOPPRESET + 1
	ANIMSTATE_POSE	 		=  i;  i = i+1;
	ANIMSTATE_CLOSED 		=  i;  i = i+1;
	ANIMSTATE_CLOSEDTALK	=  i;  i = i+1;
	ANIMSTATE_HAPPY			=  i;  i = i+1;
	ANIMSTATE_HAPPYTALK		=  i;  i = i+1;
	ANIMSTATE_SWORDJUMP		=  i;  i = i+1;
	ANIMSTATE_DIAGSTAB		=  i;  i = i+1;
	ANIMSTATE_DIAGSTAB2		=  i;  i = i+1;
	
	
	
	-- Individual NPC animation settings
	animData_Broadsword = {}
	animData_Broadsword[cinematX.ANIMSTATE_NUMFRAMES] = 52
	animData_Broadsword[cinematX.ANIMSTATE_IDLE] = "0-0"
	animData_Broadsword[cinematX.ANIMSTATE_TALK] = "1-2"
	animData_Broadsword[cinematX.ANIMSTATE_WALK] = "4-5"
	animData_Broadsword[cinematX.ANIMSTATE_RUN] = "4-5"
	animData_Broadsword[cinematX.ANIMSTATE_JUMP] = "7-7"
	animData_Broadsword[cinematX.ANIMSTATE_FALL] = "9-9"
	animData_Broadsword[cinematX.ANIMSTATE_HURT] = "42-42"
	animData_Broadsword[cinematX.ANIMSTATE_STUN] = "21-21"
	animData_Broadsword[cinematX.ANIMSTATE_DEFEAT] = "44-44"
	animData_Broadsword[cinematX.ANIMSTATE_ATTACK1] = "11-11"
	animData_Broadsword[cinematX.ANIMSTATE_ATTACK2] = "13-15"
	animData_Broadsword[cinematX.ANIMSTATE_ATTACK3] = "17-17"
	animData_Broadsword[cinematX.ANIMSTATE_ATTACK4] = "19-19"
	animData_Broadsword[cinematX.ANIMSTATE_ATTACK5] = "23-23"
	animData_Broadsword[cinematX.ANIMSTATE_ATTACK6] = "25-25"
	animData_Broadsword[cinematX.ANIMSTATE_ATTACK7] = "27-30"
	animData_Broadsword[ANIMSTATE_POSE] = "32-32"
	animData_Broadsword[ANIMSTATE_CLOSED] = "34-34"
	animData_Broadsword[ANIMSTATE_CLOSEDTALK] = "35-36"
	animData_Broadsword[ANIMSTATE_HAPPY] = "38-38"
	animData_Broadsword[ANIMSTATE_HAPPYTALK] = "39-40"
	animData_Broadsword[ANIMSTATE_SWORDJUMP] = "46-46"
	animData_Broadsword[ANIMSTATE_DIAGSTAB] = "48-48"
	animData_Broadsword[ANIMSTATE_DIAGSTAB2] = "51-51"
end


local shiftAmount = 0


--Before KillRoom
multipoints.addLuaCheckpoint(-175460, -180480, 1);
--After KillRoom
multipoints.addLuaCheckpoint(-174432, -180095, 1);
--BeforeBoss
multipoints.addLuaCheckpoint(-139890, -140227, 3);

-- Screen boundaries
top = {-200608, -180608, -160608, -140608}; bottom = {-200000, -180000, -160000, -140000};
-- Vertical speed/position of player on previous frame
prevDY = 0
prevY = 0
-- Acceleration due to gravity
accel = 0.40000000596046
-- Minimum speed to bounce player
PLAYER_BOUNCE_SPEED = -8
-- Set maximum fall speed
Defines.gravity = 20


function onLoad()
--Filter out Hammer
	if (player.isValid) then
		if (player.powerup == PLAYER_HAMMER) then
        player.powerup = PLAYER_BIG;
		end
	end
end



function onLoadSection4()
	cinematX.runCutscene (cutscene_bossPrep)
end



--***************************************************************************************
-- 																						*
-- BOSS LOOP FUNCTIONS																	*
-- 																						*
--***************************************************************************************
local startBossScene = false
	
do
	function bossOnLoop ()
		--runAnimation (0, 300,300, 0)
		--runAnimation (0, 300,300, 1)
		--runAnimation (0, 300,300, 1065353216)
		
		-- Get references
		shockwaveNPCL = findnpcs(NPCID.SPARK, -1)[0]
		shockwaveNPCR = findnpcs(NPCID.SPARK, -1)[1]
		shockwaveGenLActor = cinematX.getActorFromKey ("shockleft")
		shockwaveGenRActor = cinematX.getActorFromKey ("shockright")
		broadswordActor = cinematX.getActorFromKey ("broadsword")
		collisionActor = cinematX.getActorFromKey ("broadsword_hitbox")
	
		
		-- Process Broadsword's behavior
		if (broadswordActor ~= nil) then
			broadswordActor:overrideAnimation (animData_Broadsword)
			broadswordActor.shouldDespawn = false
			
			
			-- Determine where the boss is relative to the player
			bossSectionBounds = Section(player.section).boundary
			bossRoomCenterX = 0.5 * (bossSectionBounds.left + bossSectionBounds.right)
			
			bossClosestWallX = getNPCWallClosest (broadswordActor)
			bossFacingWallX = getNPCWallFacing (broadswordActor)
			
			bossDirToPlayerX = broadswordActor:dirToActorX (cinematX.playerActor)
			bossDirToCenterX = broadswordActor:dirToX (bossRoomCenterX)
			
			bossDistToPlayerX = broadswordActor:distanceActorX (cinematX.playerActor)
			bossDistToWallClosest = broadswordActor:distanceX (bossClosestWallX)
			bossDistToWallFacing = broadswordActor:distanceX (bossFacingWallX)
			
			
			-- Control the boss' particle effects
			fxAnim = (fxAnim + 1)%128
			
			--[[
			for  k,v  in pairs (Animation.get())  do
				if v.id == 71  then
					v.x = broadswordActor:getCenterX ()
					v.y = broadswordActor:getCenterY ()
				end
			end
			]]
					  
			
			-- CLAMP BROADSWORD TO THE SECTION BOUNDS DURING THE FIGHT
			if  cinematX.currentSceneState == cinematX.SCENESTATE_BATTLE  then
				if  (broadswordActor:getX () > bossSectionBounds.right-32) then
					broadswordActor:setX (bossSectionBounds.right-32)
				end
				if  (broadswordActor:getX () < bossSectionBounds.left) then
					broadswordActor:setX (bossSectionBounds.left)
				end
			end
			
			
			-- Control collision
			bossCollider = colliders.getSpeedHitbox(broadswordActor.smbxObjRef) --colliders.Box(broadswordActor:getX(), broadswordActor:getY(), 32, 48);
			
			playerBouncedOnBoss,playerSpinjumped = colliders.bounce(player, bossCollider);
			playerCollidedWithBoss = colliders.speedCollide (player,bossCollider)
			
			if  bossCollisionOn == true  then
			
				if cinematX.showDebugInfo == true then
					if  battlePhase == bossPhase_Vuln  then
						bossCollider:Draw (0x00FF2299)
					else
						bossCollider:Draw ()
					end
				end
				
				if playerCollidedWithBoss == true then
					if playerBouncedOnBoss == true then
						colliders.bounceResponse (player)
						player.speedX = player.speedX + (math.max(1.5, math.abs (bossDistToPlayerX*0.2)) * bossDirToPlayerX)
						bossTakeDamage ()
					elseif  battlePhase ~= bossPhase_Vuln  then
						player:harm ()
					end
				end
			end

		end
		
	end
	
	
	function br_onLoop ()		
		bossOnLoop ()
		broadswordAllyActor = cinematX.getActorFromKey ("broadswordAlly")
		
		if (broadswordAllyActor ~= nil) then
			broadswordAllyActor:overrideAnimation (animData_Broadsword)
			broadswordAllyActor.shouldDespawn = false
		end
		
		
		if  irisActor ~= nil  then
			irisActor:update ()
		end
		
		if  koodActor ~= nil  then
			koodActor:update ()
		end
		
		if  raocowActor ~= nil  then
			raocowActor:update ()
		end
		
		if  sheathActor ~= nil  then
			sheathActor:update ()
		end
		
		--player:setCurrentSpriteIndex(0, 0, true)
	end



	function onLoopSection0 ()

	end

end






function onLoop()
	br_onLoop ()
	

	--Filter out Hammer in level
	if (player.isValid) then
		if (player.powerup == PLAYER_HAMMER) then
        player.powerup = PLAYER_BIG;
		end
	end
	
	-- arabsalmon's Bog Standard code
	if top[player.section+1] and bottom[player.section+1] then
		if player.y > bottom[player.section+1] then player.y = top[player.section+1] - player.height
		elseif player.y < (top[player.section+1]-player.height) then player.y = bottom[player.section+1] end
	end
	
	donutLogic()
	bounceLogic()
end


-- arabsalmon's Donut block logic
function donutLogic()
	for _,donut in pairs(NPC.get({212,46}, player.section)) do
		if donut.speedY ~= 0 then donut.speedY = donut.speedY - accel*1.2 end
		if donut.speedY < -Defines.gravity then donut.speedY = -Defines.gravity end
	end
end


-- arabsalmon's bouncy spikes logic
function bounceLogic()
	-- Detect if contacting bouncy spike underneath player
	for _,b in pairs(Block.getIntersecting(player.x, player.y+player.height, player.x+player.width, player.y+player.height+1)) do
		if not b.layerObj.isHidden then
			if b.id == 45 then
				-- Reflect player downward momentum
				player.y = prevY
				player.speedY = -prevDY - accel
				if player.speedY > PLAYER_BOUNCE_SPEED then player.speedY = PLAYER_BOUNCE_SPEED end
				playSFX(24)
			end
		end
	end
	prevY = player.y
	prevDY = player.speedY
end


function onEvent(SwitchLayer)
	
	if SwitchLayer == "CastleBGM" then
		shiftAmount = 1
		playMusic(1)

	elseif SwitchLayer == "MeranoBogEv" then
		shiftAmount = 1
		playMusic(17)
	
	elseif SwitchLayer =="Kill1" then
		if (player.isValid) then
			if (player.powerup == PLAYER_SMALL) then
			player.powerup = PLAYER_BIG;
			end
		end
	
	elseif SwitchLayer == "UpDownRaoEv" then
		shiftAmount = 1
		playMusic(3)
   
	elseif SwitchLayer == "MonoPrinceEV" then
		shiftAmount = 1
		playMusic(19)
	
	elseif SwitchLayer == "ANMT" then
		shiftAmount = 1
		playMusic(20)
	end
end


-- Visual effects when shifting
function onCameraUpdate()
	shiftAmount = shiftAmount - 0.025
	
	if  shiftAmount > 0  then
		shiftEffect (shiftAmount)
	end
	
	--bossBgEffect ()
end


-- Dimension shift effect
function shiftEffect (amount)
	fb:captureAt(0.5)
    local rowHeight = 8
    local colWidth = 64
    for y1=0,600,rowHeight do
        for x1=0,800,colWidth do
            local x2 = x1 + colWidth
            local y2 = y1 + rowHeight
            
            local xOff = rng.random(-20, 20) * amount
            local yOff = rng.random(0, 0)
            local vertCoords = {x1+xOff, y1+yOff, x1+xOff, y2+yOff, x2+xOff, y1+yOff, x2+xOff, y2+yOff}
            local texCoords = {x1/800, y1/600, x1/800, y2/600, x2/800, y1/600, x2/800, y2/600}
            Graphics.glDraw{vertexCoords=vertCoords, texture=fb, textureCoords=texCoords,
                primitive=Graphics.GL_TRIANGLE_STRIP, priority=0.6, color={1.0, 1.0, 1.0, 0.5}}
        end
    end
end


function bossBgEffect ()
	fb:captureAt(-99)
    local rowHeight = 64
    local colWidth = 64
    for y1=0,600,rowHeight do
        for x1=0,800,colWidth do
            local x2 = x1 + colWidth
            local y2 = y1 + rowHeight
            
            local xOff = math.sin(2*os.clock()+(x1/rowHeight)-0.5*(y1/colWidth))*8
            local yOff = 0--math.cos(2*os.clock()+(y1/colWidth))*8
            local vertCoords = {x1+xOff, y1+yOff, x1+xOff, y2+yOff, x2+xOff, y1+yOff, x2+xOff, y2+yOff}
            local texCoords = {x1/800, y1/600, x1/800, y2/600, x2/800, y1/600, x2/800, y2/600}
            Graphics.glDraw{vertexCoords=vertCoords, texture=fb, textureCoords=texCoords,
                primitive=Graphics.GL_TRIANGLE_STRIP, priority=-98, color={1.0, 1.0, 1.0, 1.0}}
        end
    end
end



--***************************************************************************************
-- 																						*
-- OTHER IMPORTANT FUNCTIONS															*
-- 																						*
--***************************************************************************************
do
	function getNPCWallClosest (myActor)
		local currentSection = Section (1)
		local leftX = currentSection.boundary.left
		local rightX = currentSection.boundary.right
		
		local centerX = 0.5*(leftX + rightX)

		if myActor:getX () < centerX then
			wallX = leftX
		else
			wallX = rightX
		end

		return wallX
	end

	
	function getNPCWallFacing (myActor)
		local currentSection = Section (1)
		local leftX = currentSection.boundary.left
		local rightX = currentSection.boundary.right
		
		if myActor:getDirection () == DIR_LEFT then
			wallX = leftX
		else
			wallX = rightX
		end

		return wallX
	end
end




	
	
--***************************************************************************************
-- 																						*
-- BOSS BATTLE CONTROL FUNCTIONS														*
-- 																						*
--***************************************************************************************
do	
	function bossChangePhase (phase)
		battlePhase = phase		
		battleFrame = 0
	end


	function bossChangePhase_Dodge (numDodges)
		bossChangePhase (bossPhase_Dodge)
		battleFrame = numDodges
	end
	
	function bossChangePhase_Pogo (numBounces)
		bossChangePhase (bossPhase_Pogo)
		battleFrame = numBounces
		bossNumPogos = numBounces
	end
	
	function bossChangePhase_Vuln ()
		bossChangePhase (bossPhase_Vuln)	
		battleFrame = bossCurrentVulnTime
	end

	function bossChangePhase_ShockStab ()
		bossChangePhase (bossPhase_ShockStab)
		fxAnim = 15	
	end

	
	
	
	function bossTakeDamage ()
		cinematX.bossHP = cinematX.bossHP - 1

		if battlePhase == bossPhase_Vuln  then
			battleFrame = battleFrame - 30
		end


		-- Speed up the music toward the end
		--if (cinematX.bossHP == 2) then
		--	playMusic (19)
		--end
		
		--collisionActor.smbxObjRef:mem (0xE2, FIELD_WORD, NPCID_COLLISIONA)

		
		-- If the boss is out of health, begin the win sequence and lead into the post-battle cutscene
		if (cinematX.bossHP <= 0  and  battlePhase ~= bossPhase_Die) then
			bossVulnerable = false
			bossCollisionOn = false
			
			cinematX.abortCoroutine (bossCurrentCoroutine)
			bossCurrentCoroutine = nil
			--bossChangePhase (bossPhase_Die)
			
			cinematX.runCoroutine (coroutine_afterBattle)
		else
		
			local hurtSounds = {"voice_hurt1.wav", "voice_hurt2.wav", "voice_grunt1.wav", "voice_grunt2.wav", "voice_grunt3.wav"}
		
			if  math.random (100) > 50  then
				cinematX.playSFXSDLSingle (hurtSounds[math.random(#hurtSounds)])
			end
		end
	end
end

	
	
--***************************************************************************************
-- 																						*
-- BOSS ACTIONS																			*
-- 																						*
--***************************************************************************************

do
	function bossSpawnShockwaves ()
		cinematX.playSFXSingle (22)

		local y1 = Section(player.section).boundary.bottom-200
		
		local lShockwave = NPC.spawn (NPCID_SHOCKWAVEGEN, broadswordActor:getX()-32, y1, player.section)
		local rShockwave = NPC.spawn (NPCID_SHOCKWAVEGEN, broadswordActor:getX()+32, y1, player.section)						

		lShockwave.direction = DIR_LEFT
		rShockwave.direction = DIR_RIGHT		
	end
	
	
	function bossSpawnBigWind (yOffset)
		cinematX.playSFXSingle (22)
		
		local newX = broadswordActor:getCenterX()
		local newY = broadswordActor:getCenterY() + yOffset
		
		local windwave = NPC.spawn (NPCID.BULLET_SMW, newX, newY, player.section)

		if  player.x > newX  then
			windwave.direction = DIR_RIGHT
		else
			windwave.direction = DIR_LEFT
		end
	end
	
	
	
	function bossSpawnFX (fxID, interval, xOffset, yOffset)
		if (fxAnim % interval == 0) then
			Animation.spawn (fxID, broadswordActor:getX() + xOffset, broadswordActor:getY() + yOffset)
		end
	end
	
	
	function bossBackstepPlayer ()
	
		-- Jump away from the player
		bossCollisionOn = false
		broadswordActor:jump (math.random(4,6))
		broadswordActor:lookAtPlayer ()
		
		local backstepDistance = -6
		if  cinematX.getBattleProgressPercent() >= 0.5  then
			backstepDistance = math.random (-10, -6)
		end
		
		broadswordActor:walkForward (-6)
		
		-- Random chance of creating shockwaves on higher difficulty
		if (bossDifficulty >= 2   and   math.random(0,1) == 1) then
			bossSpawnShockwaves ()
		end
		
		broadswordActor.onGround = false
	end
	
	
	function bossBackstepCenter ()
		bossCollisionOn = false
		broadswordActor:jump (4)
		broadswordActor:walk (bossDirToCenterX * -4)
		broadswordActor.onGround = false
	end
	
	
	function bossFlipInward ()
		bossCollisionOn = false
		broadswordActor:walk (bossDirToCenterX * 6)						
		broadswordActor:jump (10)
		broadswordActor:walk (bossDirToCenterX * 6)						
		broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK7)
		cinematX.playSFXSDLSingle ("sword2.wav")
		broadswordActor.onGround = false
	end

	
	function bossRunToPlayer ()
		broadswordActor:lookAtPlayer ()
		broadswordActor:walkForward (5)	
	end
	
	
	function bossOnGround ()
		if   broadswordActor:getY() >= Section(player.section).boundary.bottom-225  
		and  broadswordActor:getSpeedY () == 0  
		and  broadswordActor.onGround == true  then
			return true;
		end
		
		return false;
	end
end	




--***************************************************************************************
-- 																						*
-- CUTSCENES																			*
-- 																						*
--***************************************************************************************
do 
	-- Setup
	local broadswordProps = {boxType=cinematX.BOXTYPE_SUBTITLE, 
							 actor=broadswordActor,
							 name="Uncle Broadsword"}
	
	--[[
	local broadswordProps = {boxType=cinematX.BOXTYPE_TEXTBLOX, 
							 actor=broadswordActor, 
							 x=500,
							 y=300,
							 name="Uncle Broadsword", 
							 bloxProps={autoTime=true,
										textAnchorX=1,
										textAnchorY=1,
										boxAnchorX=2,
										boxAnchorY=2,
										width=320,
										height=80}
							}
	]]
	
	local broadswordPropsNoAnim = {boxType=cinematX.BOXTYPE_SUBTITLE, 
								   actor=nil,
								   name="Uncle Broadsword"}
	
	local demoProps = {boxType=cinematX.BOXTYPE_SUBTITLE, 
					   actor=nil,
					   name="Demo"}
	
	local irisProps = {boxType=cinematX.BOXTYPE_SUBTITLE, 
					   actor=nil,
					   name="Iris"}
	
	local koodProps = {boxType=cinematX.BOXTYPE_SUBTITLE, 
					   actor=nil,
					   name="Kood"}
	
	local raocowProps = {boxType=cinematX.BOXTYPE_SUBTITLE, 
					   actor=nil,
					   name="Raocow"}

	local sheathProps = {boxType=cinematX.BOXTYPE_SUBTITLE, 
					   actor=nil,
					   name="Sheath"}


	function cutscene_levelIntro ()
		
		cinematX.setSkipScene (cutscene_levelIntroCleanup)
		
		
		if player.powerup == PLAYER_SMALL  then
			player.powerup = PLAYER_BIG
		end
		
		local newActors = cinematX.spawnPlayerActors (5, 
													{CHARACTER_LUIGI, 	CHARACTER_PEACH,	CHARACTER_TOAD, 	CHARACTER_LINK},
													{PLAYER_BIG, 		PLAYER_BIG,			PLAYER_BIG,		PLAYER_BIG})

		irisActor = newActors[1]
		koodActor = newActors[2]
		raocowActor = newActors[3]
		sheathActor = newActors[4]
		
		
		koodActor:setExtraSprites ("koodExpressions.png", 10, true)
		
		-- Cutscene
		
		-- They all approach broadsword
		cinematX.fadeScreenIn (4)
		cinematX.playerActor:walkToX (-159700, 2, 0.1)
		
		irisActor:walkToX (-159700 - 48, 2, 0.1)
		koodActor:walkToX (-159700 - 96, 2, 0.1)
		raocowActor:walkToX (-159700 - 160, 2, 0.1)
		sheathActor:walkToX (-159700 - 240, 2, 0.1)
		
		cinematX.waitSeconds(2.5)
			
		broadswordAllyActor:setDirection (DIR_LEFT)
		cinematX.waitSeconds(0.5)
		
		
		
		-- Broadsword starts talking
		broadswordAllyActor:setTalkAnimStates (ANIMSTATE_HAPPY, ANIMSTATE_HAPPY, ANIMSTATE_HAPPYTALK) 
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "Ho-ho!  I had a hunch I'd be seeing you all again soon!", 30, 30, "voice_talk1.wav")
		cinematX.waitForDialog ()
		
		broadswordAllyActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		cinematX.yield()
		
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "It's a smashing spot of luck you showed up,<pause 10> actually.")
		cinematX.waitForDialog ()
		
		cinematX.waitSeconds(0.5)
		
		
		--irisActor.isHidden = true
		--koodActor.actorCollisionOn = false
		--koodActor.smbxObjRef:kill ()
		--irisActor:walkToX (irisActor:getX() - 128, 2, 0.1, 8)
		--koodActor:setX(irisActor:getX())--walkToX (koodActor:getX() + 128, 3, 0.1, 8)
		
		broadswordAllyActor:setDirection (DIR_RIGHT)
		cinematX.waitSeconds(0.5)
		
		--koodActor.actorCollisionOn = true

		
		-- Broadsword poses
		broadswordAllyActor.smbxObjRef.x = broadswordAllyActor.smbxObjRef.x + 18
		
		cinematX.playSFXSDLSingle ("sword1.wav")
		broadswordAllyActor:setAnimState (ANIMSTATE_POSE)
		cinematX.waitSeconds(1.5)
		
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "That treasure I mentioned before.<speed 0.05>.. <speed 0.5>It's hidden deep within this temple!<pause 30>  I can <shake box>feel it in my whiskers,<pause 10> by jove!", 30, 30, "voice_talk2.wav")  
		cinematX.waitForDialog ()
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "It won't be long now before my brothers and I will finally be able to.<speed 0.05>..")  
		cinematX.waitForDialog ()
		
		
		-- Kood and Iris are concerned
		cinematX.runCoroutine (cor_koodIrisLook)

		cinematX.waitSeconds(1)
	
		broadswordAllyActor.smbxObjRef.x = broadswordAllyActor.smbxObjRef.x - 18
		broadswordAllyActor:setAnimState (cinematX.ANIMSTATE_IDLE)
		cinematX.waitSeconds(0.5)

		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "...")  
		cinematX.waitForDialog ()
		cinematX.waitSeconds(0.5)
		

		-- Broadsword regains his composure
		broadswordAllyActor:setDirection (DIR_LEFT)
		
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "*Ahem* Well, I'm getting ahead of myself.")  
		cinematX.waitForDialog ()
		
		broadswordAllyActor:setTalkAnimStates (ANIMSTATE_CLOSED, ANIMSTATE_CLOSED, ANIMSTATE_CLOSEDTALK) 
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "As you can see, there's two paths and only one of yours truly!  Quite the dilemma, eh wot?")  
		cinematX.waitForDialog ()

		broadswordAllyActor:setTalkAnimStates (ANIMSTATE_HAPPY, ANIMSTATE_HAPPY, ANIMSTATE_HAPPYTALK) 
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "But now we can scour this place together!  Divide and conquer, as they say!", 30, 30, "voice_talk3.wav") 
		cinematX.waitForDialog ()
		
		
		-- Broadsword walks to the door
		broadswordAllyActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		broadswordAllyActor:walkToX (-159300+16, 3, 0.1, 8)
		
		cinematX.waitSeconds(2)
		broadswordAllyActor:setDirection (DIR_LEFT)
		
		cinematX.waitSeconds(0.5)		
		
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "I'll take this hall, and all of you can take the other!", 30, 30, "voice_talk3.wav") 
		cinematX.waitForDialog ()
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "Don't worry, you'll know the artifact when you see it!  It'll be very... out of place.")  
		cinematX.waitForDialog ()
		cinematX.startDialog  (broadswordAllyActor, "Uncle Broadsword", "Well, let's not waste any more time, then!  Tally-ho!")  
		cinematX.waitForDialog ()
		
		cinematX.waitSeconds(0.25)		
		
		
		-- Broadsword enters the door
		broadswordAllyActor.smbxObjRef.y = broadswordAllyActor.smbxObjRef.y + 1200
		cinematX.waitSeconds(1.0)	
		
		cinematX.playerActor:setDirection (DIR_LEFT)
		
		cinematX.startDialog  (cinematX.playerActor, "Demo", "Well, gang, you heard him.  Let's get going already!") 
		cinematX.waitForDialog ()
		
		cinematX.playerActor:walkToX (-159470, 3, 0.1, 8)
		cinematX.waitSeconds(0.75)	
		
		cinematX.playerActor:walk (0)
		cinematX.startDialog  (koodActor, "Kood", "Hey, Demo, wait a second!  Are you sure we can trust this guy?")
		cinematX.waitForDialog ()
		
		cinematX.waitSeconds(0.25)	
		cinematX.playerActor:setDirection (DIR_LEFT)

		cinematX.startDialog  (cinematX.playerActor, "Demo", "What?  Oh, no worries, Uncle B.'s cool.  I used to go on all sorts of awesome adventures with him!") 
		cinematX.waitForDialog ()
		
		irisActor:walkToX (irisActor:getX()+48, 3, 0.1, 8)
		
		cinematX.startDialog  (irisActor, "Iris", "Sorry, sis, but for once I'm going to have to agree with the turtle.  Something's definitely not right here.")
		cinematX.waitForDialog ()
		cinematX.startDialog  (irisActor, "Iris", "That whole 'we'll finally be able to dot dot dot' thing, that was incredibly suspicious.  He's hiding something.")
		cinematX.waitForDialog ()
		cinematX.startDialog  (cinematX.playerActor, "Demo", "But you think everyone has something to hide.  C'mon, Iris, you're just being paranoid!") 
		cinematX.waitForDialog ()
		
		irisActor:setDirection (DIR_LEFT)
		koodActor:setDirection (DIR_LEFT)
		cinematX.startDialog  (raocowActor, "Raocow", "Yeah, I mean, the guy seemed pretty neat-o...")
		cinematX.waitForDialog ()
		raocowActor:setDirection (DIR_LEFT)
		sheathActor:jump(5)
		cinematX.startDialog  (sheathActor, "Sheath", "And he's got a shiny sword!  And a cool moustache!  And a hat!  You think I could grow a 'stache like that?")
		cinematX.waitForDialog ()
		
		cinematX.startDialog  (cinematX.playerActor, "Demo", "See?  It's just you two.") 
		cinematX.waitForDialog ()
		
		raocowActor:setDirection (DIR_RIGHT)
		irisActor:setDirection (DIR_RIGHT)
		koodActor:setDirection (DIR_RIGHT)
		
		cinematX.startDialog  (cinematX.playerActor, "Demo", "Look, you guys can stay here if you want to, but I'm going on ahead.")
		cinematX.waitForDialog ()
		cinematX.playerActor:walkToX (-159470+16, 3, 0.1, 8)

		cinematX.waitSeconds (0.5)
		cinematX.playerHidden = true
		cinematX.waitSeconds (1)
		
		cinematX.startDialog  (irisActor, "Iris", "*sigh*... Fine, whatever.  Be that way, sis, see if I care.")
		cinematX.waitForDialog ()
	
		irisActor:walkToX (-159470+16, 4, 0.1, 8)
		cinematX.waitSeconds (1)

		cinematX.runCutscene (cutscene_levelIntroCleanup)
	end

	
	function cutscene_levelIntroCleanup ()
		cinematX.fadeScreenOut (1)
		cinematX.waitSeconds (1)
		
		cinematX.endCutscene ()
		
		mem (0x00B2595E, FIELD_WORD, 1)
		player:mem (0x15A, FIELD_WORD, player.section + 1)

		player.x = -139776
		player.y = -140192
		cinematX.playerHidden = false
		
		cinematX.waitSeconds (0.5)
		cinematX.fadeScreenIn (0.5)
	end

	
	
	function cor_koodIrisLook ()
		koodActor:walk (0)
		irisActor:setDirection (DIR_LEFT)
		cinematX.waitSeconds (0.5)
		
		koodActor.isHidden = true
		--koodActor.smbxObjRef.y = koodActor.smbxObjRef.y - 32
		koodActor.extraSpriteAnim = {2,3}
		irisActor:setDirection (DIR_RIGHT)
		cinematX.waitSeconds (0.2)
		irisActor:setDirection (DIR_LEFT)
		cinematX.waitSeconds (0.6)
		
		koodActor.isHidden = false
		koodActor.extraSpriteAnim = {}
		koodActor:setDirection (DIR_LEFT)
		cinematX.waitSeconds (0.2)
		koodActor:setDirection (DIR_RIGHT)
		
		cinematX.waitSeconds (0.6)
		irisActor:setDirection (DIR_RIGHT)
	end
	

	function cutscene_bossIntro ()
		
		
		
		-- Player character walks in, Broadsword is facing away
		cinematX.playerActor:walkToX (-180140, 4, 1, 1)
		triggerEvent ("Scroll to Battle")
		Defines.levelFreeze = false
		cinematX.waitSeconds (1)
	
	
		-- Broadsword turns to face the player
		broadswordActor:setDirection (DIR_LEFT)
		cinematX.waitSeconds (1)
		
		cinematX.playerActor:walk (0)
		
		--cinematX.startDialog  (broadswordActor, "Uncle Broadsword", "Blah blah blah, dialogue happens, you've seen that stuff already.", 30, 30, "voice_talk1.wav")  
		
		
		cinematX.playSFXSDLSingle ("voice_talk1.wav")
		broadswordActor:setTalkAnimStates (ANIMSTATE_HAPPY, ANIMSTATE_HAPPY, ANIMSTATE_HAPPYTALK) 
		cinematX.startDialogExt  ("There you are! Did you find anything?  The treasure, perhaps?", broadswordProps)  
		cinematX.waitForDialog ()
		
		cinematX.startDialogExt  ("Just a bunch of coins, nothing special.  Sorry!  I take it that means you didn't find it either?", demoProps)
		cinematX.waitForDialog ()
		
		broadswordActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		cinematX.waitSeconds (0.25)

		broadswordActor:jump (6)
		cinematX.waitSeconds (0.25)
		triggerEvent("Reveal Leek")
		cinematX.waitSeconds (0.5)
		
		cinematX.playSFXSDLSingle ("voice_talk5.wav")
		broadswordActor:setTalkAnimStates (ANIMSTATE_CLOSED, ANIMSTATE_CLOSED, ANIMSTATE_CLOSEDTALK) 
		cinematX.startDialogExt  ("Alas, I only found this large vegetable.  Far from the item I need.", broadswordProps)  
		cinematX.waitForDialog ()

		cinematX.playerActor:jump (8)
		cinematX.startDialogExt  ("That's what we came here for, though!  You're the greatest, Uncle B!", demoProps)
		cinematX.waitForDialog ()
		
		cinematX.playSFXSDLSingle ("voice_talk2.wav")
		broadswordActor:setTalkAnimStates (ANIMSTATE_HAPPY, ANIMSTATE_HAPPY, ANIMSTATE_HAPPYTALK)
		cinematX.startDialogExt  ("Well, then!  Good to see this adventure wasn't completely in vain!", broadswordProps)  
		cinematX.waitForDialog ()
		broadswordActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		cinematX.startDialogExt  ("And yet...", broadswordProps)  
		cinematX.waitForDialog ()
		
		emote.question (player)
		cinematX.waitSeconds (0.75)
		
		broadswordActor:jump (6)
		cinematX.waitSeconds (0.25)
		triggerEvent("Hide Leek")

		cinematX.waitSeconds (0.2)
		emote.exclaim (player)
		cinematX.playerActor:jump (4)
		cinematX.playerActor:walkForward (2)
		cinematX.waitSeconds (0.2)
		cinematX.playerActor:walk (0)
		cinematX.waitSeconds (0.8)
		
		broadswordActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		cinematX.startDialogExt  ("I'm afraid I can't just give this to you.", broadswordProps)  
		cinematX.waitForDialog ()
		
		emote.question (player)
		cinematX.waitSeconds (0.75)

		--[[
		cinematX.startDialogExt  ("What?  Why not!?", demoProps)
		cinematX.waitForDialog ()
		]]
		
		cinematX.playSFXSDLSingle ("voice_talk5.wav")
		broadswordActor:setTalkAnimStates (ANIMSTATE_HAPPY, ANIMSTATE_HAPPY, ANIMSTATE_HAPPYTALK)
		cinematX.startDialogExt  ("That would be a frightfully anticlimactic end to this adventure, would it not?", broadswordProps)
		cinematX.waitForDialog ()
		
		broadswordActor:setTalkAnimStates (ANIMSTATE_CLOSED, ANIMSTATE_CLOSED, ANIMSTATE_CLOSEDTALK)
		broadswordActor:walk (2)
		cinematX.waitSeconds (1)
		  
		broadswordActor:walk (0)
		cinematX.waitSeconds (0.5)
 
		cinematX.startDialogExt  ("My heart feels unfulfilled... it still yearns for excitement, it demands a satisfying conclusion!", broadswordProps)
		cinematX.waitForDialog ()
		
		broadswordActor:setDirection (DIR_LEFT)
		cinematX.waitSeconds (0.25)

		cinematX.startDialogExt  ("And so, Demo...", broadswordProps)
		cinematX.waitForDialog ()
				
		cinematX.waitSeconds(1)
		broadswordActor.smbxObjRef.x = broadswordActor.smbxObjRef.x - 18
		cinematX.playSFXSDLSingle ("sword1.wav")
		broadswordActor:setAnimState (ANIMSTATE_POSE)
		
		cinematX.playSFXSDLSingle ("voice_talk3.wav")
		cinematX.startDialogExt  ("We must fight!", broadswordPropsNoAnim)
		cinematX.waitForDialog ()
		
		broadswordActor.smbxObjRef.x = broadswordActor.smbxObjRef.x + 18
		broadswordActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
				
		cinematX.startDialogExt  ("If this preposterous produce means that much to you, then come and have a go!  Best moi in a duel and the colossal cabbage is yours!", broadswordProps)
		cinematX.waitForDialog ()
		
		cinematX.waitSeconds (0.25)
		emote.meh (player)
		cinematX.waitSeconds (1.5)
		
		cinematX.startDialogExt  ("...Do we really have to?  It'd be nice to finish a world without some big battle for once.", demoProps)
		cinematX.waitForDialog ()

		cinematX.playSFXSDLSingle ("voice_talk1.wav")
		broadswordActor:setTalkAnimStates (ANIMSTATE_HAPPY, ANIMSTATE_HAPPY, ANIMSTATE_HAPPYTALK)
		cinematX.startDialogExt  ("You'll be waiting here for your sister and friends anyway, might as well do something fun with your time!", broadswordProps)
		cinematX.waitForDialog ()
	
		emote.ellipse (player)
		cinematX.waitSeconds (0.5)
		cinematX.playerActor:setDirection (DIR_LEFT)
		cinematX.waitSeconds (1)

		cinematX.playerActor:setDirection (DIR_RIGHT)
		cinematX.waitSeconds (0.5)

		cinematX.startDialogExt  ("Okay then... I suppose we can fight for just a little bit.", demoProps)
		cinematX.waitForDialog ()
		
		cinematX.startDialogExt  ("Excellent!  I shant take this matter lightly, so don't hold back yourself!", broadswordProps)
		cinematX.waitForDialog ()
		
		broadswordActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		cinematX.waitSeconds (0.5)			
		  
		-- Sword slice animation
		MusicOpen ("a2xt_BroadswordBattle.ogg")
		MusicPlay ()
		
		cinematX.configDialog (false, false, 1)
		cinematX.startDialog  (broadswordActor, "Uncle Broadsword", "EN GARDE!<speed 0.05>           ", 160, 160, "voice_talk5.wav")	
		cinematX.waitSeconds (0.6)
		  
		cinematX.playSFXSDLSingle ("sword1.wav")
		cinematX.playSFXSDLSingle ("sword3.wav")
		broadswordActor:setX (broadswordActor:getX() - 8)
		broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK1)
		cinematX.waitSeconds (1)
		  
		cinematX.playSFXSDLSingle (SOUNDID_SLICE)
		broadswordActor:setX (broadswordActor:getX() - 16)
		broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK2)
		cinematX.waitSeconds (1)
		  
		broadswordActor:setX (broadswordActor:getX() + 32)
		broadswordActor:setAnimState (cinematX.ANIMSTATE_IDLE)
		cinematX.waitSeconds (1)
		
		cinematX.endDialogLine ()


		-- DEBUG PROMPT TO SKIP BATTLE
		cinematX.configDialog (true, true, 1)
		
		local nextScene = cutscene_bossPrep
		cinematX.startDialogExt  ("NOTE: Due to a cinematX bug, Broadsword does not currently end his attack pattern after he is defeated.  Do you want to skip the battle?",
								  {question=true})
		cinematX.waitForDialog ()
		
		if  cinematX.questionPlayerResponse == true  then
			nextScene = cutscene_afterBattle
		end
		
		cinematX.runCutscene (nextScene)
	end
	

	function cutscene_bossPrep ()
		cinematX.fadeScreenOut ()
		cinematX.waitSeconds (2)
		
		-- Begin battle
		cinematX.endCutscene ()
		
		cinematX.fadeScreenIn ()
		cinematX.waitSeconds (1)

		cinematX.beginBattle ("Augustus Leopold Broadsword Esq. III", 25, cinematX.BOSSHPDISPLAY_BAR2, battleStartCoroutine)--battleCoroutine)
		cinematX.changeSceneMode (cinematX.SCENESTATE_BATTLE)
		--collisionANPC:mem (0x46, FIELD_WORD, 0)

		--battleCoroutine ()
		--cinematX.runCoroutine ()
	end
	

	function cutscene_afterBattle ()
		MusicStopFadeOut (1000)
	
		broadswordActor:walkToX (Section(player.section).boundary.right - 300, 4, 1, 1)
		cinematX.playerActor:walkToX (Section(player.section).boundary.left + 150, 4, 1, 1)
 		cinematX.waitSeconds (3)
		
		cinematX.configDialog (true, true, 1)	
		cinematX.playerActor:setDirection (DIR_RIGHT)
		cinematX.playerActor:walk (0)
		broadswordActor:setDirection (DIR_LEFT)
		broadswordActor:walk (0)
		
		cinematX.playSFXSDLSingle ("voice_talk1.wav")
		cinematX.startDialogExt  ("I daresay, that was a most exhilarating scuffle! Bravo!", broadswordProps)
		cinematX.waitForDialog ()
		cinematX.startDialogExt  ("As per our agreement, the titanic tomato is now yours.  Treasure it always!", broadswordProps)
		cinematX.waitForDialog ()
		
		
		-- Broadsword pulls out the leek again
		broadswordActor:jump (6)
		cinematX.waitSeconds (0.3)
		triggerEvent("Reveal Leek")
		
		cinematX.waitSeconds (1.5)

		broadswordActor:setDirection (DIR_RIGHT)
		
		cinematX.playSFXSDLSingle ("voice_talk3.wav")
		broadswordActor:setTalkAnimStates (ANIMSTATE_HAPPY, ANIMSTATE_HAPPY, ANIMSTATE_HAPPYTALK)
		cinematX.startDialogExt  ("And with that, I must be off.  That artifact won't find itself, you know!  Arrivederci!", broadswordProps)
		cinematX.waitForDialog ()
		
		
		-- Broadsword begins walking off again
		broadswordActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		broadswordActor:walkForward (2)
		
		cinematX.waitSeconds (0.5)	
		emote.ellipse (player)
		cinematX.waitSeconds (1.2)
		cinematX.playerActor:walkToX (broadswordActor:getX() - 300, 4, 1, 1)
		
		cinematX.waitSeconds (0.2)
		broadswordActor:walk (0)
		
		cinematX.startDialogExt  ("...wait, Uncle B!  Just what is the artifact?  What do you need it for?", demoProps)
		cinematX.waitForDialog ()

		cinematX.waitSeconds (0.5)
		broadswordActor:setTalkAnimStates (ANIMSTATE_CLOSED, ANIMSTATE_CLOSED, ANIMSTATE_CLOSEDTALK)
		cinematX.waitSeconds (1)
		
		cinematX.startDialogExt  ("Your sister doesn't trust me, does she?", broadswordProps)
		cinematX.waitForDialog ()

		cinematX.startDialogExt  ("Well, no, but-", {name="Demo", autoEnd=true, closeTime=45})
		cinematX.waitForDialog ()

		cinematX.startDialogExt  ("I'm sorry, Demo.  I can assure you my brothers and I are working toward a righteous cause, but even so...", broadswordProps)
		cinematX.waitForDialog ()
		
		broadswordActor:setTalkAnimStates (cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_IDLE, cinematX.ANIMSTATE_TALK) 
		cinematX.startDialogExt  ("I must ask that you two leave this matter be, for your own sake.", broadswordProps)
		cinematX.waitForDialog ()

		
		-- Broadsword resumes leaving
		broadswordActor:walk (2)
		cinematX.waitSeconds (3)

		cinematX.startDialogExt  ("Okay, then.  That was... pointlessly omnious...", demoProps)
		cinematX.waitForDialog ()
		
		cinematX.startDialogExt  ("What was pointlessly omnious?", irisProps)
		cinematX.waitForDialog ()
		
		local newActors = cinematX.spawnPlayerActors (5, 
													{CHARACTER_LUIGI, 	CHARACTER_PEACH,	CHARACTER_TOAD, 	CHARACTER_LINK},
													{PLAYER_BIG, 		PLAYER_BIG,			PLAYER_BIG,		PLAYER_BIG})

		irisActor = newActors[1]
		koodActor = newActors[2]
		raocowActor = newActors[3]
		sheathActor = newActors[4]
		
		irisActor.x = -180480
		koodActor.x = irisActor.x - 48
		raocowActor.x = koodActor.x - 48
		sheathActor.x = raocowActor.x - 48
		
		irisActor:walkToX (-180000 - 48, 2, 0.1)
		koodActor:walkToX (-180000 - 96, 2, 0.1)
		raocowActor:walkToX (-180000 - 160, 2, 0.1)
		sheathActor:walkToX (-180000 - 240, 2, 0.1)
		
		cinematX.waitSeconds (0.5)
		cinematX.playerActor:setDirection (DIR_LEFT)
		
		cinematX.waitSeconds (0.5)
		cinematX.startDialogExt  ("Oh, uh, excellent timing!  I was just saying it was pointlessly ominous that you guys weren't here yet!", demoProps)
		cinematX.waitForDialog ()
		
		emote.annoyed (irisActor.smbxObjRef)
		cinematX.waitSeconds (1)
		
		cinematX.startDialogExt  ("You were just talking to Uncle Broadsword, weren't you.", irisProps)
		cinematX.waitForDialog ()
		
		cinematX.waitSeconds (1)
				
		cinematX.startDialogExt  ("<speed 0.2>Maaaayyybe...", demoProps)
		cinematX.waitForDialog ()
		
		cinematX.startDialogExt  ("And he's planning something, isn't he.", koodProps)
		cinematX.waitForDialog ()
		
		cinematX.startDialogExt  ("<speed 0.05>...</speed>yeah.  He is.", demoProps)
		cinematX.waitForDialog ()
		cinematX.waitSeconds (1)
		
		cinematX.fadeScreenOut (1)
		cinematX.waitSeconds (2)
		
		
		cinematX.startDialogExt  ("Would you like to return to the R.E.T.C.O.N.?",
								  {question=true})
		cinematX.waitForDialog ()
		
		if  cinematX.questionPlayerResponse == true  then
		end

		cinematX.endCutscene ()
		Level.winState(1)				
	end	
	
end



--***************************************************************************************
-- 																						*
-- FIGHT COROUTINES																		*
-- 																						*
--***************************************************************************************

do
	function battleStartCoroutine ()		
		bossChangePhase_Dodge (4)
		bossAttackPattern = 0
		
		bossCurrentCoroutine = cinematX.runCoroutine (cor_bossGroundDodge)
	end
	
	
	function cor_bossGroundDodge ()
		if  battlePhase ~= bossPhase_Die  then
			nextCoroutine = nil
			performShockStab = false
			local bugFix = false
			--numDashes = 1
		
			while (bossOnGround () == false  or  bugFix == false)  do
				bugFix = true
				cinematX.yield ()
			end
		
			while (true)  do
				Text.print ("GROUND DODGE", 4, 100, 400)
				
				bossCollisionOn = true
				
				-- Smooth animation transition
				if broadswordActor:getAnimState () == cinematX.ANIMSTATE_ATTACK7 then
					broadswordActor:setAnimState (cinematX.ANIMSTATE_IDLE)
				end
				
				-- If all dodges have not been performed, keep dodging
				if  battleFrame > 0  then
				
					-- If far enough from the wall...
					if     bossDistToWallClosest > 128  then 
					
						-- If far enough from the player, run to them
						if     bossDistToPlayerX > 160  then
							bossRunToPlayer ()
							
						-- Otherwise, backstep or close attack(counts as a dodge)
						elseif bossDistToPlayerX < 160 then
							
							battleFrame = battleFrame - 1
							nextCoroutine = cor_bossBackstep
							break;
						end
						
					-- If too close to the wall, flip inward (counts as a dodge)
					else
						battleFrame = battleFrame - 1
						nextCoroutine = cor_bossFlipInward ()
						break;
					end
				
				
				-- If all dodges have been performed, go on the offensive
				else			
					nextCoroutine = cor_bossChooseBigAttack ()
					break;
				end
				
				cinematX.yield ()			
			end
			
			bossCurrentCoroutine = cinematX.runCoroutine (nextCoroutine)		
		end
	end
	

	
	function cor_bossFlipInward ()
		local nextCoroutine = cor_bossGroundDodge

		bossCollisionOn = false
		bossFlipInward ()	
		
		if (math.random(0,1) == 1  and  cinematX.getBattleProgressPercent() >= 0.5)  then
			performShockStab = true
		end
		
		
		while (bossOnGround () == false)  do
			Text.print ("FLIP", 4, 100, 400)
			
			broadswordActor:setAnimState(cinematX.ANIMSTATE_ATTACK7)
			
			
			-- Manage collision & shock stab
			if  broadswordActor:getSpeedY () > 0  then
				
				-- Collision
				if  bossCollisionOn == false  then
					bossCollisionOn = true
				end
				
				-- Stab
				if  performShockStab == true  and  broadswordActor:getY() < Section(player.section).boundary.bottom-300  then
					performShockStab = false
					bossCurrentVulnTime = 48
					bossChangePhase_ShockStab ()
					nextCoroutine = cor_bossShockStab
					break;
				end
			end
			
			-- Yield
			cinematX.yield()
		end
		
		bossCurrentCoroutine = cinematX.runCoroutine (nextCoroutine)
	end	
	
	
	function cor_bossBackstep ()
		bossBackstepPlayer ()
		
		while (bossOnGround () == false)  do
			Text.print ("BACKSTEP", 4, 100, 400)

			if  broadswordActor:getSpeedY () > 0  and  bossCollisionOn == false  then
				bossCollisionOn = true
			end
			
			cinematX.yield ()
		end
		
		bossCurrentCoroutine = cinematX.runCoroutine (cor_bossGroundDodge)
	end
	
	

	function cor_bossChooseBigAttack ()
		
		broadswordActor:lookAtPlayer ()
		broadswordActor:walkForward (0)
		cinematX.waitFrames(5)
		
		local nextCoroutine = nil
		
		-- Cancel movement
		broadswordActor:stopFollowing ()
		
		-- Reset vulnerabile time
		bossCurrentVulnTime = bossDefVulnTime
	
		-- Change attack pattern
		bossAttackPattern = bossAttackPattern + 1
		
		-- If next attack is 1, perform pogo
		if (bossAttackPattern % 3 == 1) then

			nextCoroutine = cor_bossWindSlash

		-- If next attack is 2, perform dash
		elseif (bossAttackPattern % 3 == 2) then
			nextCoroutine = cor_bossDash

		-- If next attack is 3, perform wind slash
		else			
			nextCoroutine = cor_bossPogo					
		end
		
		
		-- Next routine
		bossCurrentCoroutine = cinematX.runCoroutine (nextCoroutine)	
	end
	

	function cor_bossDash ()
	
		-- Setup
		numDashes = 1
		if  (cinematX.getBattleProgressPercent() >= 0.5) then
			numDashes = 2
		end
		
		bossChangePhase (bossPhase_DashAttack)
		local prepTime = 60
		
		
		-- Loop
		while (numDashes > 0)  do
			
			-- Unsheath sword and prepare
			cinematX.playSFXSDLSingle ("voice_attack1.wav")
			broadswordActor:walk (0)					
			broadswordActor:setSpeedY (math.max (0, broadswordActor:getSpeedY ()))
			broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK1)
			broadswordActor:lookAtPlayer ()
			
			cinematX.waitFrames (prepTime)
			
			
			-- Start swinging
			cinematX.playSFXSDLSingle (SOUNDID_SLICE)
			
			while (battleFrame < 40)  do
				bossSpawnFX (74, 2, 12, 48)
					
				broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK2)
				broadswordActor:walkForward (8)

				if bossDistToWallFacing < 100 then
					battleFrame = 100
				end
				
				battleFrame = battleFrame + 1
				cinematX.yield ()
			end
			
			numDashes = numDashes - 1
			battleFrame = 0
			
			prepTime = 30
			cinematX.yield ()
		end
			
		
		-- Next routine
		bossChangePhase_Vuln ()
		bossCurrentCoroutine = cinematX.runCoroutine (cor_bossVulnerable)	
	end
	
	
	function cor_bossWindSlash ()
	
		-- Setup
		bossCollisionOn = true
		
		local numSlashes = 4
		if  (cinematX.getBattleProgressPercent() >= 0.5) then
			numSlashes = 6
		end
	
		-- Jump to the edge of the arena
		while (bossDistToWallClosest > 64)  do
			bossBackstepPlayer ()
			cinematX.waitFrames (4)
	
			-- Wait to land 		
			while (broadswordActor.onGround == false)  do
				broadswordActor:walkToX (bossFacingWallX, math.abs(broadswordActor:getSpeedX()), 2, 64)
				cinematX.yield ()
			end
			
			cinematX.yield ()			
		end
		
		cinematX.waitSeconds(0.25)
		
		
		-- Start slashes
		broadswordActor:lookAtPlayer ()
		broadswordActor:walk(0)

		broadswordActor:setAnimState (ANIMSTATE_POSE)
		cinematX.waitSeconds(0.25)

		local spawnTop = false
		
		while (numSlashes > 0)  do
			broadswordActor:setAnimState (ANIMSTATE_POSE)
			cinematX.waitSeconds(0.25)
			
			cinematX.playSFXSDLSingle ("sword3.wav")
			broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK3)
				
			if  math.random (100) >= 20  then
				spawnTop = not spawnTop
			end			
			
			if  spawnTop == true  then
				bossSpawnBigWind (-138)
			else
				bossSpawnBigWind (-32)
			end


			
			cinematX.waitFrames(4)
			broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK4)

			
			cinematX.waitFrames(math.random(22, 44))
			
			numSlashes = numSlashes - 1
			cinematX.yield ()
		end
		
		
		-- Next routine
		bossChangePhase_Vuln ()
		bossCurrentCoroutine = cinematX.runCoroutine (cor_bossVulnerable)
	end
	
	
	function cor_bossPogo ()
	
		-- Setup
		bossChangePhase_Pogo (5)
		local bugFix = false
		
		cinematX.playSFXSDLSingle ("voice_attack2.wav")
		broadswordActor:jump (11)
		broadswordActor.onGround = false
		
		-- Loop 	
		while (bossNumPogos > 0)  do
		
			broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK5)

			-- Jump high
			broadswordActor:jump (11)
			broadswordActor.onGround = false
			bossNumPogos = bossNumPogos - 1
			
			-- If more pogos are left, follow the player...
			if  bossNumPogos > 0  then
					
				while (broadswordActor.onGround == false  or  bugFix == false  or  broadswordActor:getSpeedY() ~= 0)  do
				
					-- Don't follow actor, follow position to prevent jump glitch
					if  bossDifficulty >= 2  then
						broadswordActor:walkToX (cinematX.playerActor:getCenterX() + player.speedX*1.5, 6, 4, 96)
					else
						broadswordActor:walkToX (cinematX.playerActor:getCenterX(), 4, 4, 96)
					end
					
					--broadswordActor:followActor (cinematX.playerActor, 4, 4, false, 96)
					
					-- Warn the player if a bounce will cause a shockwave
					if  cinematX.getBattleProgressPercent() >= 0.5  and  math.abs (broadswordActor:getSpeedY()) < 2  then
						bossSpawnFX (71, 8, 0, 0)
					end
					
					bugFix = true
					cinematX.yield ()
				end
				
			else
				break;
			end
			
			-- Spawn a shockwave at the end of a bounce during phase 2
			if (bossDifficulty >= 2  or  cinematX.getBattleProgressPercent() >= 0.5) then
				bossSpawnShockwaves ()
				earthquake (3)
			end
				
			cinematX.playSFXSDLSingle ("boing.wav")
			broadswordActor:stopFollowing ()
			
			cinematX.yield ()
		end		
			
		
		-- Next routine
		bossCurrentCoroutine = cinematX.runCoroutine (cor_bossShockStab)
	end
	
	
	function cor_bossShockStab ()
		local tempBattleFrame = 0
		
		-- Setup
		cinematX.playSFXSingle (11)
			
		-- Hold in the air
		while (tempBattleFrame < 60) do
			broadswordActor:walk(0)
			
			if broadswordActor:getSpeedY () >= 0  then						
				broadswordActor:setSpeedY (0)
				bossSpawnFX (71, 8, broadswordActor:getSpeedX(), broadswordActor:getSpeedY())
			end
			
			tempBattleFrame = tempBattleFrame + 1
			cinematX.yield ()
		end

		-- Stab down
		cinematX.playSFXSingle (22)	
		
		while (true) do
			
			-- Drop faster
			if broadswordActor:getY() < Section(player.section).boundary.bottom-242  then
				broadswordActor:setY (broadswordActor:getY() + 8)
			end	
			
			-- If still falling, keep falling...
			if broadswordActor:getY() < Section(player.section).boundary.bottom-225  then
				broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK6)
				broadswordActor:setSpeedY (64)
				
				bossSpawnFX (76, 2, math.random(-8,8), math.random(-8,8))						
			
			-- ...otherwise, move on
			else
				break;
			end
			
			cinematX.yield ()
		end
	
	
		-- Fix to the ground and spawn shockwaves						
		broadswordActor:setY(Section(player.section).boundary.bottom-225)
		bossSpawnShockwaves ()
		earthquake (8)
		broadswordActor:stopFollowing ()
			
		
		-- At the end of the stab, make vulnerable
		bossChangePhase_Vuln ()
		bossCurrentCoroutine = cinematX.runCoroutine (cor_bossVulnerable)
	end
	
	
	function cor_bossVulnerable ()
		bossCollisionOn = true
	
	
		-- Determine if the recovery is quick
		local quickRecover = true
		
		if bossCurrentVulnTime == bossDefVulnTime then
			quickRecover = false
		end
		
		
		-- Wait until the vulnerable time's up
		while (battleFrame > 0) do
			
			-- Display jump prompt
			if  battleFrame > 30  then
				--Graphics.drawImageToScene (IMGREF_JUMPSIGN, broadswordActor:getX()-16, broadswordActor:getY()-96)
			end
			
			battleFrame = battleFrame - 1
			broadswordActor:walk (0)

			broadswordActor:setAnimState (cinematX.ANIMSTATE_STUN)			
			
			cinematX.yield()
		end

		
		-- Move on
		bossCollisionOn = false
		bossBackstepCenter ()
				
		if quickRecover == true then
			bossChangePhase_Dodge (2)
		else
			bossChangePhase_Dodge (4)
			bossCurrentVulnTime = bossDefVulnTime
		end
		
		bossCurrentCoroutine = cinematX.runCoroutine (cor_bossGroundDodge)
	end
	
	
	function cor_bossDefeat ()
		
		-- Stop his movement
		broadswordActor:stopFollowing ()
		broadswordActor:stopWalking ()

		-- Wait for the boss to land
		while (bossOnGround () == false)  do
			cinematX.yield ()
		end
		
		-- Set the anim state and stop the movement
		broadswordActor:setAnimState (cinematX.ANIMSTATE_DEFEAT)
		cinematX.playSFXSDLSingle ("voice_defeat.wav")
		playMusic (20)
		
		cinematX.waitSeconds (1)
		
		cinematX.runCutscene (cutscene_afterBattle)
	end
	
	
	
	-- OLD VERSION
	
	function battleCoroutine ()	
		bossChangePhase_Dodge (4)
		bossAttackPattern = 0
		
		local performShockStab = false
		local numDashes = 1
		
		while (true) do
			fxAnim = (fxAnim + 1)%128
		
			--battleFrame = battleFrame + 1
			
			--windowDebug ("TEST")
			cinematX.waitSeconds (0)
			
			-- Determine where the boss is relative to the player
			local sectionBounds = Section(player.section).boundary
			local roomCenterX = 0.5 * (sectionBounds.left + sectionBounds.right)
			
			local closestWallX = getNPCWallClosest (broadswordActor)
			local facingWallX = getNPCWallFacing (broadswordActor)
			
			local dirToPlayerX = broadswordActor:dirToActorX (cinematX.playerActor)
			local dirToCenterX = broadswordActor:dirToX (roomCenterX)
			
			local distToPlayerX = broadswordActor:distanceActorX (cinematX.playerActor)
			local distToWallClosest = broadswordActor:distanceX (closestWallX)
			local distToWallFacing = broadswordActor:distanceX (facingWallX)
			
		  
			
			-- CLAMP BROADSWORD TO THE SECTION BOUNDS
			if  (broadswordActor:getX () > sectionBounds.right-32) then
				broadswordActor:setX (sectionBounds.right-32)
			end
			if  (broadswordActor:getX () < sectionBounds.left) then
				broadswordActor:setX (sectionBounds.left)
			end
			
			
			-- DODGE & MOVE AROUND -------------------------------------------------------------------
			if battlePhase == bossPhase_Dodge then
			
				
				-- If on the ground...
				if broadswordActor.onGround == true  then
					
					bossCollisionOn = true
					
					-- If all dodges have been performed, begin attacking
					if battleFrame == 0 then
						broadswordActor:stopFollowing ()
						bossCurrentVulnTime = bossDefVulnTime
						
					
						-- Change attack pattern
						bossAttackPattern = bossAttackPattern + 1
						if (bossAttackPattern % 2 == 1) then

							cinematX.playSFXSDLSingle ("voice_attack1.wav")
							numDashes = 1
							if  (cinematX.getBattleProgressPercent() >= 0.5) then
								numDashes = 2
							end
							
							bossChangePhase (bossPhase_DashAttack)
						else
							cinematX.playSFXSDLSingle ("voice_attack2.wav")
							broadswordActor:jump (11)
							--broadswordActor:setY (broadswordActor:getY() - 32)
							bossChangePhase_Pogo (5)
							broadswordActor.onGround = false
						end
					
					
					-- If all dodges have not been performed, keep dodging
					else
					
						-- Smooth animation transition
						if broadswordActor:getAnimState () == cinematX.ANIMSTATE_ATTACK7 then
							broadswordActor:setAnimState (cinematX.ANIMSTATE_IDLE)
						end
						
						-- If far enough from the wall...
						if     bossDistToWallClosest > 128  then 
						
							-- If far enough from the player, run to them
							if     bossDistToPlayerX > 160  then
								bossRunToPlayer ()
								
							-- Otherwise, backstep or close attack(counts as a dodge)
							elseif distToPlayerX < 160 then
								
								bossBackstepPlayer ()
								battleFrame = battleFrame - 1
							end
							
						-- If too close to the wall, flip inward (counts as a dodge)
						else
							bossFlipInward ()
							
							-- Random chance of performing a shockstab during the flip
							if (math.random(0,1) == 1  and  cinematX.getBattleProgressPercent() >= 0.5) then
								performShockStab = true
							end
							
							battleFrame = battleFrame - 1
						end
					end
				
				
				-- If in the air...
				else 
					-- Perform shockstab if chosen
					if  broadswordActor:getSpeedY () > 0  then
						if  bossCollisionOn == false  then
							bossCollisionOn = true
						end
						
						if  performShockStab == true  and  broadswordActor:getY() < Section(player.section).boundary.bottom-300  then
							performShockStab = false
							bossCurrentVulnTime = 48
							bossChangePhase_ShockStab ()
						end
					end
				end
			
			
			-- DASH ATTACK ------------------------------------------------------------------------------
			elseif battlePhase == bossPhase_DashAttack then
			
				battleFrame = battleFrame + 1
			
				-- Unsheath sword and hack away
				if battleFrame     <  60 then
					broadswordActor:walk (0)					
					broadswordActor:setSpeedY (math.max (0, broadswordActor:getSpeedY ()))
					broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK1)
					broadswordActor:lookAtPlayer ()
				
				elseif battleFrame == 60 then
					cinematX.playSFXSDLSingle (SOUNDID_SLICE)
				
				elseif battleFrame < 100 then
					bossSpawnFX (74, 2, 0, 56)
				
					broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK2)
					broadswordActor:walkForward (8)
	
					if distToWallFacing < 100 then
						battleFrame = 100
					end
				
				else
					if  numDashes > 1  then
						battleFrame = 30
						numDashes = numDashes-1
						cinematX.playSFXSDLSingle ("voice_attack1.wav")
					else
						bossChangePhase_Vuln ()
					end
				end
		  

			-- POGO ------------------------------------------------------------------------------
			elseif battlePhase == bossPhase_Pogo  then
			
				broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK5)
			
			
				-- Jump high
				if battleFrame >= 0 then
					broadswordActor:followActor (cinematX.playerActor, 4, 4, false, 96) --walkToX (cinematX.playerActor:getX(), 4, 8, 96)

					if broadswordActor.onGround == true  then
						broadswordActor:jump (11)
						
						-- Bounce
						if (battleFrame > 0  and  battleFrame ~= bossNumPogos) then
							cinematX.playSFXSDLSingle ("boing.wav")
							if (bossDifficulty >= 2  or  cinematX.getBattleProgressPercent() >= 0.5) then
								bossSpawnShockwaves ()
								earthquake (3)
							end
						end
						battleFrame = battleFrame - 1
					
					-- Warn shockwaves for phase 2
					elseif  broadswordActor.onGround == false  and  math.abs (broadswordActor:getSpeedY()) < 2  then
						if  cinematX.getBattleProgressPercent() >= 0.5  then
							bossSpawnFX (71, 8, 0, 0)
						end
					end
				end

				
				-- Switch to shockstab 
				if battleFrame == 0 then
					bossChangePhase_ShockStab ()
				end
				
			

			-- SHOCKWAVE STAB ------------------------------------------------------------------------------
			elseif battlePhase == bossPhase_ShockStab  then
						
				-- Hold in the air
				if battleFrame == 0 then
					cinematX.playSFXSingle (11)
					battleFrame = battleFrame + 1
					
				elseif battleFrame < 60 then
					battleFrame = battleFrame + 1
					broadswordActor:walk(0)
					
					if broadswordActor:getSpeedY () >= 0  then						
						broadswordActor:setSpeedY (0)
						bossSpawnFX (71, 8, 0, 0)
					end
				  
				-- Stab down
				elseif battleFrame == 60 then	  
					cinematX.playSFXSingle (22)	
					battleFrame = battleFrame + 1
				  
				elseif battleFrame < 120 then
					if broadswordActor:getY() < Section(player.section).boundary.bottom-242  then
						broadswordActor:setY (broadswordActor:getY() + 8)
					end					
					if broadswordActor:getY() < Section(player.section).boundary.bottom-225  then
						broadswordActor:setAnimState (cinematX.ANIMSTATE_ATTACK6)
						broadswordActor:setSpeedY (64)
						
						bossSpawnFX (76, 2, math.random(-8,8), math.random(-8,8))						
					else
						broadswordActor:setY(Section(player.section).boundary.bottom-225)
						
						-- Spawn shockwaves						
						bossSpawnShockwaves ()
						earthquake (8)
						battleFrame = 120
						broadswordActor:stopFollowing ()
					end
				
				
				-- At the end of the stab, make vulnerable
				else 
					bossChangePhase_Vuln ()
				end
			--]]


			-- VULNERABLE ---------------------------------------------------------------------
			elseif battlePhase == bossPhase_Vuln  then
				
				-- Determine if the recovery is quick
				local quickRecover = true
				
				if bossCurrentVulnTime == bossDefVulnTime then
					quickRecover = false
				end
				
				
				if  battleFrame > 30  then
					Graphics.drawImageToScene (IMGREF_JUMPSIGN, broadswordActor:getX()-16, broadswordActor:getY()-96)
				end
				
				--bossSpawnFX (74, 16, math.random(0, 24), math.random(-4, 4))
				
				battleFrame = battleFrame - 1
				broadswordActor:walk (0)

				
				-- Move on
				if     battleFrame > 0 then					
					broadswordActor:setAnimState (cinematX.ANIMSTATE_STUN)
					--collisionActor.smbxObjRef:mem (0x46, FIELD_WORD, 0xFFFF)
					--collisionActor.smbxObjRef:mem (0x46, FIELD_WORD, 0)

				else
					bossCollisionOn = false
					bossBackstepCenter ()
					
					if quickRecover == true then
						bossChangePhase_Dodge (1)
					else
						bossChangePhase_Dodge (4)
						bossCurrentVulnTime = bossDefVulnTime
					end
				end	
				
			
			-- DEFEAT SEQUENCE ------------------------------------------------------------------------------
			elseif battlePhase == bossPhase_Die  then
				battleFrame = battleFrame + 1

				if     battleFrame   ==   1 then
					broadswordActor:setAnimState (cinematX.ANIMSTATE_DEFEAT)
					cinematX.playSFXSDLSingle ("voice_defeat.wav")
					playMusic (20)

				elseif battleFrame   == 120 then
					broadswordActor:stopFollowing ()
					break;
				end
			end
		  
		end
		
		cinematX.runCutscene (cutscene_afterBattle)
	end
end





