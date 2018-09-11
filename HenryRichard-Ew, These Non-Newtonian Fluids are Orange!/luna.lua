local solidFluidLayer;
local solidSpeed = 4.5;

function onStart()
	solidFluidLayer = Layer.get("Non-Newtonian Fluid Solid");
end

function onTick()
	if(solidFluidLayer.isHidden) then
		if(math.abs(player.speedX) > solidSpeed) then
			solidFluidLayer:show(true);
		end
	else
		if(math.abs(player.speedX) < solidSpeed) then
			solidFluidLayer:hide(true);
		end
	end
end