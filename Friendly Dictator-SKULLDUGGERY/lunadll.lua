function onLoop()
	if (player.powerup ~= PLAYER_SMALL and player.powerup ~= PLAYER_BIG) then
        player.powerup = PLAYER_BIG;
    end
	local character = player:mem(0xF0, FIELD_WORD);
	if (character == 1 or character == 3 or character == 4 or character == 5) then
        player:mem(0xF0, FIELD_WORD, 2)
	end
	tableOfBirdo = NPC.get(39, -1);
  tableOfBirdoEggs = NPC.get(40, -1);
  if(tableOfBirdo[1] ~= nil) then
    if(tonumber(tableOfBirdo[1]:mem(0xF0, FIELD_DFLOAT)) == 1) then
        if(table.getn(tableOfBirdoEggs) > 0) then
          tableOfBirdoEggs[table.getn(tableOfBirdoEggs)]:mem(0xE2, FIELD_WORD, 269);
          playSFX(42); --big fireball
        end
    end
    if(tonumber(tableOfBirdo[1]:mem(0xF8, FIELD_DFLOAT)) == 280) then
      hasGenerated = false; --just reset everything
    end
  end
	myLayer = Layer.get("no hold");
	otherLayer = Layer.get("yes hold");
	if (player:mem(0x154,FIELD_WORD) > 0) then
		--Text.print("holding somethign yo", 0, 0);
		myLayer:show(false);
		otherLayer:hide(false);
	else
		myLayer:hide(false);
		otherLayer:show(false);
	end
end
function onLoadSection()
 for _,r in pairs(findnpcs(39,player.section)) do
  r:mem(0x148,FIELD_FLOAT,-1)
 end
end
function onEvent(eventname)
 if eventname == "kill birdo" then
  for _,r in pairs(findnpcs(209,player.section)) do
   r:mem(0x148,FIELD_FLOAT,6)
  end
 end
end