function onTick()
	if(player.section == 3) then
		for  k,v in ipairs(NPC.get(48, 3))  do
			--v.speedX = 0;
			--v.speedY = 0;
			v:transform(30);
			--v.direction = DIR_RIGHT;
			if  player.x < v.x  then
				--v.direction = DIR_LEFT;
				v.x = v.x - 32
			else
				v.x = v.x + 32
			end
		end
		for  k,v in ipairs(NPC.get(30, 3))  do
			v.speedX = 0;
			v.speedY = 3;
			--v.id = 246
		end
		for  k,v in ipairs(NPC.get(47, 3))  do
			v.speedX = 0;
			v.speedY = 0;
			--v.ai4 = 0
			if (v.ai5 < 19) then
				v.ai5 = 19
			end
			v.direction = DIR_RIGHT;
			if  player.x < v.x  then
				v.direction = DIR_LEFT;
			end
			
		end
		for  k,v in ipairs(NPC.get(281, 3))  do
			--v.speedX = 0;
			--v.speedY = 0;
			--v.width = 16;
			--v.height=16;
			v:transform(280);
		end
		for  k,v in ipairs(NPC.get(131, 3))  do
			v.ai1 = v.ai1 + 1.5

		end
	end
end