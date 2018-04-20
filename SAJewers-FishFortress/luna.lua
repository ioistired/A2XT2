	_G["ManualTitle"] = "Ice Tower"
	_G["ManualArtist"] = "Falcom Sound Team J.D.K."
	_G["ManualAlbum"] = "Kaze no Densetsu Xanadu"

function onStart()
	for _,v in ipairs(NPC.get(400)) do
		local section = v:mem(0x146,FIELD_WORD);
		if(section == 6) then
			v.x = -139712; 
			v.y = -140352;
			v:mem(0x146,FIELD_WORD,3);
			v:mem(0xA8,FIELD_DFLOAT,v.x);
			v:mem(0xB0,FIELD_DFLOAT,v.y);
		elseif(section == 7) then
			v.x = -119776;
			v.y = -115488;
			v:mem(0x146,FIELD_WORD,4);
			v:mem(0xA8,FIELD_DFLOAT,v.x);
			v:mem(0xB0,FIELD_DFLOAT,v.y);
		end
	end
end

function onHUDDraw ()
	if (player.section == 1 or player.section == 2 or player.section == 5) then
			Graphics.drawScreen{color = {0.439,0.69,0.878,0.5}}
	end
end

