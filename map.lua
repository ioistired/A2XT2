local map3d = API.load("map3d");
map3d.HUDMode = map3d.HUD_NONE;

local vectr = API.load("vectr");

local settings = API.load("a2xt_settings");
local leveldata = API.load("a2xt_leveldata");
local pause = API.load("a2xt_pause");
local democounter = API.load("a2xt_democounter");
local hud = API.load("a2xt_hud");

API.load("a2xt_cheats")

local vert_default = Misc.resolveFile("map3d/standard.vert");
local frag_blur = Misc.resolveFile("shaders/blur_pixel.frag");
local shader_blur;
local buffer = Graphics.CaptureBuffer(800,600);

Audio.sounds[28].muted = true;

local currentMusic = "music/A2XT Dusk Sky.ogg";



function onStart()
	windowDebug(tostring(mem(0xB25724, FIELD_STRING)))
	windowDebug(tostring(mem(0xB25728, FIELD_BOOL)))

	-- If the hub is unlocked, go there at the start of the game
	if  fileWasJustLoaded  and  SaveData.world10 ~= nil  then
		if  SaveData.world10.unlocked  then
			leveldata.loadLevel("hub.lvl",1)
		end
	end

	if  SaveData.changeSubmap ~= nil  then
		-- go to the corresponding SOW level tile
		SaveData.changeSubmap = nil
	end

	Misc.saveGame();
	
	Audio.MusicStop();
	Audio.SeizeStream(-1);
	Audio.MusicOpen(currentMusic);
	Audio.MusicPlay();
	
	shader_blur = Shader();
	shader_blur:compileFromFile(vert_default, frag_blur);
end

local tranTimer = 0;
local maxTimer = 0;
local fadeTime = 1.5;

local lastOkPress = false;

local function getLevelObj()
	if(world.levelObj and math.abs(world.levelObj.y-world.playerY) < 8) then
		return world.levelObj;
	else
		return nil;
	end
end

function onInputUpdate()
	if(mem(0x00B250E2, FIELD_BOOL) or Misc.isPausedByLua()) then
		lastOkPress = true;
		return;
	end
	local obj = getLevelObj();
	if(player.jumpKeyPressing) then
		player.jumpKeyPressing = false;
		if(obj and not lastOkPress and not world.playerIsCurrentWalking) then
			tranTimer = lunatime.toTicks(fadeTime);
			maxTimer = tranTimer;
			Audio.MusicStopFadeOut(fadeTime*1000);
			Audio.SfxPlayCh(-1, Audio.sounds[28].sfx, 0);
		end
		lastOkPress = true;
	else
		lastOkPress = false;
	end
	if(tranTimer > 0) then
		lastOkPress = true;
		if(tranTimer == 1) then
			leveldata.applyFilters(obj.filename);
			player.jumpKeyPressing = true;
		end
		player.leftKeyPressing = false;
		player.rightKeyPressing = false;
		player.upKeyPressing = false;
		player.downKeyPressing = false;
	end
end

function onTick()
	if(tranTimer > 0) then
		tranTimer = tranTimer - 1;
	elseif(not Audio.MusicIsPlaying()) then
		Audio.MusicPlay();
	end
end

function onDraw()
	if(tranTimer > 0) then
		buffer:captureAt(0);
		Graphics.glDraw{
			vertexCoords = {0,0,800,0,800,600,0,600},
			textureCoords = {0,0,1,0,1,1,0,1},
			primitive = Graphics.GL_TRIANGLE_FAN,
			texture = buffer, 
			priority=0.1,
			shader = shader_blur,
			uniforms =
			{
				iResolution = {800,600,0},
				scale = vectr.lerp(32, 1, tranTimer/maxTimer),
				t = tranTimer/maxTimer
			}
		}
	end
end