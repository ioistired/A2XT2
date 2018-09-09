local message = API.load("a2xt_message");
local scene = API.load("a2xt_scene");
local imagic = API.load("imagic");
local pnpc = API.load("pnpc");
local colliders = API.load("colliders");

local airmeter = 1950 --Air Meter
local booairmeter = 180 --Big Boo's Air Meter

local cornImg = Graphics.loadImage("cornshield.png") --Corn Shield Image
local gasImg = Graphics.loadImage("Gas.png") --Gas Image
local barImg = Graphics.loadImage("bar.png")

local barCols = {Color.red, Color.canary, Color(0,0.8,1)}

 --Draw air meter, corn shield, and green overlay
function onDraw()
	 --Display air	
	local t = airmeter/(65*30);
	local c;
	if(t < 0.5) then
		c = Color.lerpHSV(barCols[1], barCols[2], t*2);
	else
		c = Color.lerpHSV(barCols[2], barCols[3], (t-0.5)*2);
	end
	
	if(Graphics.isHudActivated()) then
		imagic.bar{x = 400, y = 96, width = 160, height=12, percent = t, align = imagic.ALIGN_CENTRE, texture=barImg, color = c}
	end

	
	 --Show corn shields
	for _,v in ipairs(NPC.get({154, 155, 156, 157, 31}, player.section)) do
		if (player.section >= 3) then
			Graphics.drawImageToSceneWP(cornImg, (v.x - 96), (v.y - 96), 0.8, -5)
		end
	end
	
	 --Draw gas
	if (player.section >= 3) then
		Graphics.drawImageWP(gasImg, 0, 0,-5)
	end
end

local lift2Layer;
local lift2Switch;
local lift2End;
local noCornLayer;

function onStart()
	if(GameData.hazymaizecave == nil) then
		GameData.hazymaizecave = {};
	end
	if(player.section == 2 and GameData.hazymaizecave.midpoint) then
		triggerEvent("Corn 2");
	else
		GameData.hazymaizecave.midpoint = nil;
	end
	
	lift2Layer = Layer.get("Second Lift");
	lift2Switch = Layer.get("Second Lift Switch");
	lift2End = Layer.get("Second Lift Stuck");
	noCornLayer = Layer.get("No Corn Allowed");
end

local liftCollider = colliders.Box(-112320, -119872 + 24, 96, 8);
local nocornColliders = { 
							colliders.Box(-131968, -139904, 288, 256), 
							colliders.Box(-116000, -119744, 288, 256), 
							colliders.Box(-112480, -119808, 160, 192)
						};
						
						
						X=-112480; Y=-119808;
						
						
function onTick()

	liftCollider.x = liftCollider.x + lift2Layer.speedX;

	if(player:mem(0x13E, FIELD_WORD) == 0) then
		if(player.section >= 3) then
			local inCorn = false;
			
			--Player not in water
			if(player:mem(0x36, FIELD_WORD) == 0) then
				for _,v in ipairs(NPC.get({154, 155, 156, 157, 31}, player.section)) do
					v = pnpc.wrap(v);
					if(v.data.collider == nil) then
						v.data.collider = colliders.Circle(0,0,112);
					end
					v.data.collider.x = v.x+v.width*0.5;
					v.data.collider.y = v.y+v.height*0.5;
					
					if(colliders.collide(player, v.data.collider)) then
						inCorn = true;
						
						--Restore air if we aren't already full/have the moon boost
						if (airmeter < 1945) then
							airmeter = airmeter + 5
						elseif (airmeter <= 1950) then
							airmeter = 1950
						end
					end
				end
			else
				airmeter = airmeter - 2;
			end
			
			if(not inCorn) then
				airmeter = airmeter - 1;
			end
			
			if (airmeter <= 0) then
				airmeter = 0;
				--Hurt if out of air
				player:harm()
				--If not killed
				if (player:mem(0x13E, FIELD_WORD) == 0) then
					--Wait for Tanooki statue, power up, and power down to run out
					if (player:mem(0x4E, FIELD_WORD) == 0) and (player:mem(0x140, FIELD_WORD) == 0) then
						airmeter = 650
					end
				end	
			end
		--Section < 3
		else
			--Restore air in safe zones
			if (airmeter < 1940) then
				airmeter = airmeter + 10
			elseif (airmeter <= 1950) then
				airmeter = 1950
			end
		end
	else
		airmeter = 0;
	end
	
	local cornOnLift = false;
	local cornAllowed = true;
	local noCornAtLift = true;
	
	for _,v in ipairs(NPC.get{154,155}) do
	
		--Corn doesn't despawn
		v:mem(0x12A, FIELD_WORD, 180);
		
		if(v.id == 154) then
			--Corn is in section 2
			if(v:mem(0x146, FIELD_WORD) == 2) then
				GameData.hazymaizecave.midpoint = true;
			end
		end
		
		--Corn in section 4
		if(v:mem(0x146, FIELD_WORD) == 4) then
			noCornAtLift = false;
		end
		
		if(colliders.collide(v, liftCollider)) then
			cornOnLift = true;
		end
		
		for _,w in ipairs(nocornColliders) do
			if(colliders.collide(v, w)) then
				cornAllowed = false;
				if(noCornLayer.isHidden) then
					noCornLayer:show(false);
				end
				break;
			end
		end
	end
	
	if(cornAllowed and not noCornLayer.isHidden) then
		noCornLayer:hide(false);
	end
	
	if ((noCornAtLift or cornOnLift) and lift2Switch.isHidden) then
		lift2Switch:show(false);
	elseif(not noCornAtLift and not cornOnLift and not lift2Switch.isHidden) then
		lift2Switch:hide(false);
	end
	
	 --Stop second lift at the end of the track
	for _,v in ipairs(NPC.get(62)) do
		if (v.x >= -108932 and lift2End.isHidden) then
			lift2End:show(true);
			lift2Layer:hide(true);
		end
	end
	
	 --Big Boo Gag
	for _,v in ipairs(NPC.get(44, player.section)) do
		if ((player.x <= -99140) and (player.y <= -105440))	or (booairmeter < 180) then
			booairmeter = booairmeter - 1
			if (booairmeter <= 0) then
				v:kill()
			end
		end
	end
