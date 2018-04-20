--[[
READ THIS BEFORE ADDING:
- For code that runs only in your section, add your own function, wrapped with a conditional:
--	local function yourName()
--      if player.section == <section number> then
--			--YOUR CODE HERE
--		end
--	end

- Define local variables related to your section code above the function

- If it has to go in a shared function, separate it from other dev's code with a comment
--]]


-- *************
-- ** Pholtos **
-- *************
local function pholtos()
	if(player.section == 3) then
		for _,npc in ipairs(NPC.get(53, -1)) do
			-- If not on the ground and not a generator
			if  not npc:mem(0x0A, FIELD_BOOL)  and  not npc:mem(0x64, FIELD_BOOL)  then
				npc.speedY = npc.speedY - 0.15
			end
		end
	end
end

-- **************
-- ** 7NameSam **
-- **************
local function sam()
	if(player.section == 4) then
		-- This should be replaced with a drawn graphic
		for  k,v in ipairs(NPC.get(223, -1))  do
			v.x = player.x
		end
	end
end

local timer = 0;
function onTick()
	for  k,v in ipairs(NPC.get(37, -1))  do
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
	
	pholtos();
	sam();
end