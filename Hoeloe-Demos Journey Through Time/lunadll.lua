local spikescounter = 0;
local spikes1;
local spikes1bg;
local spikes2;
local spikes2bg;
local spikes3;
local spikes3bg;

local spikes1speed = 0;
local spikes2speed = 0;

local spikehurts = { a = true, b = true, c = true };



function onLoop()
	--player:mem(0xF0, FIELD_WORD, 1)
	--[[if(player.powerup > PLAYER_FIREFLOWER) then
		player.powerup = PLAYER_BIG;
	end
	if(player.reservePowerup ~= 0 
	and player.reservePowerup ~= 185 and player.reservePowerup ~= 184  and player.reservePowerup ~= 249 and player.reservePowerup ~= 9 --shrooms
	and player.reservePowerup ~= 182 and player.reservePowerup ~= 14 and player.reservePowerup ~= 183) then --fire flowers
		player.reservePowerup = 9;
	end]]

	if(spikes1 == nil) then
	
		spikes1 = findlayer("Spikes 1");
		spikes1bg = findlayer("SpikesBG1");
		spikes2 = findlayer("Spikes 2");
		spikes2bg = findlayer("SpikesBG2");
		spikes3 = findlayer("Spikes 3");
		spikes3bg = findlayer("SpikesBG3");
		
	else
	
		if(player.section == 2 and player.x > -157408 and player.y > -159936 and player.y < -158912 and (player:mem(0x122,FIELD_WORD) == 0 or player:mem(0x122,FIELD_WORD) == 7 or player:mem(0x122,FIELD_WORD) == 500)) then
		
			wasInRange = true;
			
			if(spikescounter == 0) then
				playSFX("SpikesDown.wav");
			elseif(spikescounter == 90) then
				playSFX("SpikesDown.wav");
			elseif(spikescounter == 202) then
				playSFX("SpikesUp.wav");
			elseif(spikescounter == 292) then
				playSFX("SpikesUp.wav");
			end
			
			
			if(spikehurts.a == true and spikescounter >= 80 and spikescounter < 202) then
				triggerEvent("HideSpikes1");
				spikehurts.a = false;
			elseif spikehurts.a == false and (spikescounter < 80 or spikescounter >= 202) then
				triggerEvent("ShowSpikes1");
				spikehurts.a = true;
			end
				
				
			if(spikehurts.b == true and spikescounter >= 154 and spikescounter < 292) then
				triggerEvent("HideSpikes2");
				spikehurts.b = false;
			elseif spikehurts.b == false and (spikescounter < 154 or spikescounter >= 292) then
				triggerEvent("ShowSpikes2");
				spikehurts.b = true;
			end
				
			if(spikehurts.c == true and spikescounter >= 170 and spikescounter < 292) then
				triggerEvent("HideSpikes3");
				spikehurts.c = false;
			elseif spikehurts.c == false and (spikescounter < 170 or spikescounter >= 292) then
				triggerEvent("ShowSpikes3");
				spikehurts.c = true;
			end
			
			if(spikescounter >= 0 and spikescounter < 112) then
				spikes1speed = 2;--Spikes move down 7 squares.
			elseif(spikescounter >= 112 and spikescounter < 202) then
				spikes1speed = 0;--Spikes wait.
			elseif(spikescounter >= 202 and spikescounter < 222) then
				spikes1speed = -11.2;--Spikes move up 7 squares.
			elseif(spikescounter >= 222) then
				spikes1speed = 0;--Spikes wait.
			end
			
			if(spikescounter >= 0 and spikescounter < 90) then
				spikes2speed = 0;--Spikes wait.
			elseif(spikescounter >= 90 and spikescounter < 202) then
				spikes2speed = 2;--Spikes move down 7 squares.
			elseif(spikescounter >= 202 and spikescounter < 292) then
				spikes2speed = 0;--Spikes wait.
			elseif(spikescounter >= 292 and spikescounter < 312) then
				spikes2speed = -11.2;--Spikes move up 7 squares.
			elseif(spikescounter >= 312) then
				spikes2speed = 0;
				spikescounter = -1;
			end
			
			spikes1.speedY = spikes1speed;
			spikes1bg.speedY = spikes1speed;
			spikes2.speedY = spikes2speed;
			spikes2bg.speedY = spikes2speed;
			spikes3.speedY = spikes2speed;
			spikes3bg.speedY = spikes2speed;
		
			spikescounter = spikescounter + 1;
		else
			spikes1.speedY = 0;
			spikes2.speedY = 0;
			spikes3.speedY = 0;
			spikes1bg.speedY = 0;
			spikes2bg.speedY = 0;
			spikes3bg.speedY = 0;
		end
	end
end