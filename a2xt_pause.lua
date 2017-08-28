local textblox = API.load("textblox")
local imagic = API.load("imagic")
local pm = API.load("playerManager")
local leveldata = API.load("a2xt_leveldata")

local pause = {}

local musicicons = Graphics.loadImage(Misc.resolveFile("graphics/HUD/musicicons.png"));
local musicTimer = 0;

pause.Music = { BlankGraphic = false, Title = nil, Artist = nil, Album = nil }

pause.Blocked = false;

local game_paused = false;
local unpausing = false;
local pause_blend = 0;

function _G.isGamePaused()
	return game_paused;
end

local shader_blur;
local buffer = Graphics.CaptureBuffer(800,600);

local pause_priority = 10;
local pause_option = 0;

local confirm;
local confirm_option = 0;
local confirm_alpha = 0;

local quitting = false;

local function confirmBox(func)
	confirm = func;
	Audio.playSFX(30);
end

local function unpause()
	unpausing = true;
	Audio.playSFX(30);
	--registerEvent(pm, "onInputUpdate", "onInputUpdate", false);
end

local function option_save()
	Misc.saveGame();
	Audio.playSFX(12);
end

local function levelexit()
	quitting = true;
	unpause();
	Level.exit();
end

local function gameexit()
	quitting = true;
	unpause();
	Misc.exitGame();
end

local function option_exitlevel()
	confirmBox(levelexit);
end

local function option_exitgame()
	confirmBox(gameexit);
end

local function option_restart()
	quitting = true;
	unpause();
	mem(0x00B2C6DA, FIELD_WORD, -1);
	mem(0x00B25720, FIELD_STRING, Level.filename());
	mem(0x00B250B4, FIELD_WORD, 0);
	mem(0x00B25134, FIELD_WORD, 0);
	mem(0x00B2C89C, FIELD_WORD, 0);
	mem(0x00B2C620, FIELD_WORD, 0);
	mem(0x00B2C5B4, FIELD_WORD, -1);
end

local options = {
				{name = "continue", action = unpause}
				};

do
	if(isOverworld or isTownLevel()) then
		table.insert(options, {name = "save", action = option_save});
	end

	if(isOverworld or --[[is Intro Stage]] false) then
		if(--[[unlocked hub]] true) then
			table.insert(options, {name = "return to P.O.R.T.(S.)", action = function() end});
		end
	else
		table.insert(options, {name = "exit to map", action = option_exitlevel});
	end
		
	table.insert(options, {name = "quit game", action = option_exitgame});
			
	if(not isOverworld and mem(0x00B2C62A, FIELD_WORD) == 0) then --in editor
		table.insert(options,2,{name = "reload level", action = option_restart});
	end
end

