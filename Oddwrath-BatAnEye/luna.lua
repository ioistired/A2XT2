local message = API.load("a2xt_message");
local scene = API.load("a2xt_scene");
local eventu = API.load("eventu");
local pnpc = API.load("pnpc");

function onTick()
	if(player:mem(0x56, FIELD_WORD) > 8) then
		player:mem(0x56, FIELD_WORD, 0)
	end
	
	if(player:mem(0x122, FIELD_WORD) == 2) then
		for _,v in ipairs(NPC.get(271, player.section)) do
			v = pnpc.wrap(v);
			if(v.data) then
				if(v.data.swoop) then
					v.y = v.data.swoop;
				end
				v.data.swoop = v.y;
			end
		end
	else
		for _,v in ipairs(NPC.get(271, player.section)) do
			v = pnpc.wrap(v);
			if(v.data) then
			
				v.data.swoop = nil;
			end
		end
	end
end

message.presetSequences.boo = function(args)
	local talker = args.npc;
	
	Misc.unpause();

	message.showMessageBox {target=talker, type="bubble", text="Big thanks to you for getting rid of these bats! Now we can finally continue haunting these mines in relative peace.<page>Alright everyone! We have a lot of territory to reclaim, so get moving! Go, go, go!"}
	message.waitMessageEnd(nil, true);
	
	triggerEvent("Get to work!");
	
	eventu.waitSeconds(1,true);
	
	message.showMessageBox {target=talker, type="bubble", text="...Oh, I almost forgot. I found this in the mine the other day. I'm a spooky ghost, so I have no use for food, but you look like you could use some greens. I'll be off now!"}
	message.waitMessageEnd(nil, true);
	
	triggerEvent("Oh, that's for you.");
	
	eventu.waitSeconds(0.5,true);
	
	scene.endScene()
	message.endMessage();
end