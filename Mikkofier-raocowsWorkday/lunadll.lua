local switchData = Data(Data.DATA_LEVEL, "activeSwitches")

local isSwitchYellowActive = false
local isSwitchBlueActive = false
local isSwitchGreenActive = false
local isSwitchRedActive = false

local hasSwitchYellowActivated = false
local hasSwitchBlueActivated = false
local hasSwitchGreenActivated = false
local hasSwitchRedActivated = false

multipoints = loadAPI("multipoints");
 
multipoints.addLuaCheckpoint(-99936, -100094, 5);
multipoints.addLuaCheckpoint(-59680, -60097, 7);
multipoints.addLuaCheckpoint(-79554, -80159, 6);

function onLoop()
	Text.print("Yellow:"..tostring(isSwitchYellowActive),0,0)
	Text.print("Blue:"..tostring(isSwitchBlueActive),0,20)
	Text.print("Green:"..tostring(isSwitchGreenActive),0,40)
	Text.print("Red:"..tostring(isSwitchRedActive),0,60)
	
	if (isSwitchYellowActive and not hasSwitchYellowActivated) then
		triggerEvent("hahaa! 2")
		hasSwitchYellowActivated = true 
	end
	
	if (isSwitchBlueActive and not hasSwitchBlueActivated) then
		triggerEvent("switch4 2")
		hasSwitchBlueActivated = true 
	end
	
	if (isSwitchGreenActive and not hasSwitchGreenActivated) then
		triggerEvent("switch2 2")
		hasSwitchGreenActivated = true 
	end
	
	if (isSwitchRedActive and not hasSwitchRedActivated) then
		triggerEvent("switch3 2")
		hasSwitchRedActivated = true 
	end
end

function onLoad()
	if player.isValid then
	player:mem(0xF0, FIELD_WORD, 4)
end
	initialiseSwitchData("switchYellow")
	initialiseSwitchData("switchBlue")
	initialiseSwitchData("switchGreen")
	initialiseSwitchData("switchRed")
	
	isSwitchYellowActive = (switchData:get("switchYellow") == "true")
	isSwitchBlueActive = (switchData:get("switchBlue") == "true")
	isSwitchGreenActive = (switchData:get("switchGreen") == "true")
	isSwitchRedActive = (switchData:get("switchRed") == "true")
	
	hasSwitchYellowActivated = not isSwitchYellowActive
	hasSwitchBlueActivated = not isSwitchBlueActive
	hasSwitchGreenActivated = not isSwitchGreenActive
	hasSwitchRedActivated = not isSwitchRedActive
end

function onEvent(eventName)
	if (eventName == "hahaa!") then
		isSwitchYellowActive = not isSwitchYellowActive
		switchData:set("switchYellow", tostring(isSwitchYellowActive))
		switchData:save()
	end
	
	if (eventName == "switch4") then
		isSwitchBlueActive = not isSwitchBlueActive
		switchData:set("switchBlue", tostring(isSwitchBlueActive))
		switchData:save()
	end
	
	if (eventName == "switch2") then
		isSwitchGreenActive = not isSwitchGreenActive
		switchData:set("switchGreen", tostring(isSwitchGreenActive))
		switchData:save()
	end
	
	if (eventName == "switch3") then
		isSwitchRedActive = not isSwitchRedActive
		switchData:set("switchRed", tostring(isSwitchRedActive))
		switchData:save()
	end
end

function initialiseSwitchData(switchIndex)
	if switchData:get(switchIndex) == "" then
		switchData:set(switchIndex, "false")
		switchData:save()
	end
end