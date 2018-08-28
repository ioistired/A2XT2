Text.logWarnings = false;

--Hitbox fixes
for i = 1,7 do
	if(i > 1) then
		Level.loadPlayerHitBoxes(3, i, "../peach-"..i..".ini")
	end
	Level.loadPlayerHitBoxes(4, i, "../toad-"..i..".ini")
end

local settings = API.load("a2xt_settings");
local raocoins = API.load("a2xt_raocoincounter");
local democounter = API.load("a2xt_democounter");
local hud = API.load("a2xt_hud");
local leveldata = API.load("a2xt_leveldata");
local pause = API.load("a2xt_pause");
local spintrail = API.load("a2xt_spintrail");
local sanctuary = API.load("a2xt_leeksanctuary");
local npcs = API.load("a2xt_npcs");
local scene = API.load("a2xt_scene");
local messages = API.load("a2xt_message");
local shops = API.load("a2xt_shops");
local voice  = API.load("a2xt_voice");

API.load("a2xt_cheats")


function onStart()
	-- Blue sacks are bad.
    if (player:mem(0x108,FIELD_WORD) == 1 and player:mem(0x10A,FIELD_WORD) == 3) then
        player:mem(0x108,FIELD_WORD, 0)
    end

	-- Change this episode to a world map-based one once the intro level loads
	mem(0xB25724, FIELD_STRING, "")
	mem(0xB25728, FIELD_BOOL, false)
end

--Despawn buffer that allows fixes a vanilla bug that causes NPCs to not spawn if they despawn on the same frame they are brought into view.
local cam = Camera.get()[1];
local max = math.max;
function onCameraDraw(event, camidx)
	local x,y = cam.x, cam.y;
	for _,v in ipairs(NPC.getIntersecting(x-32, y-32, x+cam.width+32, y+cam.height+32)) do
		local n = v:mem(0x12A, FIELD_WORD);
		if(n > 0) then
			v:mem(0x12A, FIELD_WORD, max(n, 180));
		end
	end
end