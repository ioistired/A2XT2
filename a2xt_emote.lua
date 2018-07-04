-- emote.lua
-- v1.0

local emote = {}
local cman = API.load ("cameraman")
local eventu = API.load ("eventu")


local imageFolderPath = "../graphics/emote"
local imageFiles = Misc.listLocalFiles(imageFolderPath)
local images = {}
images.blank = Graphics.loadImage (Misc.resolveFile(imageFolderPath.."/blank.png"))


-- Base coroutine function
local prop_img, prop_obj, prop_depth

local function cor_popup ()
	local image = prop_img
	local object = prop_obj
	local depth = prop_depth
	local frames = 0
	
	while (frames < 65)  do
		local posX,posY = object.x - 24 + object.width*0.5, object.y - 48 - 4*math.sin(0.4*(math.min(frames, 10) - 2))
		local cam = cman.playerCam[1]
		if  cam ~= nil  then
			posX,posY = cam:SceneToScreenPoint (posX,posY)
			posX = posX+images.blank.height*0.5
			posY = posY+images.blank.height*0.5
			Graphics.drawImageWP (image, posX,posY, (4*frames)/65, depth)

		else
			Graphics.drawImageToSceneWP (image, posX,posY, (4*frames)/65, depth)
		end

		frames = frames + 1
		eventu.waitFrames (0)
	end
end

local function popup (image, object, depth)
	prop_img = image
	prop_obj = object
	prop_depth = depth  or  0.5
	eventu.run (cor_popup)
end


-- Automate the image loading and function creation
function emote.blank (object)
	popup (images.blank, object)
end

for __,value in pairs (imageFiles) do

	-- Ignore blank
	local key = string.gsub(value, ".png", "")
	if  key ~= "blank"  then

		images[key] = Graphics.loadImage (Misc.resolveFile(imageFolderPath.."/"..value))
		emote[key] = function (object)
			popup (images.blank, object, 0.5)
			popup (images[key], object, 0.55)
		end
	end
end



return emote
