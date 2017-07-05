function onLoopSection0()
	if(player.x > -199232 and player.x < -194880) then
		mem(0x00B2C8AA,FIELD_WORD,1)
	elseif(player.x > -193280 and player.x < -192608 and player.y < -200384) then
		mem(0x00B2C8AA,FIELD_WORD,1)
	elseif(player.x > -188736 and player.x < -184416) then
		if(player.x > -185586 and player.x < -185408 and player.y > -200384) then
			mem(0x00B2C8AA,FIELD_WORD,0)
		else
			mem(0x00B2C8AA,FIELD_WORD,1)
		end
	else
		mem(0x00B2C8AA,FIELD_WORD,0)
	end
end



--set to normal on exit
--function onExitLevel()
--	mem(0x00B2C8AA,FIELD_WORD,0)
--end