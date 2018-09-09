local message = API.load("a2xt_message");

local water = 0;

local coinCounters = {};
local coinCount = 1;

local ectoOff;
local ectoOn;

function onStart()
	ectoOff = Layer.get("OFFecto")
	ectoOn = Layer.get("ONecto")
end

function onTick()
	if(player:mem(0x34, FIELD_WORD) == 2) then
		water = 300;
	elseif(water > 0) then
		water = water-1;
		if(water == 64) then
			SFX.play(86)
		end
	end
	
	if(water > 0) then
		player:mem(0x02, FIELD_BOOL, true)
		if(not ectoOff.isHidden) then
			ectoOff:hide(true)
		end
		if(ectoOn.isHidden) then
			ectoOn:show(true)
		end
	else
		player:mem(0x02, FIELD_BOOL, false)
		if(not ectoOn.isHidden) then
			ectoOn:hide(true)
		end
		if(ectoOff.isHidden) then
			ectoOff:show(true)
		end
	end
	
	for i = #coinCounters,1,-1 do
		local v = coinCounters[i];
		v.y = v.y - 1;
		v.t = v.t-1;
		if(v.t <= 0) then
			table.remove(coinCounters,i);
		end
	end
end

function onDraw()
	if(water > 0) then
		player:render{color=math.lerp(Color.white, Color(0.2,1,0.5), water/300)}
	end
	
	for _,v in ipairs(coinCounters) do
		Text.printWP(v.c, v.x-camera.x, v.y-camera.y,-5);
	end
end

function onNPCKill(event, npcobj, reason)
	if(npcobj.id == 103) then
		table.insert(coinCounters, {c = coinCount, x = npcobj.x, y = npcobj.y, t = 64});
		coinCount = coinCount + 1;
	end
end

function message.onMessageEnd(talkNPC)
	if(talkNPC.id == 42) then
		triggerEvent("end");
	end
end