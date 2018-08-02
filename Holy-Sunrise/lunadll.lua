local function testDraw(obj)
	if(obj.x > -199232 and obj.x < -194880) then
		return true;
	elseif(obj.x > -193280 and obj.x < -192608 and obj.y < -200384) then
		return true;
	elseif(obj.x > -188736 and obj.x < -184416) then
		if(obj.x > -185586 and obj.x < -185408 and obj.y > -200384) then
			return false;
		else
			return true;
		end
	else
		return false;
	end
end

function onDraw()
	if(testDraw(player)) then
		
		--mem(0x00B2C8AA,FIELD_WORD,1)
		
		for _,v in ipairs(Animation.get{74}) do
			v.drawOnlyMask = true;
		end
	
		player:render{color = Color.black, mountcolor = Color.black, drawmounts = true};
	end
end



--set to normal on exit
--function onExitLevel()
--	mem(0x00B2C8AA,FIELD_WORD,0)
--end