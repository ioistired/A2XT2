local minigame = {}

local pause;
local eventu = API.load("eventu")

minigame.inGame = false;
minigame.state = nil;

local currentRoutine = nil;

local playerState = {}

local function resetPause()
	if(pause == nil) then
		pause = API.load("a2xt_pause")	--this has to go here to avoid circular dependency
	end
	pause.resetPauseMenu();
end

function minigame.start(routine, initialState)
	if(currentRoutine ~= nil) then
		minigame.exit();
	end
	
	playerState.powerup = player.powerup;
	playerState.reservePowerup = player.reservePowerup;
	playerState.hp = player:mem(0x16, FIELD_WORD);
	playerState.mountType = player:mem(0x108, FIELD_WORD);
	playerState.mountColour = player:mem(0x10A, FIELD_WORD);
	
		
	minigame.inGame = true;
	minigame.state = initialState or {};
	_,currentRoutine = eventu.run(routine, minigame.state);
	
	resetPause()
end

function minigame.exit()
	minigame.inGame = false;
	
	if(currentRoutine ~= nil) then
		eventu.abort(currentRoutine)
		currentRoutine = nil;
		
		minigame.onEnd(minigame.state);
	end
	minigame.state = nil;
	
	resetPause()
end

function minigame.restorePlayerState()
	if(playerState.powerup ~= nil) then
		player.powerup = playerState.powerup;
		player.reservePowerup = playerState.reservePowerup;
		player:mem(0x16, FIELD_WORD, playerState.hp);
		player:mem(0x108, FIELD_WORD, playerState.mountType);
		player:mem(0x10A, FIELD_WORD, playerState.mountColour);
	end
end

function minigame.onInitAPI()
	registerCustomEvent(minigame, "onEnd");
end

return minigame;