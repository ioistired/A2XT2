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

	local isNpc = object.ai1 ~= nil
	local isPlayer = type(object) == "Player"
	local isActor = not isNpc  and  not isPlayer

	while (frames < 65)  do
		local initX = object.xMid  or  object.x + 0.5*object.width
		local initY = object.top  or  object.y
		if  isActor  then
			initX = object.x
			initY = object.top
		end

		local hopY = 4*math.sin(0.4*(math.min(frames, 10) - 2))

		local cam = cman.playerCam[1]
		if  cam ~= nil  then
			posX,posY = cam:SceneToScreenPoint (initX,initY)
			posX = posX - 24 
			posY = posY - 48 - hopY
			Graphics.drawImageWP (image, posX,posY, (4*frames)/65, depth)

		else
			posX = initX - 24
			posY = initY - 48 - hopY
			Graphics.drawImageToSceneWP (image, posX,posY, (4*frames)/65, depth)
		end

		--Text.dialog(posX,posY," ",initX,initY)

		frames = frames + 1
		eventu.waitFrames (0)
	end
end

local function popup (image, object, depth)
	prop_img = image
	prop_obj = object
	prop_depth = depth  or  2
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
			popup (images.blank, object, 2)
			popup (images[key], object, 2.05)
		end
	end
end



return emote
