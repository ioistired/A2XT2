local eventu = API.load("eventu");

local music = {}

local musichud = Graphics.loadImage(Misc.resolveFile("graphics/HUD/musichud.png"));
local blankmusichud = Graphics.loadImage(Misc.resolveGraphicsFile("graphics/HUD/blankmusichud.png"));
local showmusic = false
local musicwait = false

music.BlankGraphic = false
music.Title = nil;
music.Artist = nil;
music.Album = nil;
 
local function hidecredits()
        musicwait = false
        showmusic = false
end

function music.onInitAPI()
	registerEvent(music, "onInputUpdate", "onInputUpdate", false);
	registerEvent(music, "onExitLevel", "onExitLevel", false);
	registerEvent(music, "onDraw", "onDraw", false);
end

function music.onInputUpdate()
	local prepareMusic = false;
    local musiccheatcode = Misc.cheatBuffer()
    local musiccheat = string.find(musiccheatcode, "music", 1)
	
	if(mem(0x00B250E2, FIELD_BOOL) and tostring(mem(0xB250E4, FIELD_STRING)) == "") then --pause menu (check for empty message string to avoid displaying this on message boxes)
		showmusic = true;
	elseif (musiccheat ~= 0 and musiccheat ~= nil) then --music code
        prepareMusic = true
        Misc.cheatBuffer("")
    elseif(showmusic and not musicwait) then
		showmusic = false;
	end
	
	if (prepareMusic and not musicwait) then
        musicwait = true;
		showmusic = true;
        eventu.setTimer(5, hidecredits, false);
   end
end

function music.onDraw()
	local y = 500;

	if (showmusic) then
        if (music.BlankGraphic) then
			Graphics.drawImage(blankmusichud,0,y);
		else
			Graphics.drawImage(musichud,0,y);
		end
           
		y = y + 15; 
		 
		if (music.Title == nil) then
            Text.print(Audio.MusicTitleTag(),50,y)
		else
            Text.print(music.Title,50,y)
		end
		if (music.Title == nil) then
            Text.print(Audio.MusicArtistTag(),50,y+25)
		else
            Text.print(music.Artist,50,y+25)
		end
		if (music.Album == nil) then
            Text.print(Audio.MusicAlbumTag(),50,y+50)
		else
            Text.print(music.Album,50,y+50)
		end
	end
end
 
function music.onExitLevel()
	music.BlankGraphic = false
	music.ManualTitle = nil
	music.ManualArtist = nil
	music.ManualAlbum = nil
end

return music;