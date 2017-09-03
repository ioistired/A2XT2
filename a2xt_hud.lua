local npcconfig = API.load("npcconfig");
local raocoins = API.load("a2xt_raocoincounter");
local settings = API.load("a2xt_settings");
local textblox = API.load("textblox");
local imagic = API.load("imagic");
local vectr;
local map3d;
local leveldata;

_G.A2XT_FONT_MAIN = textblox.Font (textblox.FONTTYPE_SPRITE, {ini = "graphics/fonts/font_main.ini", image = Graphics.loadImage(Misc.resolveFile("graphics/fonts/font_main.png"))})	

_G.CHAR_RC = "<color white>\127<color default>"

textblox.presetProps[textblox.PRESET_SYSTEM].font = A2XT_FONT_MAIN
textblox.presetProps[textblox.PRESET_BUBBLE].font = A2XT_FONT_MAIN
textblox.presetProps[textblox.PRESET_SIGN].font = A2XT_FONT_MAIN

local img_minus = Graphics.loadImage(Misc.resolveFile("graphics/hardcoded/hardcoded-50-minus.png"));

local icons_chars;
local icons_filters;
local levelbg;
local img_levelbg = Graphics.loadImage(Misc.resolveFile("graphics/HUD/levelBorder.png"));
local lvlalpha;
local lvlfile;

local saveDisplayTime = 64;
local saveTimer = 0;
local saveImage = Graphics.loadImage(Misc.resolveFile("graphics/HUD/save.png"))

local defaultSave = Misc.saveGame;
function Misc.saveGame(...)
	defaultSave(...);
	saveTimer = saveDisplayTime;
end

if(isOverworld) then
	vectr = API.load("vectr");
	map3d = API.load("map3d");
	leveldata = API.load("a2xt_leveldata");
	
	icons_chars = {};
	icons_filters = {};
	
	icons_chars[CHARACTER_DEMO] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_demo.png"))
	icons_chars[CHARACTER_IRIS] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_iris.png"))
	icons_chars[CHARACTER_KOOD] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_kood.png"))
	icons_chars[CHARACTER_RAOCOW] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_raocow.png"))
	icons_chars[CHARACTER_SHEATH] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/head_sheath.png"))
	
	icons_filters[-2] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_catllama.png"))
	icons_filters[-1] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_sack.png"))
	icons_filters[PLAYER_BIG] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_beet.png"))
	icons_filters[PLAYER_FIREFLOWER] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_fire.png"))
	icons_filters[PLAYER_LEAF] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_leaf.png"))
	icons_filters[PLAYER_TANOOKIE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_onion.png"))
	icons_filters[PLAYER_HAMMER] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_gourd.png"))
	icons_filters[PLAYER_ICE] = Graphics.loadImage(Misc.resolveFile("graphics/HUD/filters/filter_ice.png"))
	
	lvlalpha = 0;
end

local hud = {};

local showhud = true;

local HUD_IMG = { 
					demos = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/demos.png")),
					food = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/food.png")),
					itembox = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/itembox.png")),
					x = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/x.png")),
					coins = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/coins.png")),
					raocoins = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/raocoins.png")),
					leeks = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/leeks.png"))
				}
				
local HEART_IMG = {
					[CHARACTER_KOOD] = {empty = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/hp_carrot_empty.png")), full = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/hp_carrot.png"))},
					[CHARACTER_RAOCOW] = {empty = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/hp_cat2_empty.png")), full = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/hp_cat2.png"))},
					[CHARACTER_SHEATH] = {empty = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/hp_heart_empty.png")), full = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/hp_heart.png"))}
				  }
				
local function printHUDObj(img, value, x, y,priority)
		Graphics.drawImageWP(img, x, y,priority);
		Graphics.drawImageWP(HUD_IMG.x, x+16, y,priority);
		Text.printWP(value, 1, x+32, y+1,priority);
end

local function drawNPC(id, x, y, priority)
		if(id == 0) then
			return;
		end
		local gfxw = npcconfig[id].gfxwidth;
		local gfxh = npcconfig[id].gfxheight;
		if(gfxw == 0) then
			gfxw = npcconfig[id].width;
		end
		if(gfxh == 0) then
			gfxh = npcconfig[id].height;
		end
		Graphics.draw{x=x-gfxw*0.5,y=y-gfxh*0.5,type=RTYPE_IMAGE,image=Graphics.sprites.npc[id].img,sourceX=0,sourceY=0,priority=priority,sourceWidth=gfxw,sourceHeight=gfxh};
end

function hud.onInitAPI()
	registerEvent(hud, "onDraw", "onDraw", false);
	registerEvent(hud, "onDrawEnd", "onDrawEnd", false);
end


--Specific things for currency huds
function hud.drawFood(x, y, priority)
	Graphics.drawImageWP(HUD_IMG.food, x, y, priority);
	if(GLOBAL_LIVES < 0) then
		Graphics.drawImageWP(img_minus, x, y+19,priority);
	end
	Text.printWP(GLOBAL_LIVES, 1, x, y+19,priority)
end

function hud.drawRC(x,y,priority)
	printHUDObj(HUD_IMG.raocoins, raocoins.get(), x, y,priority);
end

function hud.window (args)
	args.image = args.image or img_levelbg
	
	return imagic.Create{primitive=imagic.TYPE_BOX, x=args.x,y=args.y, width=args.width, height=args.height, align=imagic.ALIGN_CENTRE, bordertexture=args.image, borderwidth = 32};
end


