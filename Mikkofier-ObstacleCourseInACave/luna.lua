local message = API.load("a2xt_message");
local scene = API.load("a2xt_scene");
local eventu = API.load("eventu");
local pnpc = API.load("pnpc");

local runPeachScene = false;
local dooranim = 0;
local camerashift;

local bossStarted = false;

local function cor_peach()
	eventu.waitSeconds(0.5);
	
	local t = pnpc.wrap(NPC.get(198,1)[1]);
	
	message.showMessageBox {target=t, type="bubble", text="You're probably looking for this bag o' cash?<page>Well, too bad! I'm using it for my brilliant and sundry plans, too grand for you to comprehend!<page>Now, to make my escape, Nyah hah haa!"}
	message.waitMessageEnd(nil, true);
	
	eventu.waitSeconds(0.5);
	triggerEvent("Escape, for real!");
	
	eventu.waitSeconds(0.5);
	
	scene.endScene();
end

local function cor_peach2()
	while(camera.x < Section(2).boundary.right-800) do
		
		if((player:isGroundTouching() or player.x > -150432) and not Misc.isPausedByLua()) then
			Misc.pause()
		end
		cameraShift = Section(2).boundary.right-800;
		eventu.waitFrames(0, true);
	end
	
	cameraShift = nil;
	
	local t;
	for _,v in ipairs(NPC.get(39,2)) do
		if(v.x > -150752) then
			t = pnpc.wrap(v);
			break;
		end
	end
	
	message.showMessageBox {target=t, type="bubble", text="Nyah ha haa! I see my as-evil-as-me clones were no match for you. Let me be your opponent, now."}
	message.waitMessageEnd(nil, true);
	
	eventu.waitSeconds(0.5, true);
	Misc.unpause()
	
	bossStarted = true;
	
	scene.endScene();
end

function onCameraUpdate()
	if(cameraShift) then
		camera.x = math.min(camera.x + 4, cameraShift);
	end
end

local function cor_peach3()
	
	local t;
	for _,v in ipairs(NPC.get(39,2)) do
		if(v.x > -150752) then
			t = pnpc.wrap(v);
			break;
		end
	end
	message.showMessageBox {target=t, type="bubble", text="Oh no, my brilliant and sundry plans!"}
	message.waitMessageEnd(nil, true);
	

	eventu.waitSeconds(0.5, true);
	Misc.unpause();
	
	triggerEvent("Victory")
	
	scene.endScene();
end

function onNPCKill(event, npc, reason)
	if(npc.id == 39 and bossStarted) then
		Misc.pause()
		scene.startScene{scene=cor_peach3, noletterbox = true}
		bossStarted = false;
	end
end

function onTick()
	if(not runPeachScene and player.section == 1) then
		runPeachScene = true;
		
		scene.startScene{scene=cor_peach}
	end
	
	if(dooranim > 0) then
		dooranim = dooranim-1;
		if(dooranim <= 0) then
			triggerEvent("poof");
		end
	end
end

function onDraw()
	if(dooranim > 0) then
		Graphics.drawImageToSceneWP(Graphics.sprites.effect[59].img, -193984, -200608, 0, math.floor((1-dooranim/48)*5)*64, 32, 64, -60)
	end
end

function onEvent(name)
	if(name == "What was that?") then
		dooranim = 48;
	elseif(name == "Gloating1") then
		scene.startScene{scene=cor_peach2}
	end
end