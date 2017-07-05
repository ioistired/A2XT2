hud(false)
local overlay = Graphics.loadImage("//HUD.png");

_G["ManualArtist"] = "M. Maekawa"
_G["ManualTitle"] = "Standing Up"
_G["ManualAlbum"] = "Final Soldier"

ranInitialCheck = false
Settings = Data(Data.DATA_WORLD, "ConfigData")

InputConfig = Settings:get("ShowInputsConfig");
MusicCombo = Settings:get("MusicComboConfig")
UseDemos = Settings:get("DemoCounter");


function onLoop()

	if ranInitialCheck == false then
		if (InputConfig == 1) then
			for k, v in pairs(Block.getIntersecting(-199840,-200160,-199744,-200032)) do
				v.id = 282
			end
		end
		if (MusicCombo == 1) then
			for k, v in pairs(Block.getIntersecting(-199456,-200160,-199392,-200032)) do
				v.id = 282
			end
		end
		if (UseDemos == 1) then
			for k, v in pairs(Block.getIntersecting(-199648,-200160,-199552,-200032)) do
				v.id = 282
			end
		end
		ranInitialCheck = true
	end

	if (player.x > -199840 and player.x < -199744 and player.y > -200160 and player.y < -200032) then 

		Graphics.drawImage(overlay,0,0);
		Text.print("Input Display",30,15)
		Text.print("Show Inputs in the Bottom-Right Corner",30,40)
		--Text.print("SNES9x-style display in the Bottom-Right C",50,50)
		Text.print("ON = Enabled Off = Disabled",30,65)

	elseif (player.x > -199648 and player.x < -199552 and player.y > -200160 and player.y < -200032) then 

		Graphics.drawImage(overlay,0,0);
		Text.print("Life System",30,15)
		Text.print("Use Traditional Lives, or ASMT-Style Demos",30,40)
		--Text.print("SNES9x-style display in the Bottom-Right C",50,50)
		Text.print("ON = Life System Off = Demo System",30,65)

	elseif (player.x > -199456 and player.x < -199392 and player.y > -200160 and player.y < -200032) then 

		Graphics.drawImage(overlay,0,0);
		Text.print("Music Information Code",30,15)
		Text.print("How to activate music information",30,40)
		--Text.print("SNES9x-style display in the Bottom-Right C",50,50)
		Text.print("ON = press 'Up + Start' Off = type 'music'",30,65)



	end

end