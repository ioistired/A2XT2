function onTick()

	for  k,v in ipairs(NPC.get(37, -1))  do

		if (v.ai1 == 0) then
			v.ai1 = 1;
			--[[if (timer == 100) then
				v.ai1 = 1;
				timer =0
			else
				timer = timer + 1
				v.ai1 = 0
			end]]
		elseif (v.ai1 == 3) then
			v.speedY = v.speedY / 1.5
		end

	end
end

