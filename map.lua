local map3d = API.load("map3d");
map3d.HUDMode = map3d.HUD_NONE;

local vectr = API.load("vectr");

local settings = API.load("a2xt_settings");
local leveldata = API.load("a2xt_leveldata");
local music = API.load("a2xt_music");
local democounter = API.load("a2xt_democounter");
local hud = API.load("a2xt_hud");

local vert_default = Misc.resolveFile("map3d/standard.vert");
local frag_blur = Misc.resolveFile("shaders/blur.frag");
local shader_blur;
local buffer = Graphics.CaptureBuffer(800,600);

Audio.sounds[28].muted = true;

local currentMusic = "music/A2XT Dusk Sky.ogg";

function onStart()
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

function onInputUpdate()
	if(mem(0x00B250E2, FIELD_BOOL) or Misc.isPausedByLua()) then
		lastOkPress = true;
		return;
	end
	if(player.jumpKeyPressing) then
		player.jumpKeyPressing = false;
		if(world.levelObj and not lastOkPress and not world.playerIsCurrentWalking) then
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
			leveldata.applyFilters(world.levelObj.filename);
			player.jumpKeyPressing = true;
			savedata.onEnterLevel(world.levelObj.filename);
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