local eventu = API.load("eventu");
local rng = API.load("rng");

function onStart()
	if (player.isValid) then
		--player.powerup = PLAYER_BIG;
		player:mem(0x16, FIELD_WORD, 3)
		player:mem(0xF0, FIELD_WORD, 4);
		player:mem(0x108, FIELD_WORD, 0);

	end

end

function onInputUpdate()
	if( cantshoot == true) then
		player.rightKeyPressing = false
		player.leftKeyPressing = false
	end

	if(Lejes.releaseTriggered == true) then
		if(player.downKeyPressing) then
			player.downKeyPressing = false
		end
		if(player.altJumpKeyPressing) then
			player.altJumpKeyPressing = false
		end
		if player.altRunKeyPressing then
			player.runKeyPressing = false
			player.altRunKeyPressing = false
		end
	end
end

function onLoadSection9()
	if (player.isValid) then
		player.powerup = PLAYER_SMALL;
Lejes.releaseTriggered = false
	end
	eventu.setFrameTimer(2,introtext,false)
	--_G["ManualTitle"] = "Roll's Sacrifice"
	--_G["ManualArtist"] = "TSSF"
	--_G["ManualAlbum"] = "Mega Man 10 NSF Soundtrack Remade"

end

function introtext()
	if player.section == 9 then
triggerEvent("IntroText");
end
end

function onLoopSection9()

end

function onLoop()
	Lejes:onLoop()
	Hearts:onLoop()


end


--Borrowing Lejes's Shooter thingy again >.>

Lejes = {}
Lejes.buttonrelease = true;
Lejes.fireballx = 0;
Lejes.firebally = 0;
Lejes.fireballspeedX = 0;
Lejes.fireballdir = 0;
Lejes.fireballnpc = nil;
Lejes.fireballnpc2 = nil;
Lejes.crocomireattack = nil;
Lejes.firecooldown = 0;
Lejes.firecooldown2 = 100;
Lejes.crocotimer = 140;
Lejes.stringcounter = 0;
Lejes.playerHeight = 54;
Lejes.playerWidth = 24;
Lejes.releaseTriggered = false
bosshits = 0
bosscooldown = 40
test = nil
boss = true
mofifier = 1
cantshoot = false
timer = 0;
testnum = 0
function Lejes:onLoop()

	for _,v in pairs(NPC.get(39,-1)) do
		v.speedX = 0
		v.speedY = 0
		v.dontMove = true
		
if v.ai1 <= 0 then
			
v:mem(0x156, FIELD_WORD, 10) 
		end
	end

	for  k,v in pairs(NPC.get(37, -1))  do
		if (v.ai1 == 0) then
			v.ai1 = 1;
			--[[if (timer == 100) then
				v.ai1 = 1;
				timer =0
			else
				timer = timer + 1
				v.ai1 = 0
			end]]
		end
		if (v.ai1 == 3) then
			v.speedY = v.speedY / 1.5
		end

	end
