left = 198;
right =  800 - left;
speed = 1.4;


function onLoadSection0(asdf)
   frame = false
end
function onLoopSection0(asdf)
   if asdf == 1 then
      screen = player.sectionObj.boundary
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
