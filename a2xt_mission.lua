local textblox = API.load("textblox")
local eventu = API.load("eventu")

local mission = {}

function mission.onInitAPI()
	registerEvent(mission, "onStart", "onStart", true)
end

-- Notes:
--    When scripting quests, only use these functions/modules: mission.Progress, mission.Define, mission.Sounds.Play().  The API handles everything else for you.
--    Sidequests only need their own APIs in the QUESTS folder when they involve levels/towns besides the ones they start in.


--********************************************************************
--* Utility functions                                                *
--********************************************************************
function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function argCheck (args, props)

	local errorStr = "The following required arguments are missing: "
	local shouldError = false

	for  k,v in pairs (args) do
		if  props[v] == nil  then
			if shouldError == true  then
				errorStr = errorStr..", "
			end
			errorStr = errorStr..k
			shouldError = true
		end
	end

	if  shouldError  then
		error (errorStr)
	end
end


--********************************************************************
--* Initialize miscellaneous objects and variables                   *
--********************************************************************
local questsActive = {}

mission.state = {
	OPEN = 0,
	STARTED = 1,
	CLEARED = 2,
}


--********************************************************************
--* Quest data                                                       *
--********************************************************************
local dataObj = Data (Data.DATA_GLOBAL, "sidequests", true)
mission.Data = {}
mission.Data.obj = dataObj
mission.Data.quests = dataObj:get()
mission.Data.questsParsed = {}
local function questIsParsed (quest)
	return mission.Data.questsParsed[quest] ~= nil
end
mission.Data.Get = function (quest)
	if  questIsParsed(quest) == false  then
		local tableStr = mission.Data.quests[quest]
		if  tableStr ~= nil  then
			mission.Data.questsParsed[quest] = loadstring("return "..tableStr)()
		else
			return nil;
		end
	end
	return mission.Data.questsParsed[quest]
end
mission.Data.Save = function (quest)
	-- If quest isn't parsed, the data was never accessed and there is no need to save
	if  questIsParsed(quest)  then
		mission.Data.quests[quest] = table.tostring (mission.Data.questsParsed[quest])
		mission.Data.obj:set (quest, mission.Data.quests[quest])
		mission.Data.obj:save ()
	end
end
--[[
mission.Data.Set = function (quest, key, value, save)
	local questRef = mission.Data.Get (quest)
	questRef[key] = value
	
	if  save == true  then
		mission.Data.Save (quest)
	end
end
]]


--********************************************************************
--* Sound effects                                                    *
--********************************************************************
mission.Sounds = {
                  paths = {
                           arps = {"ding1.ogg","ding2.ogg","ding3.ogg","ding4.ogg","ding5.ogg","ding6.ogg","dingfinal.ogg"},
                           ping = "clear.ogg",
                           clear = "clear.ogg",
                           endQuest = "clear.ogg",
                           bad = "bad.ogg"
                          },
                  arps = {}
                 }
for k,v in pairs (mission.Sounds.paths) do
	if type(v) ~= "table"  then
		mission.Sounds[k] = Audio.SfxOpen(Misc.resolveFile("QUESTS/"..v))
	end
end
for k,v in pairs (mission.Sounds.paths.arps) do
	mission.Sounds.arps[k] = Audio.SfxOpen(Misc.resolveFile("QUESTS/"..v))
end


mission.Sounds.Play = function (sound)
	if  sound ~= nil  then
		Audio.SfxPlayObj (sound, 0)
	end
end



--********************************************************************
--* Notifications                                                    *
--********************************************************************
local ping_props = {}

local function newPingBlock (args)
	local props = {}
	for  k,v in pairs (ping_props)  do
		props[k] = v
	end
	props.font = props.font or textblox.defaultSpritefont[4][1]
	props.textScale = 2
	props.bind = textblox.BIND_SCREEN
	props.width = args.boxW
	props.height = args.boxH
	--props.textOffX = props.textOffX or 4
	--props.textOffY = props.textOffY or 8
	props.boxAnchorX = textblox.ALIGN_MID
	props.boxAnchorY = textblox.ALIGN_MID
	props.textAnchorX = props.textAnchorX or textblox.ALIGN_MID
	props.textAnchorY = props.textAnchorY or textblox.ALIGN_MID


	local msgBlock = textblox.Block (400, args.boxY, args.message, props)
	msgBlock:finish ()

	return msgBlock;
