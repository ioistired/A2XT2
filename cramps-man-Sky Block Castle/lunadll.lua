multipoints = API.load("multipoints");
multipoints.addLuaCheckpoint(-139616, -140128, 3);
multipoints.addLuaCheckpoint(-79616, -80320, 6);
multipoints.addLuaCheckpoint(20224, 19008, 11);

local blueActive = false

local lastJumpMomentum = 0
local wasOnSlope = false
local wasStandingOnYellowBlock = false

function standingOnBlock(id)
	local blocksStandingOn = Block.getIntersecting(player.x, player.y + player.height, 
								player.x + player.width, player.y + player.height + 1)
				
	for _,block in pairs(blocksStandingOn) do
		if (block.id == id) then
			return true
		end
	end
	
	return false
end

function onLoop()
	if (player.section == 1 or player.section == 2 or player.section == 4 or 
		player.section == 5 or player.section == 6 or player.section == 7 or 
		player.section == 8 or player.section == 9 or player.section == 10 or
		player.section == 11 or player.section == 12 or player.section == 13 or
		player.section == 14) then
		local onGround = wasOnSlope or (player:mem(0x146, FIELD_WORD) ~= 0)
		local jumpMomentum = player:mem(0x11C, FIELD_WORD)
		
		if (onGround) and (jumpMomentum ~= 0) and (lastJumpMomentum == 0) then
			if (not wasStandingOnYellowBlock) then
				if (blueActive) then
					triggerEvent("activateBlue")
				else
					triggerEvent("activateRed")
				end
				
				--if spinjumping, not normal jumping
				if (player:mem(0x50, FIELD_WORD) == -1) then
					Audio.playSFX("greenBeep.ogg")
				else
					Audio.playSFX("blueRedBeep.ogg")
				end
				
				blueActive = not blueActive
			end
		end
		
		lastJumpMomentum = jumpMomentum
		wasOnSlope = (player:mem(0x48, FIELD_WORD) ~= 0)
		wasStandingOnYellowBlock = standingOnBlock(171)
	end
	
	--make disco shell invincible every frame like boss invincibility
	for _,npc in pairs(NPC.get(194, player.section)) do
		npc:mem(0x156, FIELD_WORD, 2)
	end
end

function onLoad()
	if (player.isValid) then
		if (player.character == CHARACTER_PEACH or player.character == CHARACTER_LINK) then
			player.character = CHARACTER_MARIO
			--player:mem(0xF0, FIELD_WORD, 1)
		end
		
		if (player2) then
			if (player2.character == CHARACTER_PEACH or player2.character == CHARACTER_LINK) then
				player2.character = CHARACTER_LUIGI
			end
		end		
	end
end