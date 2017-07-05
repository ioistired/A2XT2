timer = 0;
function onLoop()

	for  k,v in pairs(NPC.get(37, -1))  do

		if (v.ai1 == 0) then
			v.ai1 = 1;
			if (v.ai2 < 98) then
				v.ai2 = 98;
				timer = 0
			--else
				--timer = timer + 1
				--v.ai1 = 0
			end
		end
		if (v.ai1 == 3) then
			v.speedY = v.speedY * 1.5
		end

	end
end

function onLoop()
    for _,npc in pairs(NPC.get(53, -1)) do
        if (npc:mem(0x0A, FIELD_WORD) == 0) and (npc:mem(0x64, FIELD_WORD) == 0) then
            npc.speedY = npc.speedY - 0.15
        end
    end
end