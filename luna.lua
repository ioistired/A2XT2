--**********
--|INCLUDES|
--**********
 --API.load("pSwitchTicking")

API.load("a2xt_savedata");
local settings = API.load("a2xt_settings");
local raocoins = API.load("a2xt_raocoincounter");
local democounter = API.load("a2xt_democounter");
local hud = API.load("a2xt_hud");
local music = API.load("a2xt_music");
local spintrail = API.load("a2xt_spintrail");
local leveldata = API.load("a2xt_leveldata");
local sanctuary = API.load("a2xt_leeksanctuary");
local npcs = API.load("a2xt_npcs");

function onInputUpdate()
        --*****************************
        --|START + SELECT BUTTON COMBO|
        --*****************************
        if (player.dropItemKeyPressing and player.pauseKeyPressing) then
                player.dropItemKeyPressing = false
                player.pauseKeyPressing = false
				Level.exit();
        end
end

local function LoadHitboxes()

	--******************************
	--|KOOD AND RAOCOW HITBOX FIXES|
	--******************************
	Level.loadPlayerHitBoxes(3, 2, "../peach-2.ini")
	Level.loadPlayerHitBoxes(3, 3, "../peach-3.ini")
	Level.loadPlayerHitBoxes(3, 4, "../peach-4.ini")
	Level.loadPlayerHitBoxes(3, 5, "../peach-5.ini")
	Level.loadPlayerHitBoxes(3, 6, "../peach-6.ini")
	Level.loadPlayerHitBoxes(3, 7, "../peach-7.ini")
	
	Level.loadPlayerHitBoxes(4, 1, "../toad-1.ini")
	Level.loadPlayerHitBoxes(4, 2, "../toad-2.ini")
	Level.loadPlayerHitBoxes(4, 3, "../toad-3.ini")
	Level.loadPlayerHitBoxes(4, 4, "../toad-4.ini")
	Level.loadPlayerHitBoxes(4, 5, "../toad-5.ini")
	Level.loadPlayerHitBoxes(4, 6, "../toad-6.ini")
	Level.loadPlayerHitBoxes(4, 7, "../toad-7.ini")
end
 
function onStart()
	LoadHitboxes();
	
    --*************************************
    --|REMOVE ANY BLUE SACKS ON LEVEL LOAD|
    --*************************************
    if (player:mem(0x108,FIELD_WORD) == 1 and player:mem(0x10A,FIELD_WORD) == 3) then
        player:mem(0x108,FIELD_WORD, 0)
    end
 
end
 