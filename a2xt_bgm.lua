local eventu = API.load("eventu")

local leveldata = API.load("a2xt_leveldata")
local message = API.load("a2xt_message")
local scene = API.load("a2xt_scene")
local archives = API.load("a2xt_archives")


local bgm = {}
bgm.songsOrder = {
--[[
"a2mt-anothercastle.spc",
"a2mt-anothermansion.ogg",
"a2mt-ballroom.ogg",
"a2mt-beach.spc",
"a2mt-beachtheme.ogg",
"a2mt-boo.ogg",
"a2mt-castle.spc",
"a2mt-challenge.spc",
"a2mt-citadel.ogg",
"a2mt-future.spc",
"a2mt-ghost.spc",
"a2mt-jungle.spc",
"a2mt-mansion.ogg",
"a2mt-musicidea.ogg",
"a2mt-night.ogg",
"a2mt-possiblesnow.ogg",
"a2mt-rock.spc",
"a2mt-sewers.spc",
"a2mt-sky.ogg",
"a2mt-sometheme.spc",
"a2mt-something.ogg",
"a2mt-something.spc",
"a2mt-swamp.ogg",
"a2mt-title.ogg",
"a2mt-troubledforest.ogg",
"a2mt-volcano.ogg",
"a2mt-water.spc",
"a2mt-whatisthis.ogg",
"a2mt-whispers.ogg",
]]--
{"a2xt-spacefights.ogg", "Space Fights", 0},
{"a2xt-alliumampeloprasum.ogg", "Allium Ampeloprasum", 1},
{"a2xt-aurevoir.ogg", "Au Revoir, Mes Anges", 9},
{"a2xt-aurevoir2.ogg", "*Au Revoir Intensifies*", 9},
"a2xt-blood.ogg",
"a2xt-bonkers.ogg",
"a2xt-boss1.ogg",
"a2xt-boss2.ogg",
"a2xt-boss3.ogg",
"a2xt-boss4.ogg",
"a2xt-boss5.ogg",
"a2xt-boss6.ogg",
"a2xt-boss7.ogg",
"a2xt-boss8.ogg",
"a2xt-broadsword.ogg",
"a2xt-rewind.ogg",
"a2xt-castle.ogg",
"a2xt-chronotons.ogg",
"a2xt-diner.ogg",
"a2xt-dog.ogg",
"a2xt-dog2.ogg",
"a2xt-dragon.ogg",
"a2xt-dusksky.ogg",
"a2xt-finallevel.ogg",
"a2xt-grass.ogg",
"a2xt-hub.ogg",
"a2xt-justbethere.ogg",
"a2xt-midboss3.ogg",
"a2xt-panic.ogg",
"a2xt-pendulum.ogg",
"a2xt-relay.ogg",
"a2xt-rumble.ogg",
"a2xt-sapphire.nsfe",
"a2xt-shop-lively.ogg",
"a2xt-shop-mishi.ogg",
"a2xt-shop-modest.ogg",
"a2xt-shop-pleasant.ogg",
"a2xt-shop-trendy.ogg",
"a2xt-smokingisbadforyou.ogg",
"a2xt-strategytime.ogg",
"a2xt-tensehub.ogg",
"a2xt-ultpanda.ogg",
"a2xt-w7castle.ogg",
"a2xt-wandering.nsfe",
--[[
"asmt-cloud9.ogg",
"asmt-clouds.ogg",
"asmt-forest.ogg",
"asmt-grassland.spc",
"asmt-herewego.spc",
"asmt-ice.ogg",
"asmt-ievan.spc",
"asmt-imperial.spc",
"asmt-kurokimono.spc",
"asmt-kuroremix.ogg",
"asmt-space.ogg",
"asmt-stuff.ogg",
"asmt-underground.ogg",
"asmt-void.spc",
"asmt-volcano.spc",
"caw-add.ogg",
"caw-gentlemen.ogg",
"caw-ow-steampunk.ogg",
"chrom1im-8bit.ogg",
"chrom1um-winter.ogg",
"demodance.ogg",
"ow-a2mt-forestremix.ogg",
"ow-a2mt-mountian.ogg",
"ow-a2mt-overworld.spc",
"ow-a2mt-ow2.ogg",
"ow-a2mt-pharoh.ogg",
"ow-a2mt-snow.spc",
"ow-a2mt-winter.ogg",
]]--
"ow-a2xt-blood.ogg",
"ow-a2xt-dmv.ogg",
"ow-a2xt-forest.ogg",
"ow-a2xt-minstrel.ogg",
"ow-a2xt-mountain.ogg",
"ow-a2xt-overbaked.ogg",
"ow-a2xt-vicar.ogg",
--[[
"ow-asmt-beach.ogg",
"ow-asmt-desert.spc",
"ow-chrom1um-snestime.ogg",
]]--
"popipo.ogg",
"smb3-switch.ogg",
"smw-switch.ogg"
}

