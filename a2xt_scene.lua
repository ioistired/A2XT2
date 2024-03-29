local eventu = API.load("eventu")
local imagic = API.load("imagic")
local textblox = API.load("textblox")
local cameraman = API.load("cameraman")
local rng = API.load("rng")

local hud = API.load("a2xt_hud")
--local actors = API.load("a2xt_actor")

local a2xt_scene = {}



function a2xt_scene.onInitAPI()
	registerEvent (a2xt_scene, "onStart", "onStart", true)
	registerEvent (a2xt_scene, "onTick", "onTick", true)
	registerEvent (a2xt_scene, "onInputUpdate", "onInputUpdate", false)
	registerEvent (a2xt_scene, "onDraw", "onDraw", false)
end


--***************************
--** Variables             **
--***************************
local readonly         = {inCutscene=1, isSkipping=1}

a2xt_scene.inCutscene  = false

a2xt_scene.camera      = nil

a2xt_scene.quake       = 0

a2xt_scene.currInputs  = {}
a2xt_scene.prevInputs  = {}

a2xt_scene.subroutines = {}

local tintFadeRoutine  = nil

local currentScene     = nil
local skipRoutine      = nil
local usingActors      = false

local skipHoldRoutine  = nil
local skipIntroRoutine = nil
local letterboxRoutine = nil

local lockJump = false;

-- Drawing
local letterboxTop     = imagic.Box{x=0,y=0,  width=800,height=50,  color=0x00000000, scene=false}
local letterboxBottom  = imagic.Box{x=0,y=600,width=800,height=50,  color=0x00000000, scene=false, align = imagic.ALIGN_BOTTOMLEFT}
local tintBox          = imagic.Box{x=0,y=0,  width=800,height=600, color=0x00000000, scene=false}

local letterboxColor   = 0x000000DD
local letterboxCurrent = {color = 0x00000000}

local skipProps        = {
                          text = "",
                          startText = "Hold [tanooki] to skip.",
                          font = textblox.FONT_SPRITEDEFAULT4X2,
                          x = 20,
                          y = 20,
                          alpha = 0,
                          halign=t_halign,
                          valign=t_valign
                         }

local hud_food = false;
local hud_rc = false;


--***************************
--** Utility Functions     **
--***************************
local function lerp (minVal, maxVal, percentVal)
	return (1-percentVal) * minVal + percentVal*maxVal;
end

-- Color blending
-- https://stackoverflow.com/questions/35189592/lua-color-fading-function#35191214
local function Dec2Hex(nValue) -- http://www.indigorose.com/forums/threads/10192-Convert-Hexadecimal-to-Decimal
	if type(nValue) == "string" then
		nValue = tonumber(nValue);
	end
	nHexVal = string.format("%X", nValue);  -- %X returns uppercase hex, %x gives lowercase letters
	local sHexVal = nHexVal.."";
	if nValue < 16 then
		return "0"..tostring(sHexVal)
	else
		return sHexVal
	end
end
local function fade_RGBA(col1, col2, percent)
	local r1, g1, b1, a1 = string.match (string.format("%08X", col1), "([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])")
	local r2, g2, b2, a2 = string.match (string.format("%08X", col2), "([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])")
	local r3 = tonumber(r1, 16)*(1-percent) + tonumber(r2, 16)*(percent)
	local g3 = tonumber(g1, 16)*(1-percent) + tonumber(g2, 16)*(percent)
	local b3 = tonumber(b1, 16)*(1-percent) + tonumber(b2, 16)*(percent)
	local a3 = tonumber(a1, 16)*(1-percent) + tonumber(a2, 16)*(percent)
	return tonumber(Dec2Hex(r3)..Dec2Hex(g3)..Dec2Hex(b3)..Dec2Hex(a3),16)
end

local function disableGrab()
	-- Disable side grab
	mem(0x009AD622, FIELD_WORD, 0xE990)
	--mem(0x009AD622, FIELD_WORD, 0x850F)
	
	-- Disable top grab
	mem(0x009CC392, FIELD_WORD, 0xE990)
	--mem(0x009CC392, FIELD_WORD, 0x850F)
	
	-- Disable shell side grab
	mem(0x009ADA63, FIELD_WORD, 0x9090)
	--mem(0x009ADA63, FIELD_WORD, 0x1474)
	
	 -- Disable shell top grab
	mem(0x009AC6C4, FIELD_WORD, 0xE990)
	--mem(0x009AC6C4, FIELD_WORD, 0x850F)
	
end

local function enableGrab()
	-- side grab
	mem(0x009AD622, FIELD_WORD, 0x850F)

	-- top grab
	mem(0x009CC392, FIELD_WORD, 0x850F)

	--  shell side grab
	mem(0x009ADA63, FIELD_WORD, 0x1474)

	-- shell top grab
	mem(0x009AC6C4, FIELD_WORD, 0x850F)