for  k,v in pairs(NPC.get(38, -1))  do
      if (v.x < player.x) then
         v.speedX = .5
      end
      if (v.y < player.y) then
         v.speedY = .7
      end
      if (v.x > player.x) then
         v.speedX = -.5
      end
      if (v.y > player.y) then
         v.speedY = -.7
      end
	--v.speedX = v.speedX * .9
	--v.speedY = v.speedY * .9
   end
	for  k,v in pairs(NPC.get(133, 5))  do
		
		v.id = 202
	end
	
	--Text.print(player:mem(0x16, FIELD_WORD),100,100)

	if (player.speedX >= 3.5 and Lejes.releaseTriggered == true) then
		player.speedX = 3
	end
	if (player.speedX <= -3.5 and Lejes.releaseTriggered == true) then
		player.speedX = -3
	end


	--if (player.powerup == PLAYER_BIG) then
		--Lejes.releaseTriggered = true
	--end

	if Lejes.releaseTriggered then
		if (player.XKeyState == -1 and Lejes.firecooldown <= 0 and Lejes.buttonrelease == true and cantshoot == false) then

			Lejes.buttonrelease = false;
			if (player.FacingDirection == DIR_RIGHT) then
				Lejes.fireballx = player.x + 24;
				Lejes.fireballspeedX = 9;
				Lejes.fireballdir = DIR_RIGHT;
			else
				Lejes.fireballx = player.x - 24;
				Lejes.fireballspeedX = -9;
				Lejes.fireballdir = DIR_LEFT;
			end
			if (player.powerup == PLAYER_SMALL) then
				Lejes.firebally = player.y + 12;
			else
				Lejes.firebally = player.y + 24;
			end
			if (player.section ~= 10) then
				Lejes.fireballnpc = spawnNPC(108, Lejes.fireballx, Lejes.firebally, 3);
			else
				Lejes.fireballnpc = spawnNPC(85, Lejes.fireballx, Lejes.firebally, player.section);
				Lejes.fireballnpc:mem(0x46, FIELD_WORD, 0xFFFF);
			end
			Lejes.fireballnpc.speedX = Lejes.fireballspeedX;
			--Lejes.fireballnpc:mem(0x46, FIELD_WORD, 0xFFFF);
			Lejes.fireballnpc:mem(0xEC, FIELD_FLOAT, Lejes.fireballdir);
			Lejes.fireballnpc:mem(0x118, FIELD_FLOAT, Lejes.fireballdir);
			Lejes.firecooldown = 15;
			playSFX("shoot.wav");
		end
		
		if (player.XKeyState == 0) then
			Lejes.buttonrelease = true;
		end
		
		if (Lejes.firecooldown > 0) then
			Lejes.firecooldown = Lejes.firecooldown - 1;
		end
					--Text.print(hits,100,100)
		for k, v in pairs(findnpcs(85, player.section)) do
			for t, u in pairs(findnpcs(77, player.section)) do
				if ((v.x < u.x + u:mem(0x90, FIELD_DFLOAT)) and (v.x + v:mem(0x90, FIELD_DFLOAT) > u.x + 32) and (v.y < u.y + u:mem(0x88, FIELD_DFLOAT)) and (v.y + v:mem(0x88, FIELD_DFLOAT) > u.y)) then
					

					v:kill(9)
					if (bosscooldown == 0) then
						bosshits = bosshits - 1;
						playSFX("bosshurt.wav");
						bosscooldown = 40;
	
					end
					if (bosshits == 0 and bossstarted == true) then
						u:kill(9)
						Misc.doPOW()
						playSFX("bosskill.wav");
						Animation.spawn(108, u.x + 32, u.y + 32)


					end
					--spawnNPC(77, u.x, u.y, 10)
					--[[if (v.speedX < 0) then
						u.x = u.x - 3;
					else
						u.x = u.x + 7;
					end
					v:kill();]]
				end
			end
			for t, u in pairs(findnpcs(162, player.section)) do
				if ((v.x < u.x + u:mem(0x90, FIELD_DFLOAT)) and (v.x + v:mem(0x90, FIELD_DFLOAT) > u.x + 32) and (v.y < u.y + u:mem(0x88, FIELD_DFLOAT)) and (v.y + v:mem(0x88, FIELD_DFLOAT) > u.y)) then
					v:kill(9)
					u:kill(9)
					Animation.spawn(108, u.x + 32, u.y + 32)
				end
			end
			if (bosscooldown > 0 and (bosscooldown % 4 == 0) and frozen == false) then
				for  k,v in pairs(NPC.get(77, 10))  do
					Animation.spawn(75, v.x + 32 , v.y + 32)
				end
			end
		end
		
	end
end

function onEvent(eventname)
	correctevent = string.sub(eventname,1,5)
	--Text.print(correctevent,100,100)
	if (correctevent == "block") then
		Audio.playSFX("platform.wav")
	end
	if (eventname == "revealhelmet") then
		player:mem(0x16, FIELD_WORD, 3);
		--Lejes.releaseTriggered = true
		eventu.setFrameTimer(1, test, false)
	end	
	if (eventname == "BossKill") then
		eventu.setTimer(3, WinJingle, false);
	end
	if (eventname == "ShowLeek") then
		Lejes.releaseTriggered = false
		Audio.MusicStop()
		cantshoot = false
	end
