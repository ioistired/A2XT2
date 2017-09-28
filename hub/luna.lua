local imagic = API.load("imagic")

local leveldata = API.load("a2xt_leveldata")
local message = API.load("a2xt_message")
local scene = API.load("a2xt_scene")
local archives = API.load("a2xt_archives")

local pendSpr = Graphics.loadImage("pendulum.png")
local reflections = Graphics.CaptureBuffer(800,600);


message.presetSequences.MessageTest = function(args)
	local talker = args.npc

	message.showMessageBox {target=talker, text="Testing sign messages.", type="sign"}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing bubble messages."}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing system messages.", type="system"}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing boxless messages.", type="textonly"}
	message.waitMessageEnd();

	message.showMessageBox {target=talker, text="Testing intercom messages.", type="intercom"}
	message.waitMessageEnd();

	message.endMessage();
	scene.endScene();
end


message.presetSequences.archiveChars = function(args)
	local talker = args.npc

	message.promptChosen = false
	message.showMessageBox {target=talker, text="<gt>Accessing character profiles...<pause 0.1>", type="system", closeWith="prompt"}
	message.waitMessageDone();

	-- Set up prompt
	local names,bios = archives.GetUnlockedBios()

	local namePages = {}
	if  #names > 8  then
		for i=1,#names  do
			local pageNum = math.floor(i/8)+1
			if  namePages[pageNum] == nil  then  namePages[pageNum] = {};  end;
			table.insert(namePages[pageNum], names[i])
		end
	else
		namePages = {names}
	end


	-- Begin prompt loop
	local loopBroken = false
	local currentPage = 1

	while  (not loopBroken)  do

		-- Set up page controls and cancel option
		local extraOptions = {}
		local nextNum = -1
		local prevNum = -1
		local cancelNum = -1

		if  #namePages > 1  then
			if  currentPage > 1  then
				extraOptions[#extraOptions+1] = "Previous page"
				prevNum = extraOptions[#extraOptions]
			end
			if  currentPage < #namePages  then
				extraOptions[#extraOptions+1] = "Next page"
				nextNum = extraOptions[#extraOptions]
			end
		end
		extraOptions[#extraOptions+1] = message.getCancelOption()
		cancelNum = extraOptions[#extraOptions]


		-- Call prompt
		local currentNames = namePages[currentPage]

		message.promptChosen = false
		message.showPrompt{options=table.join(currentNames, extraOptions)}
		message.waitPrompt()


		-- If the player has chosen a character name, show the bio
		if  message.promptChoice <= #currentNames  then
			message.showMessageBox{target=talker, text=bios[currentPage[message.promptChoice]], type="system"}
			message.waitMessageEnd()

		-- Otherwise, if the player cancelled
		elseif  message.promptChoice == #currentNames + #extraOptions  then
			loopBroken = true

		-- Otherwise
		else
			local extraNum = message.promptChoice-#currentNames

			-- If the player has chosen next page
			if extraNum == nextNum  then
				currentPage = currentPage+1

			-- If the player has chosen previous page
			elseif  extraNum == prevNum  then
				currentPage = currentPage-1
			end
		end

		-- Yield
		eventu.waitFrames(0)
	end
	names[#names+1] = message.getCancelOption()

	message.endMessage();
	scene.endScene();
end





function onDraw()

	-- Pendulum section
	if  player.section == 0  then

		-- Pendulum
		local pendPercent = math.sin(math.rad(lunatime.tick()))
		imagic.Draw {primitive=imagic.TYPE_BOX, align=imagic.ALIGN_TOP,
		             color=0xFFFFFF00 + 32 + 32*(1-math.abs(pendPercent)),
		             x=-200000+400, y=-200600-150, priority=-95, scene=true,
		             width=pendSpr.width*2, height=pendSpr.height*2, 
		             texture=pendSpr, rotation=55*pendPercent}

		-- Reflection
		reflections:captureAt(-2);
		local cam = Camera.get()[1]
		local reflectY = -200160 - cam.y;
		local th = (reflectY/600);
		local stretchFactor = 1;
		local brightness = 0.1;
		Graphics.glDraw {
		                 vertexCoords = {0,reflectY,800,reflectY,800,600,0,600}, 
		                 textureCoords = {0,th,1,th,1,(th*2-1)*stretchFactor,0,(th*2-1)*stretchFactor}, 
		                 vertexColors = {brightness,brightness,brightness,0, brightness,brightness,brightness,0, 0,0,0,0, 0,0,0,0},
		                 primitive = Graphics.GL_TRIANGLE_FAN, 
		                 texture=reflections, 
		                 priority = -2,
		};
	end
end