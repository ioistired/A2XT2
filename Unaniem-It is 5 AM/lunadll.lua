local graphX = loadSharedAPI("graphX");

tintImg = Graphics.loadImage ("noGL-Tint.png")

function onHUDDraw ()
	if  Graphics.isOpenGLEnabled()  then
		graphX.boxScreen (0,0,800,600, 0x00000099)
	else
		Graphics.drawImageWP (tintImg, 0,0, 9/16, 2.0)
	end
end