end

Hearts = {}
heartLimit = 7;
vhearts = 7;

sevenhits = Graphics.loadImage("//7hits.png");
sixhits = Graphics.loadImage("//6hits.png");
fivehits = Graphics.loadImage("//5hits.png");
fourhits = Graphics.loadImage("//4hits.png");
threehits = Graphics.loadImage("//3hits.png");
twohits = Graphics.loadImage("//2hits.png");
onehits = Graphics.loadImage("//1hits.png");
zerohits = Graphics.loadImage("//0hits.png");

sevenboss = Graphics.loadImage("//7boss.png");
sixboss = Graphics.loadImage("//6boss.png");
fiveboss = Graphics.loadImage("//5boss.png");
fourboss = Graphics.loadImage("//4boss.png");
threeboss = Graphics.loadImage("//3boss.png");
twoboss = Graphics.loadImage("//2boss.png");
oneboss = Graphics.loadImage("//1boss.png");
zeroboss = Graphics.loadImage("//0boss.png");


printIt = false
test = false
bosscutscene = false
bossstarted = false
bossgainhealth = false

first = true;
jump = true
waittime = 9;

freezetime = 300
freezecounter = 0
frozen = false

-- Hearts System based on http://engine.wohlnet.ru/forum/viewtopic.php?f=26&t=551

function Hearts:onLoop()
	
