
local blueActive = false
local greenActive = true
local hasJumped = false
local pressedJump = false

local previousPlayerY = 0
local secondPreviousPlayerY = 0

function onKeyDown(keycode, playerIndex)
	if (playerIndex == 1) then
		if (keycode == KEY_JUMP or keycode == KEY_SPINJUMP) then
			if (secondPreviousPlayerY == 0) then
				hasJumped = false
			end

			if (not hasJumped and not pressedJump) then
				if (blueActive) then
					triggerEvent("activateBlue")
				else
					triggerEvent("activateRed")
				end
				
				if (keycode == KEY_SPINJUMP) then
					if (greenActive) then
						triggerEvent("deactivateGreen")
					else
						triggerEvent("activateGreen")
					end

					greenActive = not greenActive
					Audio.playSFX("greenBeep.ogg")
				else
					Audio.playSFX("blueRedBeep.ogg")
				end
				
				blueActive = not blueActive
				hasJumped = true
				pressedJump = true
			end
		end
	end
end

function onLoop()
	secondPreviousPlayerY = previousPlayerY
	previousPlayerY = player.speedY
	pressedJump = false
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