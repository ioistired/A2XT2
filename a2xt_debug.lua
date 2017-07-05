local dbg = {}

local showinputs = false;

function dbg.onInitAPI()
	registerEvent(dbg, "onInputUpdate", "onInputUpdate", false);
end

function dbg.onInputUpdate()
        if (showinputs == 1) then
                if (player.upKeyPressing) then
			textblox.print("U", 500, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)

                end
                if (player.downKeyPressing) then
			textblox.print("D", 520, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
                if (player.leftKeyPressing) then
			textblox.print("L", 540, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
                if (player.rightKeyPressing) then
			textblox.print("R", 560, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
       
                if (player.pauseKeyPressing) then
			textblox.print("RUN", 640, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
                if (player.dropItemKeyPressing) then
			textblox.print("SEL", 580, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
       
                if (player.runKeyPressing == true and player.altRunKeyPressing == false) then
			textblox.print("V", 780, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
       
                if (player.jumpKeyPressing) then
			textblox.print("II", 720, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
       
                if (player.altRunKeyPressing) then
			textblox.print("IV", 740, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
                if (player.altJumpKeyPressing) then
			textblox.print("I", 680, 584, inputfont, textblox.HALIGN_LEFT, textblox.HALIGN_TOP, 999, 1)
                end
       
        end
end

return dbg;