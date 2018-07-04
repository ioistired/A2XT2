-- emote.lua
-- v1.0

local emote = {}
local eventu = API.load ("eventu")



-- Base coroutine function
local prop_img, prop_obj

local function cor_popup ()
	local image = prop_img
	local object = prop_obj
	local frames = 0
	
	while (frames < 65)  do
		Graphics.drawImageToSceneWP (image, object.x - 24 + object.width*0.5, object.y - 48 - 8*math.sin(0.4*(math.min(frames, 10) - 2)), (4*frames)/65, 0.5)
		frames = frames + 1
		eventu.waitFrames (0)
	end
end

local function popup (image, object)
	prop_img = image
	prop_obj = object
	eventu.run (cor_popup)
end



-- Automate the image loading and function creation
local imageFolderPath = "../graphics/emote"
local imageFiles = Misc.listLocalFiles(imageFolderPath)
local images = {}
images.blank = Graphics.loadImage (Misc.resolveFile(imageFolderPath.."/blank.png"))
function emote.blank (object)
	popup (images.blank, object)
end

for __,value in pairs (imageFiles) do

	-- Ignore blank
	local key = string.gsub(value, ".png", "")
	if  key ~= "blank"  then

		images[key] = Graphics.loadImage (Misc.resolveFile(imageFolderPath.."/"..value))
		emote[key] = function (object)
			popup (images.blank, object)
			popup (images[key], object)
		end
	end
end



return emote