local function getOWLevelObj()
	if(world.levelObj and math.abs(world.levelObj.y-world.playerY) < 8) then
		return world.levelObj;
	else
		return nil;
	end
end

local function drawHUD(priority)
	local sideoffset = 75;
	if(saveTimer > 0) then
		Graphics.drawImageWP(saveImage, 800-24, 600-24, (saveTimer/saveDisplayTime), 10);
		saveTimer = saveTimer - 1;
	end
	if((isOverworld and showhud == WHUD_ALL) or (not isOverworld and showhud)) then
		Graphics.drawImageWP(HUD_IMG.demos,400-sideoffset-64,20,priority);
		Text.printWP(GLOBAL_DEMOS, 1, 400-sideoffset-64, 39,priority)
		
		hud.drawFood(400-sideoffset-140,20,priority);
	
		if(isOverworld and player:mem(0x16, FIELD_WORD) == 0) then
			player:mem(0x16, FIELD_WORD, 1);
		end
		if(player.character == CHARACTER_DEMO or player.character == CHARACTER_IRIS) then
			Graphics.drawImageWP(HUD_IMG.itembox,368,12,priority);
			
			drawNPC(player.reservePowerup,400,44,priority);
		else
			local wid = 32;
			for i=1,3 do
				local g;
				if(player:mem(0x16, FIELD_WORD) >= i) then
					g = HEART_IMG[player.character].full;
				else
					g = HEART_IMG[player.character].empty;
				end
				Graphics.drawImageWP(g,400 - (wid*1.5) + wid * (i-1),20,priority);
			end
		end
		
		printHUDObj(HUD_IMG.coins, mem(0x00B2C5A8,FIELD_WORD), 400+sideoffset+96, 20,priority);
		printHUDObj(HUD_IMG.leeks, mem(0x00B251E0,FIELD_WORD), 400+sideoffset+96, 38,priority);
		
		hud.drawRC(400+sideoffset, 20,priority);
		
		for i=1,math.min(5,raocoins.local_counter),1 do
			Graphics.drawImageWP(HUD_IMG.raocoins,400+sideoffset+12*(i-1),38,priority);
		end
		
		--Draw overworld-specific hud pieces
		if(isOverworld) then
			local lvlobj = getOWLevelObj();
			if(lunatime.tick() > 0 and (lvlobj or lvlalpha > 0)) then
				if(lvlobj) then
					lvlfile = lvlobj.filename;
				elseif(lvlfile == nil) then
					levelbg = nil;
					return;
				end
				
				local data = leveldata.GetData(lvlfile);
				if(data) then
					if(lvlobj) then
						lvlalpha = math.lerp(lvlalpha, 1, 0.2);
					else
						lvlalpha = math.lerp(lvlalpha, 0, 0.2);
						if(lvlalpha < 0.05) then
							lvlfile = nil;
						end
					end
					local p = map3d.project(vectr.v4(world.playerX + 16, 0, world.playerY, 1));
					p.y = p.y - 48;
					
					local author = "by "..data.Author;
					
					local wid = math.max(GENERIC_FONT:getStringWidth(data.Name), GENERIC_FONT:getStringWidth(author));
					local hei = GENERIC_FONT.charHeight * 2 + 28;
					
					if(data.Filters) then
						hei = hei + 20;
					end
					
					x = p.x + 400;
					y = p.y + 300 - hei;
					local bgalpha = 0.75;
					
					local bga = math.floor(lvlalpha*bgalpha*255);
					local lvla = math.floor(lvlalpha*255);
					
					if(levelbg == nil) then
						levelbg = imagic.Create{primitive=imagic.TYPE_BOX, x=x,y=y+hei*0.5, align=imagic.ALIGN_CENTRE, width = wid+64, height = hei+32, bordertexture=img_levelbg, borderwidth = 32};
					end
					levelbg:Draw{priority=priority, colour=0x07122700+bga, bordercolour = 0xFFFFFF00+bga};
					textblox.printExt(data.Name, {x = x, y = y+4, width=600, font = GENERIC_FONT, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0xFFFFFF00+lvla})
					textblox.printExt(author, {x = x, y = y+4+GENERIC_FONT.charHeight+2, width=600, font = GENERIC_FONT, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0xFFFFFF00+lvla})
					
					local chrs = leveldata.CharsOrDefault(data);
					local iconx = x+10-(10*#chrs)-8;
					for k,v in ipairs(chrs) do
						Graphics.drawImageWP(icons_chars[v], iconx, y + GENERIC_FONT.charHeight * 2 + 10, lvlalpha, priority)
						iconx = iconx + 20;
					end
					
					if(data.Filters) then
						iconx = x+10-(10*#data.Filters)-8;
						for k,v in ipairs(data.Filters) do
							Graphics.drawImageWP(icons_filters[v], iconx, y + GENERIC_FONT.charHeight * 2 + 30, lvlalpha, priority)
							iconx = iconx + 20;
						end
					end
				end
			else
				levelbg = nil;
			end
		end
	end
end

function renderHUD(idx, priority)
	showhud = Graphics.isHudActivated();
		
	drawHUD(priority);
end

function hud.onDraw()
	if(isOverworld) then
		showhud = Graphics.getOverworldHudState();
		Graphics.activateOverworldHud(WHUD_NONE);
		drawHUD(5);
	else
		showhud = Graphics.isHudActivated();
	end
end

function hud.onDrawEnd()
	if(isOverworld) then
		Graphics.activateOverworldHud(showhud);
	end
end

return hud;