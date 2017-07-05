--Load Apis
multipoints = loadAPI("multipoints");

--Set Multipoints
multipoints.addLuaCheckpoint(40384, 39648, 12);
multipoints.addLuaCheckpoint(192, -256, 10);

--ON LOAD
function onLoad()
	if player.isValid then
		--Player Filter
		if (player:mem(0xF0, FIELD_WORD) >= 3) then
			player:mem(0xF0, FIELD_WORD, 1)
		end
	end
end