end


--***************************
--** Coroutines            **
--***************************
local function cor_lerpProperty(args)
	local timeLimit = args.time or 1
	local timePassed = 0

	local val1 = args.val1  or  args.obj[args.property]
	local val2 = args.val2  or  val1

	while (timePassed < timeLimit)  do
		local percent = timePassed/timeLimit

		args.obj[args.property] = lerp(val1, val2, percent)

		timePassed = timePassed + eventu.deltaTime
		eventu.waitFrames(0,true)
	end
	args.obj[args.property] = val2
end
local function cor_lerpColor(args)
	local timeLimit = args.time or 1
	local timePassed = 0

	local col1 = args.col1  or  args.obj.color
	local col2 = args.col2  or  col1

	while (timePassed < timeLimit)  do
		local percent = timePassed/timeLimit

		args.obj.color = fade_RGBA(col1, col2, percent)

		timePassed = timePassed + eventu.deltaTime
		eventu.waitFrames(0,true)
	end
	args.obj.color = col2
end
local function cor_skipMessage()
	-- Fade in
	skipProps.text = skipProps.startText
	eventu.run(cor_lerpProperty, {obj=skipProps, time=1, property="alpha", val1=0, val2=1})
	eventu.waitSeconds(2,true)

	-- Fade out
	eventu.run(cor_lerpProperty, {obj=skipProps, time=1, property="alpha", val1=1, val2=0})
end
local function cor_letterbox()

	-- Fade in
	Graphics.activateHud(false)
	eventu.run(cor_lerpColor, {obj=letterboxCurrent, time=0.5, col2=letterboxColor})
	eventu.waitSeconds(0.5,true)

	-- Wait until the cutscene has ended
	while (a2xt_scene.inCutscene)  do
		eventu.waitFrames(0,true)
	end

	-- Fade out
	eventu.run(cor_lerpColor, {obj=letterboxCurrent, time=0.5, col2=0x00000000})
	Graphics.activateHud(true)

end

local function cor_skipping()
	skipProps.alpha = 1
	skipProps.text = "Skipping scene... 3."
	eventu.waitSeconds(1,true)
	skipProps.text = "Skipping scene... 2."
	eventu.waitSeconds(1,true)
	skipProps.text = "Skipping scene... 1."
	eventu.waitSeconds(1,true)

	skipProps.text = ""
	eventu.abort(currentScene)
	_,currentScene = eventu.run(skipRoutine)
	skipRoutine = nil
end


--***************************
--** API Member Functions  **
--***************************

-- startScene args:
--    scene:      main cutscene coroutine
--    sceneArgs:  an optional argument to be passed into the eventu.run call for
--                  the cutscene coroutine (can be a table of arguments)
--    skip:       the coroutine called when the player skips the cutscene;
--                  if not specified, the cutscene will be unskippable.
--    interrupt:  if true, will abort the current cutscene coroutine.

