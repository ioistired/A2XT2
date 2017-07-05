	_G["ManualTitle"] = "Ice Tower"
	_G["ManualArtist"] = "Falcom Sound Team J.D.K."
	_G["ManualAlbum"] = "Kaze no Densetsu Xanadu"


multipoints = loadSharedAPI("multipoints");

multipoints.addLuaCheckpoint(-139712, -140352, 6, -79936, -80096);
multipoints.addLuaCheckpoint(-119712, -115488, 7, -59936, -60096);


local graphX = loadSharedAPI("graphX");

tintImg = Graphics.loadImage ("noGL-Tint.png")

function onHUDDraw ()
	if (player.section == 1 or player.section == 2 or player.section == 5) then
		if  Graphics.isOpenGLEnabled()  then
			graphX.boxScreen (0,0,800,600, 0x70B0E080)
		else
			Graphics.drawImageWP (tintImg, 0,0, 8/16, 2.0)
		end
	end
end

function onLoop()

end