end
local function cor_ping (args)
	local sound = args.sound
	local cam = Camera.get()[1]
	local boxY = 150

	--if  player.y < cam.y + cam.height*0.5  then
	--	boxY = 450
	--end


	-- Initialize block
	local msgBlock = newPingBlock (args)
	msgBlock.visible = true
	msgBlock.x = msgBlock.width*-0.5
	msgBlock.y = boxY

	-- Slide on-screen
	mission.Sounds.Play (args.sound)
	while (msgBlock.x ~= 400)  do
		msgBlock.x = msgBlock.x + math.ceil(0.125*(400-msgBlock.x))
		eventu.waitFrames(0)
	end

	-- Stay on screen
	eventu.waitSeconds(args.seconds  or  3)

	-- Slide off
	local camObj = Camera.get()[1]
	local destX = 800+msgBlock.width*0.5
	local spd = 1
	while (msgBlock.x < destX)  do
		msgBlock.x = msgBlock.x + spd
		spd = spd*1.125
		eventu.waitFrames(0)
	end

	-- Clean up
	msgBlock:closeSelf()

	-- Signal
	eventu.signal("pingDone")
end
mission.Ping = {props = ping_props}


mission.Ping.Generic = function (args)
	-- ARGUMENTS:
	--    message       (string):                  The text to display with the ping
	--    boxW and boxH (int):                     The width and heaight of the ping box in pixels
	--    sound         (index of mission.Sounds): Sound effect to play with the ping

	eventu.run (cor_ping, args)
end

mission.Ping.NewTask = function (text)
	-- ARGUMENTS:
	-- text (string) = new task string

	mission.Ping.Generic {message = "<color 0xFFFF00FF>NEW TASK: <br><color 0xFFCCFFFF><i>"..text.."</i>",
	                      sound   = mission.Sounds.ping,
	                      boxW    = 500,
	                      boxH    = 100}
end
mission.Ping.ClearTask = function (task, infotext)
	-- PROPERTIES:
	-- task (index) = task index
	-- infotext (string) = additional instructions for the player

	local pingprops = {}

	local taskName = task  or  "-unspecified task-"
	local info = infotext
	local msg = "<color 0xFFCCFFFF><i>"..taskName.."<br></i><color 0xFFFF00FF>TASK COMPLETE!"
	if  infotext ~= nil  then
		msg = msg.."<br><br><color 0xFFFFFFFF>"..info
	end

	mission.Ping.Generic {message = msg,
	                      sound   = mission.Sounds.ping,
	                      boxW    = 500,
	                      boxH    = 100}
end
mission.Ping.NewQuest = function (name)
	mission.Ping.Generic {message = "<color 0xFFFF00FF>NEW QUEST:<br><br><color 0xFFCCFFFF><i>"..name,
	                      sound   = mission.Sounds.ping,
	                      boxW    = 500,
	                      boxH    = 100}
end
mission.Ping.QuestStart = function (name)
	mission.Ping.Generic {message = "<color 0xFFFF00FF>BEGIN QUEST:<br><br><color 0xFFCCFFFF><i>"..name,
	                      sound   = mission.Sounds.ping,
	                      boxW    = 500,
	                      boxH    = 100}
end
mission.Ping.QuestOver = function (name, reward)
	reward = reward  or  "-unspecified-"

	mission.Ping.Generic {message = "<color 0xFFFF00FF>QUEST COMPLETE:<br><br><color 0xFFCCFFFF><i>"..name.."<br><br><color 0xFFFFFFFF>Reward: "..reward,
	                      sound   = mission.Sounds.endQuest,
	                      boxW    = 300,
	                      boxH    = 200}
end



--********************************************************************
--* Updating quests                                                  *
--********************************************************************
mission.Progress = {}

mission.Progress.GetTask = function (quest, index)
	local questData = mission.Data.Get (quest)
	if  questData ~= nil  then
		return questData.tasks[index], questData.tasksDone[index]
	else
		return nil, nil;
	end
