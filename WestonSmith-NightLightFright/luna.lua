local left = 198;
local right =  800 - left;
local speed = 1.4;
local frame;


function onLoadSection0()
   frame = false
end

function onTick()
	if(player.section == 1) then
		local screen = player.sectionObj.boundary
		if frame == false then
			screen.left = player.x - left
			screen.right = player.x + right
			frame = true
		end
		screen.left = screen.left + speed
		screen.right = screen.right + speed
		player.sectionObj.boundary = screen
	end
end

function onEvent(eventName)
	if (eventName == "StopScroll") then
		speed = 0
	end
end
