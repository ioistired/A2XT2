local myLayer;
local otherLayer;

function onStart()
	myLayer = Layer.get("no hold");
	otherLayer = Layer.get("yes hold");
end

function onTick()
	local tableOfBirdo = NPC.get(39, -1);
	local tableOfBirdoEggs = NPC.get(40, -1);
	
	if(tableOfBirdo[1] ~= nil) then
		if(tableOfBirdo[1].ai1 == 1 and #tableOfBirdoEggs > 0) then
			tableOfBirdoEggs[#tableOfBirdoEggs]:transform(269);
			Audio.playSFX(42); --big fireball
		end
		if(tableOfBirdo[1].ai2 == 280) then
			hasGenerated = false; --just reset everything
		end
	end
	
	if (player.holdingNPC ~= nil and myLayer.isHidden) then
		--Text.print("holding somethign yo", 0, 0);
		myLayer:show(false);
		otherLayer:hide(false);
	elseif(player.holdingNPC == nil and not myLayer.isHidden) then
		myLayer:hide(false);
		otherLayer:show(false);
	end
end

function onLoadSection()
	for _,r in ipairs(NPC.get(39,player.section)) do
		r:mem(0x148,FIELD_FLOAT,-1)
	end
end

function onEvent(eventname)
	if eventname == "kill birdo" then
		for _,r in ipairs(NPC.get(209,player.section)) do
			r:mem(0x148,FIELD_FLOAT,6)
		end
	end
end