if (Lejes.releaseTriggered == true) then
		hud(false);
		--Detect extra hearts. It'll add an infinite number of hearts.
		if (player.powerup == PLAYER_FIREFLOWER) then
			if (waittime == 9) then
				Audio.playSFX("gainhealth.wav")
				vhearts = vhearts + 1;
				player:mem(0x16, FIELD_WORD, 3);
				waittime = 0
			else
				waittime = waittime + 1
			end
			player.powerup = PLAYER_BIG;
		end
		
		--You've defined a number of hearts for some reason, no?
		if (vhearts > heartLimit) then
			vhearts = heartLimit;
		end
		
		--If damaged, take extra hearts from virtual hearts
		if ((player:mem(0x16, FIELD_WORD)) == 2) and (vhearts > 0) then
			vhearts = vhearts - 1;
			Audio.playSFX("ouch.wav")
			player:mem(0x16, FIELD_WORD, 3);

		end
		
		--This keeps the player alive
		if (player.powerup == PLAYER_SMALL) and (vhearts > 2) then
			player.powerup = PLAYER_BIG;


		end
		if (player:mem(0x13E, FIELD_WORD) ~= 0) then
			vhearts = -1
		end

		--kill the player
		if (vhearts == 0) then
			player:kill()
			cantshoot = true
			Lejes.releaseTriggered = false
			vhearts = vhearts - 1;
		end
		
		--[[This prints the number of hearts with base text at specific coordinates. 
		NOTE: there is no necesity to type a space after the word. Because the function adds one automatically.]]
		if (printIt == true) then
			local HeartN = tostring(vhearts);
			local truehearts = player:mem(0x16, FIELD_WORD);
			Text.print("Hearts" .. " " .. HeartN .. " " .. waittime , 100, 100);
		end

		if (vhearts == 7) then
			Graphics.placeSprite(1,sevenhits,75,50);
			Graphics.unplaceSprites(sixhits);
			Graphics.unplaceSprites(fivehits);
			Graphics.unplaceSprites(fourhits);
			Graphics.unplaceSprites(threehits);
			Graphics.unplaceSprites(twohits);
			Graphics.unplaceSprites(onehits);
			Graphics.unplaceSprites(zerohits);
		elseif (vhearts == 6) then
			Graphics.placeSprite(1,sixhits,75,50);
			Graphics.unplaceSprites(sevenhits);
			Graphics.unplaceSprites(fivehits);
			Graphics.unplaceSprites(fourhits);
			Graphics.unplaceSprites(threehits);
			Graphics.unplaceSprites(twohits);
			Graphics.unplaceSprites(onehits);
			Graphics.unplaceSprites(zerohits);
		elseif (vhearts == 5) then
			Graphics.placeSprite(1,fivehits,75,50);
			Graphics.unplaceSprites(sixhits);
			Graphics.unplaceSprites(sevenhits);
			Graphics.unplaceSprites(fourhits);
			Graphics.unplaceSprites(threehits);
			Graphics.unplaceSprites(twohits);
			Graphics.unplaceSprites(onehits);
			Graphics.unplaceSprites(zerohits);
		elseif (vhearts == 4) then
			Graphics.placeSprite(1,fourhits,75,50);
			Graphics.unplaceSprites(sixhits);
			Graphics.unplaceSprites(fivehits);
			Graphics.unplaceSprites(sevenhits);
			Graphics.unplaceSprites(threehits);
			Graphics.unplaceSprites(twohits);
			Graphics.unplaceSprites(onehits);
			Graphics.unplaceSprites(zerohits);
		elseif (vhearts == 3) then
			Graphics.placeSprite(1,threehits,75,50);
			Graphics.unplaceSprites(sixhits);
			Graphics.unplaceSprites(fivehits);
			Graphics.unplaceSprites(fourhits);
			Graphics.unplaceSprites(sevenhits);
			Graphics.unplaceSprites(twohits);
			Graphics.unplaceSprites(onehits);
			Graphics.unplaceSprites(zerohits);
		elseif (vhearts == 2) then
			Graphics.placeSprite(1,twohits,75,50);
			Graphics.unplaceSprites(sixhits);
			Graphics.unplaceSprites(fivehits);
			Graphics.unplaceSprites(fourhits);
			Graphics.unplaceSprites(threehits);
			Graphics.unplaceSprites(sevenhits);
			Graphics.unplaceSprites(onehits);
			Graphics.unplaceSprites(zerohits);
		elseif (vhearts == 1) then
			Graphics.placeSprite(1,onehits,75,50);
			Graphics.unplaceSprites(sixhits);
			Graphics.unplaceSprites(fivehits);
			Graphics.unplaceSprites(fourhits);
			Graphics.unplaceSprites(threehits);
			Graphics.unplaceSprites(twohits);
			Graphics.unplaceSprites(sevenhits);
			Graphics.unplaceSprites(zerohits);
		else
			Graphics.placeSprite(1,zerohits,75,50);
			Graphics.unplaceSprites(sevenhits);
			Graphics.unplaceSprites(sixhits);
			Graphics.unplaceSprites(fivehits);
			Graphics.unplaceSprites(fourhits);
			Graphics.unplaceSprites(threehits);
			Graphics.unplaceSprites(twohits);
			Graphics.unplaceSprites(onehits);
		end
	end
	
end

function onLoadSection3()
	--_G["ManualTitle"] = "Mega Man 2 Wily 1/2 VRC6 Remix"
	--_G["ManualArtist"] = "8BitDanooct1"
	--_G["ManualAlbum"] = ""

	if (player.isValid) then
		player:mem(0x16, FIELD_WORD, 3);
		eventu.setFrameTimer(1, test, false)
		--Lejes.releaseTriggered = true

	end
end
function onLoadSection8()
	if (player.isValid) then
		player:mem(0x16, FIELD_WORD, 3);
		eventu.setFrameTimer(1, test, false)
		--Lejes.releaseTriggered = true
	end
end

function test()
player:mem(0x16, FIELD_WORD, 3);
Lejes.releaseTriggered = true
end

function onLoadSection10()
	boss = false
	--triggerEvent("BossCutscene")
	Lejes.releaseTriggered = false
	bosscutscene = true
	eventu.setTimer(5, BossStart, false);
	eventu.setTimer(3, BossHealth, false);
	--eventu.setTimer(7, BossShoot, false);
