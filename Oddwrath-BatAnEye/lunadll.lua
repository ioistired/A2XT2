function onLoad()
	if (player.isValid) then
		local character = player:mem(0xF0, FIELD_WORD)
    		if (character == 3 or character == 5) then
        		player:mem(0xF0, FIELD_WORD, 1)
        	end
   	 end
	player.mount = 0
	end
function onLoop()
  if(player:mem(0x56, FIELD_WORD) > 8) then
    player:mem(0x56, FIELD_WORD, 0)
   end
  end 