if  (SaveData.bgmHeard == nil)  then
	SaveData.bgmHeard = {}
end


--TODO: Replace this with a proper constant
local CURRENT_WORLD = 0;


message.presetSequences.jukeboxNormal = function(args)
	local talker = args.npc

	message.promptChosen = false
	message.showMessageBox {target=talker, text="Change the music?", type="system", closeWith="prompt"}
	message.waitMessageDone();

	-- Set up prompt
	local songs = {}--table.clone(bgm.songsOrder)
	local optionTable = {}
	
	for _,v in ipairs(bgm.songsOrder) do
		if(type(v) ~= "table") then
			table.insert(optionTable, v)
			table.insert(songs, v)
		elseif(v[3] == nil or v[3] <= CURRENT_WORLD) then
			table.insert(optionTable, v[2])
			table.insert(songs, v)
		end
	end
	--[[
	for  i=#songs,1,-1  do
		if  SaveData.bgmHeard[songs[i] ] == nil  then
			songs[i] = nil
		end
	end
	--]]
	
	table.insert(optionTable, "Silence")
	table.insert(optionTable, "Reset")
	table.insert(optionTable, message.getCancelOption())


	-- Begin prompt loop
	local loopBroken = false
	local currentPage = 1

	while  (not loopBroken)  do

		-- Call prompt
		message.promptChosen = false
		message.showPrompt{options=optionTable, optionsShown=8, sideX=-1}
		message.waitPrompt()


		-- If the player cancelled
		if  message.promptChoice == #optionTable  then
			loopBroken = true

		-- Otherwise, if the player selected reset, change the music back to the current event theme
		elseif  message.promptChoice == #optionTable-1  then
			Audio.SeizeStream(-1)
			Audio.MusicStop()
			Audio.playSFX("../sound/extra/jukebox-stop.ogg")

			eventu.waitSeconds(0.75)
			Audio.playSFX("../sound/extra/jukebox-start.ogg")

			eventu.waitSeconds(1)
			Audio.resetMciSections()


		-- Otherwise, if the player selected silence, stop the music
		elseif  message.promptChoice == #optionTable-2  then
			Audio.SeizeStream(-1)
			Audio.MusicStop()
			Audio.playSFX("../sound/extra/jukebox-stop.ogg")


		-- Otherwise, if the player has chosen a song, play it
		else
			local keyIndex = message.promptChoice
			local key = songs[keyIndex]
			if(type(key) == "table") then
				key = key[1]
			end
			Audio.SeizeStream(-1)
			Audio.MusicStop()
			Audio.playSFX("../sound/extra/jukebox-stop.ogg")

			eventu.waitSeconds(0.75)
			Audio.playSFX("../sound/extra/jukebox-start.ogg")

			eventu.waitSeconds(1)

			Audio.MusicOpen("../music/"..key)
			Audio.MusicPlay()
		end

		-- Yield
		eventu.waitSeconds(0.25)
	end

	message.endMessage();
	scene.endScene();
end


return bgm