end

function onLoopSection10()


	if (boss == true) then

		for  k,v in pairs(NPC.get(77, 10))  do
			--freezetime = rng.randomInt(200)
				--Text.print(freezetime, 200, 300)
			if (freezetime == 10 and frozen == false) then
				freezecounter = 0
				frozen = true
				freezetime = 0
				--bosscooldown = 100
				Lejes.firecooldown2 = 150

			end
				--Text.print(freezecounter, 300, 300)
			if (freezecounter > 0 ) then
				freezecounter = freezecounter - 1
				v:mem(0x48, FIELD_WORD, -1);
				--v.speedX = 
				--v.speedY = -.25
				if (freezecounter < 150) then
					--cantshoot = true
					player.speedX = player.speedX *.8
					--player.speedY = 
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					Animation.spawn(78,  rng.randomInt(0,800),  rng.randomInt(-600,0))
					if (respawnedhealth == false) then
						Audio.playSFX("flashman.wav")
						v:mem(0x48, FIELD_WORD, 0);
						--bosshits = bosshits + 1
						respawnedhealth = true
						if (bosshits > 7) then
							bosshits = 7
						end
					end

				else
					Animation.spawn(74, v.x + rng.randomInt(64), v.y + rng.randomInt(64))
				end
			else
				respawnedhealth = false
				freezetime = freezetime - 1
				--cantshoot = false
				frozen = false
				v:mem(0x48, FIELD_WORD, 0);
			end
		end


	--Text.print(Lejes.firecooldown2,200,200)
	if (Lejes.firecooldown2 <= 0) then
		for  k,v in pairs(NPC.get(77, 10))  do
			if (v.direction == DIR_RIGHT) then
				Lejes.fireballx = v.x + 24;
				Lejes.fireballspeedX = 6;
				Lejes.fireballdir = DIR_RIGHT;
			else
				Lejes.fireballx = v.x + 24;
				Lejes.fireballspeedX = -6;
				Lejes.fireballdir = DIR_LEFT;
			end
			Lejes.firebally = v.y + 32;
			Lejes.fireballnpc = spawnNPC(162, Lejes.fireballx, Lejes.firebally, player.section);
			--Lejes.fireballnpc2 = spawnNPC(282, Lejes.fireballx, Lejes.firebally, player.section);
			Lejes.fireballnpc.speedX = Lejes.fireballspeedX;
			--Lejes.fireballnpc2.speedY = 6;
			Lejes.fireballnpc:mem(0xEC, FIELD_FLOAT, Lejes.fireballdir);
			Lejes.fireballnpc:mem(0x118, FIELD_FLOAT, Lejes.fireballdir);
			Lejes.firecooldown2 = rng.randomInt(50)

		end
	end
		if (Lejes.firecooldown2 > 0) then
			Lejes.firecooldown2 = Lejes.firecooldown2 - 1;
		end
	end

	if (bosscutscene) then

		triggerEvent("BossCutscene")
		for  k,v in pairs(NPC.get(77, 10))  do
			v.speedY = .75
			end
	end


	if (bosscooldown ~= 0) then
		bosscooldown = bosscooldown - 1
	end
		if (bosshits == 7) then
			Graphics.placeSprite(1,sevenboss,125,50);
			Graphics.unplaceSprites(sixboss);
			Graphics.unplaceSprites(fiveboss);
			Graphics.unplaceSprites(fourboss);
			Graphics.unplaceSprites(threeboss);
			Graphics.unplaceSprites(twoboss);
			Graphics.unplaceSprites(oneboss);
			Graphics.unplaceSprites(zeroboss);
		elseif (bosshits == 6) then
			Graphics.placeSprite(1,sixboss,125,50);
			Graphics.unplaceSprites(sevenboss);
			Graphics.unplaceSprites(fiveboss);
			Graphics.unplaceSprites(fourboss);
			Graphics.unplaceSprites(threeboss);
			Graphics.unplaceSprites(twoboss);
			Graphics.unplaceSprites(oneboss);
			Graphics.unplaceSprites(zeroboss);
		elseif (bosshits == 5) then
			Graphics.placeSprite(1,fiveboss,125,50);
			Graphics.unplaceSprites(sixboss);
			Graphics.unplaceSprites(sevenboss);
			Graphics.unplaceSprites(fourboss);
			Graphics.unplaceSprites(threeboss);
			Graphics.unplaceSprites(twoboss);
			Graphics.unplaceSprites(oneboss);
			Graphics.unplaceSprites(zeroboss);
		elseif (bosshits == 4) then
			Graphics.placeSprite(1,fourboss,125,50);
			Graphics.unplaceSprites(sixboss);
			Graphics.unplaceSprites(fiveboss);
			Graphics.unplaceSprites(sevenboss);
			Graphics.unplaceSprites(threeboss);
			Graphics.unplaceSprites(twoboss);
			Graphics.unplaceSprites(oneboss);
			Graphics.unplaceSprites(zeroboss);
		elseif (bosshits == 3) then
			Graphics.placeSprite(1,threeboss,125,50);
			Graphics.unplaceSprites(sixboss);
			Graphics.unplaceSprites(fiveboss);
			Graphics.unplaceSprites(fourboss);
			Graphics.unplaceSprites(sevenboss);
			Graphics.unplaceSprites(twoboss);
			Graphics.unplaceSprites(oneboss);
			Graphics.unplaceSprites(zeroboss);
		elseif (bosshits == 2) then
			Graphics.placeSprite(1,twoboss,125,50);
			Graphics.unplaceSprites(sixboss);
			Graphics.unplaceSprites(fiveboss);
			Graphics.unplaceSprites(fourboss);
			Graphics.unplaceSprites(threeboss);
			Graphics.unplaceSprites(sevenboss);
			Graphics.unplaceSprites(oneboss);
			Graphics.unplaceSprites(zeroboss);
		elseif (bosshits == 1) then
			Graphics.placeSprite(1,oneboss,125,50);
			Graphics.unplaceSprites(sixboss);
			Graphics.unplaceSprites(fiveboss);
			Graphics.unplaceSprites(fourboss);
			Graphics.unplaceSprites(threeboss);
			Graphics.unplaceSprites(twoboss);
			Graphics.unplaceSprites(sevenboss);
			Graphics.unplaceSprites(zeroboss);
		else
			--Graphics.placeSprite(1,zeroboss,125,50);
			Graphics.unplaceSprites(sevenboss);
			Graphics.unplaceSprites(sixboss);
			Graphics.unplaceSprites(fiveboss);
			Graphics.unplaceSprites(fourboss);
			Graphics.unplaceSprites(threeboss);
			Graphics.unplaceSprites(twoboss);
			Graphics.unplaceSprites(oneboss);
		end


	for  k,v in pairs(NPC.get(77, 10))  do
		v.direction = DIR_RIGHT;
		if (jump == true) then
			modifier = rng.random(0.92, 1.17)
			v.speedY = v.speedY * modifier
			jump = false
		else
			jump = true
		end
		--Text.print(v.speedY, 100, 100)
		if  player.x < v.x  then
			v.direction = DIR_LEFT;
			--v.speedX = 4
    		end
	end
end

function BossShoot()
	boss = true
--local shoot = rng.randomInt(1)

end

function BossStart()
	bosscutscene = false
	boss = true
	bossstarted = true
		Lejes.releaseTriggered = true
		for  k,v in pairs(NPC.get(77, 10))  do
			v:mem(0x48, FIELD_WORD, 0);
			end
end
function BossHealth()
			bosshits = 7
			Audio.playSFX("bossgainhealth.wav")

end

function WinJingle()
	--Audio.playSFX("winner.ogg")
	Audio.MusicOpen("mm10nsf.nsfe|19")
	Audio.MusicPlay()
	cantshoot = true
end