function a2xt_scene.startScene(args)
	-- Run this as a coroutine so the cutscene will only start after the previous one
	eventu.run(function()

			-- Built-in delay to wait for the camera to be initialized in order to avoid errors (we really need to fix cameraman's player cam initialization)
			while (a2xt_scene.camera == nil) do
				eventu.waitFrames(0,true)
			end

			-- If there is a cutscene already happening, either
			if  a2xt_scene.inCutscene  then

				-- interrupt it...
				if  args.interrupt  then
					eventu.abort(currentScene)

				-- ...or wait it out.
				else
					while (a2xt_scene.inCutscene) do
						eventu.waitFrames(0,true)
					end
				end
			end

			if(not args.noletterbox) then
				-- Restart the letterbox effect if necessary
				if  letterboxRoutine ~= nil  then  eventu.abort(letterboxRoutine);  end;
				_,letterboxRoutine = eventu.run(cor_letterbox)
			end

			-- Set up skippable stuff
			if  args.skip ~= nil  then
				a2xt_scene.setSkippable(args.skip)
			end

			-- Start the scene itself
			if  args.sceneArgs ~= nil  then
				_, currentScene = eventu.run(args.scene, args.sceneArgs)
			else
				_, currentScene = eventu.run(args.scene)
			end

			eventu.waitFrames(0,true)
		end
	)
end

function a2xt_scene.runSub(funct)
	local _,subr = eventu.run(funct)
	table.insert(a2xt_scene.subroutines, subr)
end

function a2xt_scene.abortSubs()
	for  _,v in ipairs(a2xt_scene.subroutines)  do
		eventu.abort(v)
	end
	a2xt_scene.subroutines = {}
end


-- setupBossScreen args:
--    xOffset:      x offset from the player's position (default 0)
--    yOffset:      y offset from the player's position (default 0)
--    time:         time it takes to transition (default 1)
function a2xt_scene.setupBossScreen(args)
	args = args  or  {}

	a2xt_scene.camera:Reset(args)
	eventu.abort(letterboxRoutine)

	eventu.run(cor_lerpColor, {obj=letterboxCurrent, time=0.5, col2=0x00000000})
	Graphics.activateHud(true)
end

function a2xt_scene.endScene()
	eventu.abort(currentScene)
	enableGrab();
	currentScene = nil
end
function a2xt_scene.setSkippable(routine)
	skipRoutine = routine
	_,skipIntroRoutine = eventu.run(cor_skipMessage)
end


-- setTint args:
--    time:       amount of time it takes to fade (0 for instant, defaults to 0)
--    color:      the color to change to
function a2xt_scene.setTint(params)
	local args = {time=params.time  or  0, obj=tintBox, col2=params.color}
	if  tintFadeRoutine ~= nil  then
		eventu.abort(tintFadeRoutine)
	end
	_, tintFadeRoutine = eventu.run(cor_lerpColor, args)
end


function a2xt_scene.displayFoodHud(show)
	hud_food = show;
end
function a2xt_scene.displayRaocoinHud(show)
	hud_rc = show;
end

--***************************
--** Events                **
--***************************
function a2xt_scene.onStart()
	a2xt_scene.camera = cameraman.playerCam[1]
end


function a2xt_scene.onTick()
	a2xt_scene.camera = cameraman.playerCam[1]

	local wasInCutscene = a2xt_scene.inCutscene;
	a2xt_scene.inCutscene = false
	if  (currentScene ~= nil)  then
		a2xt_scene.inCutscene = true
	elseif(wasInCutscene) then
		lockJump = true;
	end

	if  a2xt_scene.quake ~= nil  then
		if  a2xt_scene.quake > 0  then
			Defines.earthquake = a2xt_scene.quake
		end
	end
end

function a2xt_scene.onDraw()
	-- Draw letterboxing and tint boxes
	letterboxTop:Draw(1,letterboxCurrent.color)
	letterboxBottom:Draw(1,letterboxCurrent.color)
	tintBox:Draw(1,tintBox.color)

	--[[
	Text.print (tostring(currentScene), 20, 100)
	Text.print (tostring(inCutscene), 20, 120)
	Text.print (tostring(not currentScene == nil), 20, 140)
	Text.print (tostring(a2xt_scene.inCutscene), 20, 160)
	Text.print (tostring(a2xt_scene.tint), 20, 180)
	--]]

	-- Draw skip message
	textblox.printExt (skipProps.text, skipProps)
	
	if(hud_food) then
		hud.drawFood(40,20,5);
	end
	if(hud_rc) then
		hud.drawRC(100,30,5);
	end
end

function a2xt_scene.onInputUpdate()
	if(lockJump) then
		if(player.jumpKeyPressing) then
			player.jumpKeyPressing = false;
		else
			lockJump = false;
		end
	end

	if  a2xt_scene.inCutscene and not isGamePaused() then
		-- Override inputs
		for  k,v in pairs{"up","down","left","right","jump","run","altJump","altRun","dropItem","pause"}  do
			a2xt_scene.prevInputs[v] = a2xt_scene.currInputs[v]
			a2xt_scene.currInputs[v] = player[v.."KeyPressing"]
			player[v.."KeyPressing"] = false
		end
		if(player:mem(0x154,FIELD_WORD) == 0 and currentScene) then
			disableGrab();
		end
		player.runKeyPressing = true;

		-- Skipping management
		local wasHoldingTan = a2xt_scene.prevInputs.altRun
		local holdingTan = a2xt_scene.currInputs.altRun

		-- Start skipping
		if  (skipHoldRoutine == nil  and  skipRoutine ~= nil  and  not wasHoldingTan  and  holdingTan)  then
			if  skipIntroRoutine ~= nil  then  eventu.abort(skipIntroRoutine);  end;
			_,skipHoldRoutine = eventu.run(cor_skipping)
		end
		-- Stop skipping
		if  (skipHoldRoutine ~= nil  and  wasHoldingTan  and  not holdingTan)  then
			eventu.abort(skipHoldRoutine)
			skipProps.text = ""
			skipHoldRoutine = nil
		end
	end
end




--***************************
--** Metamethods           **
--***************************
function a2xt_scene.__index(obj,key)
     if (key == "isSkipping") then
		return (skipHoldRoutine ~= nil)

	elseif (key == "tint") then
		return tintBox.color;

	else
		return rawget(obj, key)
	end

end

function a2xt_scene.__newindex(obj,key,val)
	if     (readonly[key] ~= nil) then
		error ("The A2XT scene API's "..key.." property is read-only.");

	elseif (key == "tint") then
		tintBox.color = val;

	else
		rawset(obj, key, val);
	end
end


return a2xt_scene