end

local airIDs = 
{
[9] 	= 1300;
[250] 	= 1300;
[14] 	= 650;
[264]	= 650;
[34]	= 650;
[169]	= 650;
[170]	= 650;
[253]	= 650;
[10]	= 33;
[88]	= 33;
[138]	= 33;
[251]	= 33;
[252]	= 163;
[274]	= 163;
[90]	= 1950;
[188]	= 5850;
}

function onNPCKill(eventObj, killedNPC, killReason)
     --Add air when things are collected, but not when they match a falling reserve item
	if (killReason == 9) then
     --Check if the NPC is on screen, otherwise it must have despawned
        if (killedNPC:mem(0x12A, FIELD_WORD) > 0 and killedNPC:mem(0x138, FIELD_WORD) ~= 2) then
			
			if(airIDs[killedNPC.id] ~= nil) then
				airmeter = airmeter + airIDs[killedNPC.id];
				--Cap air meter unless we just got a moon
				if(killedNPC ~= 188) then
					airmeter = math.min(airmeter, 1950);
				else
					airmeter = math.min(airmeter, 5850);
				end
			end
        end
    end
end

message.presetSequences.introguy = function(args)
		local talker = args.npc;
		
		message.showMessageBox {target=talker, type="bubble", text="Hello friend! Heading deeper into this cave, I see.<page>Listen, this part of the cave is filled with highly toxic gas. If I were you, I'd take this corn with you.<page>As everyone knows, corn is a natural repellant of toxic gas."}
		message.waitMessageEnd(nil, true);
		
		local response;
		if(player.character == CHARACTER_DEMO) then
			response = "That's a bit... odd. Thanks, I guess.";
		elseif(player.character == CHARACTER_IRIS) then
			response = "That's stupid, but whatever. As long as we can get through, I don't care how.";
		elseif(player.character == CHARACTER_KOOD) then
			response = "That sure sounds useful. Thanks for the help.";
		elseif(player.character == CHARACTER_RAOCOW) then
			response = "So true! No worries, guy. I shall protect this corn with my life.";
		elseif(player.character == CHARACTER_SHEATH) then
			response = "But I can't... uh... hold things... How will I...";
		end
		message.showMessageBox {target=player, type="bubble", text=response}
		message.waitMessageEnd(nil, true);
		
		if(player.character == CHARACTER_SHEATH) then
			message.showMessageBox {target=talker, type="bubble", text="Oh. Sounds like a personal problem. I guess you'd better just take a deep breath and run for it. It was nice knowing you!"}
			message.waitMessageEnd(nil, true);
		else
			message.showMessageBox {target=talker, type="bubble", text="Yes, well... anyway, this is the only corn I have, so don't lose it. Good luck in there."}
			message.waitMessageEnd(nil, true);
		end
		
		scene.endScene()
		message.endMessage();
end


function onEvent(eventName)
	 --Trigger Fences
	if (eventName == "Fence Switch to Off") then
		triggerEvent("Left Fences Extend")
		triggerEvent("Right Fences Extend")
		triggerEvent("Top Fences Extend")
	end
	
	 --Trigger Corn2 if you reach the top of section 6
	if (eventName == "Corn 2") then
		GameData.hazymaizecave.midpoint = true;
	end
end