local pauseBorder = Graphics.loadImage(Misc.resolveFile("graphics/HUD/levelBorder.png"));
local pausebg = imagic.Create{primitive=imagic.TYPE_BOX, x=400,y=300, align=imagic.ALIGN_CENTRE, width = 400, height = (40*#options)+40, bordertexture=pauseBorder, borderwidth = 32};

local confirmbg = imagic.Create{primitive=imagic.TYPE_BOX, x=400,y=300, align=imagic.ALIGN_CENTRE, width = 300, height = 120, bordertexture=pauseBorder, borderwidth = 32};

local charbg;
local arrowLeft;
local arrowRight;
local arrowPos;

if(isOverworld) then
	charbg = imagic.Create{primitive=imagic.TYPE_BOX, x=400,y=208, align=imagic.ALIGN_BOTTOM, width = 100, height = 100, bordertexture=pauseBorder, borderwidth = 32};
	arrowLeft = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/sanctuary_arrow_left.png"))
	arrowRight = Graphics.loadImage(Misc.resolveFile("graphics/sanctuary/sanctuary_arrow_right.png"))
	arrowPos = 0;
end

local function drawMusic(p)
	local y = 500;
	
	Graphics.glDraw{vertexCoords={0,y,800,y,800,y+100,0,y+100}, color = {0,0,0,0.5}, priority = p, primitive = Graphics.GL_TRIANGLE_FAN};
	
	if (not pause.Music.BlankGraphic) then
		Graphics.drawImageWP(musicicons,22,y+15,p);
	end
          
	y = y + 15; 
	 
	if (pause.Music.Title == nil) then
        Text.printWP(Audio.MusicTitleTag(),50,y,p)
	else
        Text.printWP(pause.Music.Title,50,y,p)
	end
	if (pause.Music.Artist == nil) then
        Text.printWP(Audio.MusicArtistTag(),50,y+25,p)
	else
        Text.printWP(pause.Music.Artist,50,y+25,p)
	end
	if (pause.Music.Album == nil) then
        Text.printWP(Audio.MusicAlbumTag(),50,y+50,p)
	else
        Text.printWP(pause.Music.Album,50,y+50,p)
	end
end

local function formatSelected(name)
	return "<gt>  \0<wave>"..name.."</wave>\0  <lt>";
end

local function drawConfirmBox(priority, alpha)

	local bga = alpha*0.85;
	confirmbg:Draw{priority=priority, colour=0x07122700+bga, bordercolour = 0xFFFFFF00+bga};
		
	textblox.printExt("Exiting will lose unsaved progress. Continue?", {x = 400, y = 260, width=250, font = GENERIC_FONT, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0xFFFFFF00+alpha})
	
	local ops = {"no", "yes"}
	
	for k,name in ipairs(ops) do
		if(confirm_option+1 == k) then
			name = formatSelected(name);
		end
		textblox.printExt(name, {x = 340+100*(k-1), y = 320, width=400, font = GENERIC_FONT, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0xFFFFFF00+alpha});
	end
end

local function drawPause(priority)
	if(shader_blur == nil) then
		shader_blur = Shader();
		shader_blur:compileFromFile(nil, Misc.resolveFile("shaders/blur_gauss.frag"));
	end
	if(game_paused) then
		if(unpausing) then
			pause_blend = pause_blend-0.1;
			if(pause_blend < 0) then
				game_paused = false;
				pause_blend = 0;
				Misc.unpause();
				return;
			end
		else
			pause_blend = pause_blend+0.1;
		end
		pause_blend = math.min(math.max(pause_blend,0),1);
		
		Graphics.glDraw{
			vertexCoords = {0,0,800,0,800,600,0,600},
			textureCoords = {0,0,1,0,1,1,0,1},
			primitive = Graphics.GL_TRIANGLE_FAN,
			texture = buffer, 
			priority=priority,
			shader = shader_blur,
			uniforms =
			{
				iResolution = {800,600,0},
				blend = pause_blend
			}
		}
		
		local alpha = math.floor(pause_blend*255);
		local bga = alpha*0.75;
		
		pausebg:Draw{priority=priority, colour=0x07122700+bga, bordercolour = 0xFFFFFF00+bga};
		
		local y = 300 - (20*#options);
		if(isOverworld) then
			
			local ps = PlayerSettings.get(pm.getCharacters()[player.character].base, player.powerup);
			
			local tx1,ty1 = 3,4;
			if(player.character == CHARACTER_SHEATH) then
				tx1 = 5;
				ty1 = 0;
			end
			
			local xOffset = ps:getSpriteOffsetX(tx1, ty1);
			local yOffset = ps:getSpriteOffsetY(tx1, ty1);--+ player:mem(0x10E,FIELD_WORD);
			player.height = ps.hitboxHeight
			player.width = ps.hitboxWidth
			
			tx1 = tx1*0.1;
			ty1 = ty1*0.1;
			
			charbg.y = y-32
			charbg.border.y = y-32;
			charbg:Draw{priority=priority, colour=0x07122700+bga, bordercolour = 0xFFFFFF00+bga};
			
			Graphics.drawImageWP(Graphics.sprites[pm.getCharacters()[player.character].name][player.powerup].img, 400-player.width*0.5+xOffset, y-player.height*0.5-32-48+yOffset, tx1*1000, ty1*1000, 100, 100, priority)
			
			if(not confirm) then
				local a = math.sin(arrowPos)
				
				Graphics.drawImageWP(arrowLeft, 360 + a, y-90, priority)
				Graphics.drawImageWP(arrowRight, 800-360-16 - a, y-90, priority)
				
				arrowPos = arrowPos+0.1;
			end
		end
		
		textblox.printExt("PAUSED", {x = 400, y = y, width=400, font = GENERIC_FONT, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0xFFFFFF00+alpha})
		
		for k,v in ipairs(options) do
			local name = v.name;
			if(k == pause_option+1 and confirm == nil) then
				name = formatSelected(name);
			end
			textblox.printExt(name, {x = 400, y = y+40+30*(k-1), width=400, font = GENERIC_FONT, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=priority, color=0xFFFFFF00+alpha});
		end
		
		
		if(confirm_alpha > 0 or confirm) then
			if(confirm) then
				confirm_alpha = confirm_alpha + 0.2;
			else
				confirm_alpha = confirm_alpha - 0.2;
			end
			
			confirm_alpha = math.min(math.max(confirm_alpha,0),1);
			drawConfirmBox(priority, math.floor(confirm_alpha*255));
			
		end
		
		if(pause_blend == 1 or musicTimer > 0) then
			drawMusic(priority);
		end
	end
end

local charList = {CHARACTER_DEMO, CHARACTER_IRIS, CHARACTER_RAOCOW, CHARACTER_KOOD, CHARACTER_SHEATH}
local currentChar = 1;

function pause.onInitAPI()
	registerEvent(pause, "onInputUpdate", "onInputUpdate", true);
	registerEvent(pause, "onExitLevel", "onExitLevel", false);
	registerEvent(pause, "onDraw", "onDraw", false);
	registerEvent(pause, "onPause", "onPause", false);
	
	if(isOverworld) then
		currentChar = table.ifind(charList, player.character)
	end
end

function pause.onPause(evt)
	evt.cancelled = true;
end

function pause.Block()
	pause.Blocked = true;
end

function pause.Unblock()
	pause.Blocked = false;
end

function pause.onInputUpdate()
	unregisterEvent(pm, "onInputUpdate", "onInputUpdate");
	local prepareMusic = false;
    local musiccheatcode = Misc.cheatBuffer()
    local musiccheat = string.find(musiccheatcode, "music", 1)
	
	if (musiccheat ~= 0 and musiccheat ~= nil) then --music code
        musicTimer = lunatime.toTicks(4);
        Misc.cheatBuffer("")
	end
   
   if(player.keys.pause and not presspause) then
		if(game_paused) then
			unpause();
		elseif (not mem(0x00B250E2, FIELD_BOOL) and not Misc.isPausedByLua() and not pause.Blocked) then
			game_paused = true;
			unpausing = false;
			buffer:captureAt(pause_priority);
			Misc.pause();
			Audio.playSFX(30);
		end
	elseif(game_paused) then
		if(player.keys.down == KEY_PRESSED and confirm == nil) then
			pause_option = (pause_option+1)%(#options);
			Audio.playSFX(26)
		elseif(player.keys.up == KEY_PRESSED and confirm == nil) then
			pause_option = (pause_option-1)%(#options);
			Audio.playSFX(26)
		elseif((player.keys.left == KEY_PRESSED or player.keys.right == KEY_PRESSED)) then
			if(confirm ~= nil) then
				confirm_option = 1-confirm_option;
				Audio.playSFX(26)
			elseif(isOverworld) then
				if(player.keys.left == KEY_PRESSED and not player.keys.right) then
					currentChar = currentChar-1;
					if(currentChar < 1) then
						currentChar = 5;
					end
					leveldata.setCharacter(charList[currentChar]);
					Audio.playSFX(26)
				elseif(player.keys.right == KEY_PRESSED and not player.keys.right) then
					currentChar = currentChar+1;
					if(currentChar > 5) then
						currentChar = 1;
					end
					leveldata.setCharacter(charList[currentChar]);
					Audio.playSFX(26)
				end
			end
			
		elseif(player.keys.jump == KEY_PRESSED) then
			if(confirm == nil) then
				options[pause_option+1].action();
			else
				if(confirm_option == 1) then
					confirm();
				end
				Audio.playSFX(30);
				confirm = nil;
				confirm_option = 0;
			end
		end
	end
	presspause = player.keys.pause;
end

function pause.onDraw()
	if(game_paused) then
		drawPause(pause_priority);
	elseif(musicTimer > 0) then
		musicTimer = musicTimer - 1;
		drawMusic(pause_priority);
	end
	if(quitting) then
		Graphics.glDraw{vertexCoords={0,0,800,0,800,600,0,600}, primitive = Graphics.GL_TRIANGLE_FAN, color = {0,0,0,1-pause_blend}, priority=10};
	end
end
 
function pause.onExitLevel()
	pause.Music.BlankGraphic = false
	pause.Music.ManualTitle = nil
	pause.Music.ManualArtist = nil
	pause.Music.ManualAlbum = nil
end

return pause;