end
mission.Progress.CompleteTask = function (props)
	-- PROPERTIES:
	-- quest (string): quest key
	-- task (whole number): task index
	
	-- Check for missing required arguments
	argCheck ({"quest", "task"}, props)
	
	-- Get data
	local questData = mission.Data.Get (props.quest)
	local taskName = questData.tasks[props.task]
	local info = props.info


	-- Set data
	if  questData.tasksDone == nil  then
		questData.tasksDone = {}
	end
	questData.tasksDone[props.task] = true
	mission.Data.Save (props.quest)

	-- Trigger notification
	mission.Ping.ClearTask (taskName, info)

	-- If there are new tasks
end
mission.Progress.State = function (quest)
	-- Get data
	local questData = mission.Data.Get (quest)

	if  questData ~= nil  then
		return questData.state
	else
		return nil
	end
end
mission.Progress.Start = function (quest)
	-- Get data
	local questData = mission.Data.Get (quest)

	-- Set data
	questData.state = mission.state.STARTED
	mission.Data.Save (quest)

	-- Trigger the notification
	mission.Ping.QuestStart (questData.name)
end
mission.Progress.End = function (quest)
	-- Get data
	local questData = mission.Data.Get (quest)
	
	questData.state = mission.state.CLEARED
	mission.Data.Save (quest)
	
	-- Trigger notification
	mission.Ping.QuestOver (questData.name, questData.reward)
end
mission.Progress.Reset = function (quest)
	-- Get the props the quest was initialized with
	local questData = mission.Data.Get (quest)
	local initProps = questData.initProps
	questData = nil

	-- Reset the "was parsed" flag
	mission.Data.questsParsed[quest] = nil

	-- Re-initialize the quest
	mission.Define.Quest(initProps)
end



--********************************************************************
--* Quest definition                                                 *
--********************************************************************

mission.Define = {}

function mission.Define.Task (props)
	-- ARGUMENTS:
	-- quest (string): The quest key
	-- task  (string): The task text
	-- id    (int):    The task's index in the task list (if undefined, will be placed at the end
	-- ping  (bool):   Unless false, makes a "New Task" popup will appear

	argCheck ({"quest", "task"}, props)

	-- Get data
	local questData = mission.Data.Get (props.quest)

	-- If the quest exists, proceed to add the task
	if  questData ~= nil  then
		local taskList = questData.tasks
		local doneList = questData.tasksDone
		local newId = props.id  or  #taskList+1

		taskList[newId] = props.task
		doneList[newId] = false
		mission.Data.Save (props.quest)

		-- Ping unless specified otherwise
		if  props.ping ~= false  then
			mission.Ping.NewTask (props.task)
		end

		-- Return
		return newId

	else
		return nil
	end
end
function mission.Define.Quest (props)
	-- ARGUMENTS:
	-- key (string): The key the quest data will be indexed under
	-- info (string): A short blurb summarizing the quest
	-- tasks (table of strings): The individual tasks that make up the quest
	-- reward (string): The reward text listed (not the actual items)

	argCheck ({"key", "tasks"}, props)

	local key = props.key
	local name = props.name  or  "-Unnamed-"
	local info = props.info  or  "-No info given-"
	local reward = props.reward  or  "???"
	local tasks = props.tasks

	-- If there is already data for it, don't continue
	if  questIsParsed (key) == false  then

		-- Create the data
		local done = {}
		for  k,v in pairs (tasks) do
			done[k] = false
		end

		mission.Data.questsParsed [key] = {name=name, info=info, reward=reward, tasks=tasks, initProps=props, tasksDone=done, state=mission.state.OPEN}
		mission.Data.Save (key)

		-- Trigger the notification
		mission.Ping.NewQuest (name)
	end
end




--********************************************************************
--* Load active quests                                               *
--*                                                                  *
--********************************************************************

function mission.onStart ()
	for  k,v  in pairs (mission.Data.quests)  do
		local questInfo = mission.Data.Get (k)
		local path = "QUESTS/"..k..".lua"

		if  questInfo.state == mission.state.STARTED  then
			if  Misc.resolveFile(path) ~= nil  then
				--windowDebug (k.." api loaded")
				table.insert (questsActive, API.load("..\\QUESTS\\"..k))
			else
				--windowDebug ("no api for "..k.." detected")
			end
		else
			--windowDebug (k.." detected but not started")
		end
	end
end


return mission