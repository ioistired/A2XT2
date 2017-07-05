multipoints = loadSharedAPI("multipoints");

multipoints.addLuaCheckpoint(-179744, -179680, 1);
multipoints.addLuaCheckpoint(-159488, -160128, 2);
multipoints.addLuaCheckpoint(-139648, -140096, 3);
multipoints.addLuaCheckpoint(-119488, -120128, 4);
multipoints.addLuaCheckpoint(-99648, -100096, 5);
multipoints.addLuaCheckpoint(-79488, -80128, 6);

function onLoopSection3()
	for  k,v in pairs(NPC.get(48, 3))  do
		--v.speedX = 0;
		--v.speedY = 0;
		v.width = 32;
		v.height =32;
		v.id = 30
		--v.direction = DIR_RIGHT;
		if  player.x < v.x  then
			--v.direction = DIR_LEFT;
			v.x = v.x - 32
		else
			v.x = v.x + 32
		end
	end
	for  k,v in pairs(NPC.get(30, 3))  do
		v.speedX = 0;
		v.speedY = 3;
		--v.id = 246
	end
	for  k,v in pairs(NPC.get(47, 3))  do
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
	for  k,v in pairs(NPC.get(281, 3))  do
		--v.speedX = 0;
		--v.speedY = 0;
		--v.width = 16;
		--v.height=16;
		v.id = 280
	end
	for  k,v in pairs(NPC.get(131, 3))  do
		v.ai1 = v.ai1 + 1.5

	end
end