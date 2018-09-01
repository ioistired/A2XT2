local map3d = API.load("map3d");
local vectr = API.load("vectr");

map3d.HUDMode = map3d.HUD_NONE;
map3d.Skybox = Graphics.loadImage(Misc.resolveFile("graphics/extra/skybox.png"));
map3d.Light.direction = vectr.forward3:rotate(65,-35, 0);


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

local currentWorld = 0
local currentMusic = "music/ow-a2xt-grass.ogg";
local worldMusic = {
	 [0]="ow-a2xt-grass.ogg",
	 [1]="a2xt-dusksky.ogg",
	 [2]="ow-a2xt-snow.ogg",
	 [3]="ow-a2xt-desert.ogg",
	 [4]="ow-a2xt-mountain.ogg",
	 [5]="ow-asmt-beach.ogg",
	 [6]="ow-a2xt-dmv.ogg",
	 [7]="caw-ow-steampunk.ogg",
	 [8]="asmt-space.ogg",
	 [9]="ow-a2xt-overbaked.ogg",
	[10]="caw-add.ogg"
}



function onStart()
	SaveData.introDone = true; --May need to move this if we go somewhere else before the world map - adds the "exit to map" option to the pause menu

	Misc.saveGame();

	Audio.MusicStop();
	Audio.SeizeStream(-1);
	Audio.MusicOpen(currentMusic);
	Audio.MusicPlay();

	shader_blur = Shader();
	shader_blur:compileFromFile(vert_default, frag_blur);
	
	if(player.character == CHARACTER_UNCLEBROADSWORD) then
		player:transform(CHARACTER_DEMO);
	end
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
	if  (obj)  then
		local lvlData = leveldata.GetData(obj.filename)
		if  lvlData  then
			if  currentWorld ~= lvlData.world  then
				currentWorld = lvlData.world
				Audio.MusicOpen("music/"..worldMusic[currentWorld])
				Audio.MusicPlay()
			end
		end
	end
	
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
	player.jumpKeyPressing = false;
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