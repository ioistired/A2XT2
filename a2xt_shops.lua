local npcManager = API.load("npcManager")
local textblox = API.load("textblox")
local animatx = API.load("animatx")
local cman = API.load("cameraman")
local eventu = API.load("eventu")
local imagic = API.load("imagic")
local pnpc = API.load("pnpc")
local rng = API.load("rng")
local defs = API.load("expandedDefines")

local scene = API.load("a2xt_scene")
local voice = API.load("a2xt_voice")
local message = API.load("a2xt_message")
local raocoins = API.load("a2xt_raocoincounter");
local costumes = API.load("a2xt_costumes")
local rewards = API.load("a2xt_rewards")
local leveldata = API.load("a2xt_leveldata")

local a2xt_shops = {}

--***************************
--** Variables             **
--***************************

local stable_mount_to_npc = {95, 98, 99, 100, 148, 149, 150, 228}
local stable_npc_to_mount = {}
for k,v in ipairs(stable_mount_to_npc) do
	stable_npc_to_mount[v] = k;
end

local powerup_shop_section = -1;
local img_powerup_generator = Graphics.loadImage(Misc.resolveFile("graphics/HUD/shop-generator.png"))
local powerup_shop_generator_markers = {};

local powerup_shop_lucky_chances = 
									{
										[9] = 5,
										[14] = 3,
										[34] = 3,
										[169] = 1,
										[170] = 1,
										[264] = 3
									}

local powerup_shop_lucky_total_prob = 0;
local powerup_shop_lucky_ids = {};

for k,v in pairs(powerup_shop_lucky_chances) do
	table.insert(powerup_shop_lucky_ids, k);
	powerup_shop_lucky_total_prob = powerup_shop_lucky_total_prob + v;
end

local function spawnSmoke(x,y)
	local a = Animation.spawn(10,x,y,player.section);
	a.x = a.x-a.width*0.5;
	a.y = a.y-a.height*0.5;
end

local function changePlayerState()
	player:mem(0x140,FIELD_WORD,150);
	spawnSmoke(player.x+player.width*0.5, player.y+player.height*0.5)
	Audio.playSFX(34)
end

local function getText(variants, index)
	if(type(variants) == "table") then
		return variants[index or 1];
	else
		return variants;
	end
end

local function buygenerator(npc)
	local n = NPC.spawn(npc.id, npc.x, npc.y, npc:mem(0x146, FIELD_WORD));
	n.dontMove = true;
	
	n = NPC.spawn(npc.id, npc.x, npc.y, npc:mem(0x146, FIELD_WORD));
	n:mem(0x64, FIELD_BOOL, true);	--is a generator
	n:mem(0x68, FIELD_WORD, 0);		--generator delay setting
	n:mem(0x6A, FIELD_WORD, 16800);	--generator fire rate
	n:mem(0x70, FIELD_WORD, 1)		--generate upwards
	n:mem(0x72, FIELD_WORD, 1);		--warp generator
	n.dontMove = true;
	
	npc:kill();
	
	if(SaveData.powerupshop == nil) then
		SaveData.powerupshop = {};
	end
	if(SaveData.powerupshop.generators == nil) then
		SaveData.powerupshop.generators = {};
	end
	
	SaveData.powerupshop.generators[tostring(npc.id)] = true;
end


a2xt_shops.settings = {
                      --[[ stable    = {   
                                    buyprices  = {2,4,4,4,8,6,6,6},
                                    sellprices = {1,2,2,2,4,3,3,3},
                                    selection  = {1,2,3},
                                   }
								   ]]
							stable = { 
									prices = {
											[95] = 	{buy = 2, sell = 1},
											[100] = {buy = 4, sell = 2},
											[98] = 	{buy = 4, sell = 2},
											[99] = 	{buy = 4, sell = 2},
											[149] = {buy = 8, sell = 4},
											[150] = {buy = 6, sell = 3},
											[228] = {buy = 6, sell = 3},
											[148] = {buy = 6, sell = 3}
											}
									},
									
							powerup = { 
									prices = {
											[9] = {buy = 2}, 
											[14] = {buy = 4},  
											[34] = {buy = 5},  
											[90] = {buy = 3},  
											[169] = {buy = 10}, 
											[170] = {buy = 10},  
											[188] = {buy = 9}, --3*[90]
											[264] = {buy = 5},
											[287] = {buy = 4}
											}
									}
                      }

for _,v in pairs(a2xt_shops.settings) do
	v.ids = {};
	for k,_ in pairs(v.prices) do
		table.insert(v.ids, k);
	end
end		

a2xt_shops.settings.costume = 	{
									ids = {977},
									prices = 	{
													DEMO_TEMPLATE = 0;
													IRIS_TEMPLATE = 0;
													RAOCOW_TEMPLATE = 0;
													KOOD_TEMPLATE = 0;
													SHEATH_TEMPLATE = 0;
													
													DEMO_BOBBLE = 100;
													DEMO_SAFETYBEE = 100;
												}
								}
					  
a2xt_shops.dialogue = {
                       stable    = {
                                    options = {
                                               {--[["I'd like to rent out a catllama.",]] "What do you do here?", "I've got places to be."},
                                               {"I'm ready to return her.", "Can I hear the sales pitch again?", "I need more time with this majestic creature."},
                                               {"You interested in buying?", "...What's your angle?", "NO YOU CAN'T HAVE HER"}
                                              },
                                    --TODO: Get these assigned to the right npc ids
                                    items = {[95] = "Common Verdegris",[98] = "Azure Skyhowler",[99] = "Whiffing Honeyjackal",[100] = "Norwegian Pyrelynx",[150] = "Flaminguanaco",[149]="Grizzlpaca",[148]="Sandy Meatcamel",[228]="Siberian Frostchucker"},
                                    welcome = {
                                               "Why, howdy there!  You wouldn't happen to be interested in renting out one of our fine furry friends, now, would ya?",
                                               "Hey there, pardner!  I trust our girl's been treatin' ya right?",
                                               "Well, now, that's a mighty fine camelid you've got there!"
                                              },
                                    goodbye = {
                                               "Don't be a stranger, hear?",
                                               "Have a safe trip!",
                                               "Let us know if you change your mind!"
                                              },
                                    about = "You look like you got a good head on your shoulders.  I reckon you know as well as I do that catllama-back ridin' is the only true way to travel.<page>We humble ranchers are here to provide you with a cuddly companion to help you get where you need to go.  Our catnips are the most dependable mounts you'll find for hundreds o' miles!<page>Of course, we hafta eat, so we can't go lending out rides for free.  We'll need a down payment of raocoins whenever you want to take one of our li'l fillies out with ya.<page>But we're not in this business fer the money.  If'n you bring 'em back home when you're done, we'll refund some of that fee as a show of good faith!<page>We'll accept wild catllamas y'all bring in as well, never hurts to add another member to the family!",
                                    browse = "Alrighty, just let me know which breed y'all want!",
                                    alreadyriding = 
                                            {
                                             [1] = "Looks to me like you have some kind of sack-type device. Gonna struggle to ride one o' these majestic creatures with your legs all tied up like that!",
                                             [2] = "Now that is one mighty fine contraption, but these catllamas are mighty afraid of machinery.<page>Why don't ya try parkin' that up and we'll see about gettin' ya a catllama instead.",
                                             [3] = "Seems ta me like you already have one o' our furry friends here. I don't know about you but ridin' two at once seems a bit of a stretch.<page>Come see me an' we can arrange tradin' her in if you'd like."
                                            },
                                    confirm = {
                                               "The [item], huh?  She'll run y'all about... I'd say [price].  Sound good?",
                                               "Sure y'all ready to part?  I can let ya keep her for a bit longer if you'd prefer.",
                                               "We've always more room for a new friend!  Let's see here...<page>She's got a mighty fine coat, great dental hygiene... Does [price] sound like a fair offer?"
                                              },
                                    buy = {
                                           "Thank ya kindly!  When yer done with her, jus' bring 'er back to this here stable and we'll give y'all a partial refund.<page>Don't worry too much if you lose track of 'er out in the wild, though;  she's a clever one, she can find her way back home no problem!",
                                           "We're mighty grateful for y'all bringin' her back!  Hope y'all had a great time together!<page>As promised, here's [price] back.  Feel free to stop by again sometime!",
                                           "Done deal!  Don't you worry, we'll take great care of the li'l rascal!<page>Feel free to come an' visit her or bring in any others y'all would like us to take care of!"
                                          },
                                    stopbuying = "It's alright if you're having second thoughts. We'll still be here if y'all decide to give it a go later!",  
                                    nodeal = {
                                              "Arrighty, then.  Is there another breed y'all might want instead?",
                                              "No harm done!  Jus' let me know when yer ready and we'll take 'er back!",
                                              "Aw, bummer.  Well, we'll be here if y'all change yer mind!"
                                             },
                                    notenough = "No can do, compadre!  You're gonna need more raocoins than that.",
                                    notallowed = {
                                                  [CHARACTER_PEACH] = "Sorry there, fella, but I can see it in yer eyes... that's the look of someone deathly allergic to catllamas.<page>I reckon if we were to let you ride one of our steeds you might keel right over, and we don't have the legal team to handle that kinda mess!",
                                                  [CHARACTER_TOAD] = "No offense there, pardner, but I can see it in yer eyes... that's the look of someone who spends an inordinate amount of time 'round wild sheep.<page>Now I ain't one to question nobody's life decisions, but I do hafta caution against tryin' to ride a catllama while covered in the scent o' their natural enemies.  The results ain't pretty.",
                                                  [CHARACTER_LINK] = "Thousand pardons, li'l lady, but I can see it in yer eyes... that's the look of someone who's prolly sixteen years old.<page>I reckon folks might start callin' us irresponsible and the like if they saw us loanin' out livestock to unaccompanied minors."
                                                 }
                                   },

                       powerup   = {
                                    options = {
                                               {"What is this place?", "Later."}
                                              },
                                    items = {[9] = "Red Radish", [14] = "Hot Cactus", [34] = "Spinach Leaf", [90] = "Green Radish", [169] = "Mystical Onion", [170] = "Extreme Gourd", [188] = "Lord of the Forest", [264] = "Icy Pine", [287] = "Lucky Dip Deal"},
                                    welcome = "Buy somethin' will ya?",
                                    about = {"This is a grocery store. We sell food. Try some, why don't ya?",
                                             "This is a grocery store. We sell food. Try some, why don't ya?<page>Some of our stock is a special, all-you-can-eat offer. Buy it once, and you can get a free refill any time you like. It's a steal!"},
                                    goodbye = "Make sure you come back later, ya hear?",
                                    confirm =
                                              {
                                               "That's a [item].  It'll cost ya [price].  Deal?",
                                               "That [item] is part of our all-you-can-eat offer.  It'll be [price].  Okay?",
                                              },
                                    buy =  "Enjoy your food!",
                                    nodeal = "Fine then. Anything else?",
                                    notenough = "Hey, what are ya trying to pull? You're gonna need more cash than that.",
                                   },

                       costume   = {
                                    options = {"What is this place?", "Later."},
                                    welcome = 	{ 
													"Bonjour madamoiselle. Would you like to peruse our fine outfits perchance?",
													"Bonjour monsieur. Would you like to peruse our fine outfits perchance?"
												},
									about = "We are a stylish boutique. We sell chique and fashionable outfits at reasonable prices.<page>There is also a changing room where you can change into any new clothing you purchase.",
									goodbye = 
											{
												"Au revoir, madame.",
												"Au revoir, monsieur."
											},
                                    buy = 	{
												"Merci, madame.",
												"Merci, monsieur."
											},
                                    notenough = "Ah, je suis triste. Ensure you have the necessary funds, s'il vous plait.",
									nodeal = 	{
													"You're mad, moiselle.",
													"Ah, such a shame."
												},
                                    confirm = {
												"Ah, le [item] outfit, c'est fantastique! It is [price], d'accord?",
												"Je suis desole, but that item has already been sold!"
											  }
                                   },

                       minigame  = {
                                   },

                       bmarket   = {
                                    options = {"Purchase (10 lives)", "Who are you?", "Later, alligator."},
                                    welcome = "Well, well, well, it seems we have a customer... you have good taste, my friend.",
                                    about = "My identity is of no consequence.  The important thing is that I can offer you far better produce than any of those eight-bit salad peddlers at the powerup shops.<page>Here's the thing, though: I don't take raocoins. Those cheap trinkets are far too easy for the government to trace and they won't do you a lick of good come the end times.<page>No, my friend, I only deal in cold, hard FOOD.  No mess, no footprints, no Big Brother knocking on the door of <i>this</i> establishment.<page>I don't take credit, so if you're interested in buying you better make sure you've got enough to spare.  Capiche?",
                                    buying = "An excellent choice!  You won't regret that investment, <wave1>hee hee hee...<wave 0><page>Here's the goods.  Remember, no refunds!",
                                    notenough = "I'm sorry, but it seems you're a little low on FOOD right now.  Why not go stock up and come back later?",
                                    goodbye = "Take care, friend..."
                                   },

                       sanctuary = {
                                    options = {"What is this place?", "Leeks are kinda dumb.", "Goodbye."},
                                    options2 = {"I'm sorry, that was uncalled for.", "Really, though, leeks aren't all that great.", "I'm good, thanks."},
                                    options3 = {"You're right, I'm being a jerk.", "Spring onions are better.", "Okay, fine, I'm going now."},
                                    options3 = {"I was wrong, leeks are the best vegetable!", "Leeks still suck."},
                                    welcome = "Welcome, dutiful sprig.  May you find respite in our humble sanctuary.",
                                    welcome2 = "Oh, it's you again.",
                                    about = "This temple was built to honor and commune with the one true Goddess, the wise and benevolent Lady Leek.<page>In appreciation of our reverence, the Lady extends Her divine aid to any who may need it.  With Her all-seeing eye and ever-present roots, she can reveal the whereabouts of any and all items you may seek.<page>She's also an avid advocate of card collecting, if you're into that stuff.<page>If you have need of Her insight, stand upon the pedestal and let your mind and spirit bask in Her antioxidating radiance.",
                                    insult = "Why, I never!  The sheer <tremble>audacity</tremble> to utter such blasphemy in these hallowed halls!<page>*deep breath*<page>Forgive me for my  lapse in decorum.<page>It seems you have lost your way.  But fear not, wayward child of the stalk!  If you open up your heart to the Goddess and renounce your heresy, I am sure she will welcome you back with open arms.",
                                    insult2 = "Again with the sinful slander!<page>If you cannot stay that wicked tongue then kindly take your leave of this sacred place, lest your vile words distress Her leafy goodness!",
                                    insult3 = "Oh, I see how it is!  You're one of those scismatic heathens!<page>You'll not defile this holy place with your false gods, you barbarian!  Begone at once!",
                                    apology = "A wise decision.  Reflect upon your mistakes and grow from them, young one. Embrace Her care and you will surely find peace.<page>And further know that, should you lose your way again, the Lady will always forgive you if you choose to accept Her help.",
                                    apology2 = "I commend you for finally being honest with yourself and accepting Her heavenly truth.  By renouncing the deplorable sacrilege of the Spring Onion, you are now on your way to redemption.<page>It will not be easy atoning for your sins, but as long as you continue to cleanse your soul with the nutrients of virtue, you too shall find true enlightenment.",
                                    goodbye = "Farewell, fellow seedling.  May the almighty allium bless you with great fortune and bountiful harvest.",
                                    goodbye2 = "So long, benighted kin.  I hope you may one day come to your senses and return to the path of righteous greenery.",
                                    goodbye3 = "Good riddance."
                                   }
                      }

--***************************
--** API Member Functions  **
--***************************
local function addPrice (str, amount)
	local newStr = string.gsub(str, "%[price%]", tostring(amount)..CHAR_RC)
	return newStr;
end
local function addItem (str, item)
	local newStr = str;
	if(item:lower():match("^[aeiou]")) then
		newStr = string.gsub(newStr, "(a)(%s%[item%])", "an%2")
	end
		
		newStr = string.gsub(newStr, "%[item%]", item)

	return newStr;
end
function a2xt_shops.getItemPromptList (ids, names, prices)
	local options = {}
	for  i=1,#ids  do
		local id = ids[i]
		options[i] = names[id].." ("..tostring(prices[id])..CHAR_RC..")"
	end
	return options
end

--TODO: Needs cleaning up because I can't be bothered to learn how gsub works right now
function a2xt_shops.parse(str, item, price)
	local newStr = addPrice(addItem(str, item), price);
	return newStr;
end

--***************************
--** Sequences             **
--***************************

--[[ --old catllama stable
message.presetSequences.stable = function(args)
	local talker = args.npc

	local dialog   = a2xt_shops.dialogue.stable
	local settings = a2xt_shops.settings.stable

	local hasRide = (player:mem(0x108, FIELD_WORD) == 3)

	local hasSameRide = false


	-- Determine the variant: 1=no catllama, 2=rented catllama, 3=non-rented catllama
	local variant = 1
	if  hasRide  then
		variant = 3
		if  hasSameRide  then
			variant = 2
		end
	end

	-- Begin with the prompt
	message.promptChosen = false
	message.showMessageBox {target=talker, type="bubble", text=dialog.welcome[variant], closeWith="prompt"}
	message.waitMessageDone ()
	message.showPrompt {options=dialog.options[variant]}
	message.waitPrompt ()

	-- Rent/turn in
	if  message.promptChoice == 1  then

		-- Rent a catllama
		if  variant == 1  then
			if  player.character == CHARACTER_MARIO  or  player.character == CHARACTER_LUIGI  then

				-- Get the options and their prices
				local options = {"hi","no"}--a2xt_shops.getItemPromptList(settings.selection, dialog.items, settings.buyprices)
				options[#options+1] = "On second thought..."
				local breakLoop = false

				local promptMessage = dialog.browse

				-- Ask the player which breed they want
				while  (not breakLoop)  do

					-- Prompt the player
					message.promptChosen = false
					message.showMessageBox {target=talker, type="bubble", text=dialog.browse, closeWith="prompt"}
					message.waitMessageDone ()
					message.showPrompt {options=options}
					message.waitPrompt ()

					-- If the player declines
					if  message.promptChoice == #options  then
						breakLoop = true
						message.showMessageBox {target=talker, type="bubble", text=dialog.stopbuying}

					else
						-- If the player has enough raocoins, get confirmation
						if  true  then
							message.promptChosen = false
							local catllamaPicked = 1--settings.selection[message.promptChoice]
							local confirmMessage = string.gsub (dialog.confirm[1], "%[item%]", dialog.items[catllamaPicked])
							message.showMessageBox {target=talker, type="bubble", text=confirmMessage, closeWith="prompt"}
							message.waitMessageDone ()
							message.showPrompt ()
							message.waitPrompt ()

							-- Player has rented the catllama
							if  message.promptChoice == 1  then
								message.showMessageBox {target=talker, type="bubble", text=dialog.buy[1]}
								player:mem(0x108, FIELD_WORD, 3)
								player:mem(0x10A, FIELD_WORD, catllamaPicked)
								breakLoop = true
							end

						-- If the player doesn't have enough raocoins, refuse
						else
							message.showMessageBox {target=talker, type="bubble", text=dialog.notenough}
							message.waitMessageEnd ()
						end
					end

					promptMessage = dialog.nodeal[1]
				end

			-- If the player is a non-Yoshi character, respond accordingly
			else
				message.showMessageBox {target=talker, type="bubble", text=dialog.notallowed[player.character]}
			end


		-- Return or sell a catllama
		else
			-- Calculate the refund/sale value
			local price = 5
			local confirmMessage = addPrice(dialog.confirm[variant], price)

			-- Check to make sure the player wants to do this
			message.promptChosen = false
			message.showMessageBox {target=talker, type="bubble", text=confirmMessage, closeWith="prompt"}
			message.waitMessageDone ()
			message.showPrompt {}
			message.waitPrompt ()

			-- Sell the catllama
			if  message.promptChoice == 1  then
				-- Add raocoins
				-- Add particle effects
				player:mem(0x108, FIELD_WORD, 0)
				message.showMessageBox {target=talker, type="bubble", text=dialog.buy[variant]}

			-- Keep the catllama
			else
				message.showMessageBox {target=talker, type="bubble", text=dialog.nodeal[variant]}
			end
		end

	-- About
	elseif  message.promptChoice == 2  then
		message.showMessageBox {target=talker, type="bubble", text=dialog.about}

	-- Bye
	elseif  message.promptChoice == 3  then
		message.showMessageBox {target=talker, type="bubble", text=dialog.goodbye[variant]}
	end

	message.waitMessageEnd()
	scene.endScene()
end
]]

message.presetSequences.stable = function(args)
	local talker = args.npc

	local dialog   = a2xt_shops.dialogue.stable
	local settings = a2xt_shops.settings.stable

	local hasRide = (player:mem(0x108, FIELD_WORD) == 3)
	
	local variant = 1;
	if(hasRide) then
		variant = 3;
	end

	-- Begin with the prompt
	message.promptChosen = false
	message.showMessageBox {target=talker, type="bubble", text=dialog.welcome[variant], closeWith="prompt"}
	message.waitMessageDone ()
	message.showPrompt {options=dialog.options[variant]}
	message.waitPrompt ()

	local choice = message.promptChoice
	if(not hasRide) then
		choice = choice + 1;
	end
	
	-- Rent/turn in
	if  choice == 1 and hasRide  then
		-- Return or sell a catllama
		-- Calculate the refund/sale value
		local price = settings.prices[stable_mount_to_npc[player:mem(0x10A, FIELD_WORD)]].sell;
		local confirmMessage = addPrice(dialog.confirm[variant], price)

		scene.displayRaocoinHud(true);
		
		-- Check to make sure the player wants to do this
		message.promptChosen = false
		message.showMessageBox {target=talker, type="bubble", text=confirmMessage, closeWith="prompt"}
		message.waitMessageDone ()
		message.showPrompt {}
		message.waitPrompt ()
		
		-- Sell the catllama
		if  message.promptChoice == 1  then
			raocoins.add(price);
			changePlayerState();
			player:mem(0x108, FIELD_WORD, 0)
			message.showMessageBox {target=talker, type="bubble", text=dialog.buy[variant]}

			-- Keep the catllama
		else
			message.showMessageBox {target=talker, type="bubble", text=dialog.nodeal[variant]}
		end
		
	-- About
	elseif  choice == 2  then
		message.showMessageBox {target=talker, type="bubble", text=dialog.about}

	-- Bye
	elseif  choice == 3  then
		message.showMessageBox {target=talker, type="bubble", text=dialog.goodbye[variant]}
	end

	message.waitMessageEnd()
	scene.displayRaocoinHud(false);
	scene.endScene()
	message.endMessage();
end

message.presetSequences.powerup = function(args)
	local talker = args.npc

	local dialog   = a2xt_shops.dialogue.powerup
	local settings = a2xt_shops.settings.powerup
	
	local variant = 1;

	-- Begin with the prompt
	message.promptChosen = false
	message.showMessageBox {target=talker, type="bubble", text=dialog.welcome, closeWith="prompt"}
	message.waitMessageDone ()
	message.showPrompt {options=dialog.options[variant]}
	message.waitPrompt ()

	local choice = message.promptChoice
	
	-- About
	if  choice == 1  then
		local index = 1;
		if(talker.data.hasGenerator) then
			index = 2;
		end
		message.showMessageBox {target=talker, type="bubble", text=dialog.about[index]}

	-- Bye
	elseif  choice == 2  then
		message.showMessageBox {target=talker, type="bubble", text=dialog.goodbye}
	end

	message.waitMessageEnd()
	scene.endScene()
	message.endMessage();
end

local function playerIsMale()
	return player.character == CHARACTER_RAOCOW or player.character == CHARACTER_KOOD or player.character == CHARACTER_UNCLEBROADSWORD;
end

message.presetSequences.costume = function(args)
	local talker = args.npc

	local dialog   = a2xt_shops.dialogue.costume
	local settings = a2xt_shops.settings.costume
	
	local variant = 1;
	
	if(playerIsMale()) then
		variant = 2;
	end

	-- Begin with the prompt
	message.promptChosen = false
	message.showMessageBox {target=talker, type="bubble", text=dialog.welcome[variant], closeWith="prompt"}
	message.waitMessageDone ()
	message.showPrompt {options=dialog.options}
	message.waitPrompt ()

	local choice = message.promptChoice
	
	-- About
	if  choice == 1  then
		local index = 1;
		message.showMessageBox {target=talker, type="bubble", text=dialog.about}

	-- Bye
	elseif  choice == 2  then
		message.showMessageBox {target=talker, type="bubble", text=dialog.goodbye[variant]}
	end

	message.waitMessageEnd()
	scene.endScene()
	message.endMessage();
end

message.presetSequences.coatlyn = function(args)
	local npc = args.npc
	local isCommenting = false
	local firstTime = not SaveData.coatlyn
	local roomieMet = SaveData
	local playerCostumed = costumes.isDefault(Player.character)

	local intro = ""

	-- If this is the first time meeting Coatlyn
	if  (firstTime)  then
		intro = "It is I, fresh, fab fashionista Coatlyn!  My couture consultation is rivaled by none!"

		SaveData.coatlyn = {
			roomieMet = {},
			roomiesMet = 0
		};

		if  playerCostumed
			intro = intro.."<page> I can sense potential in you, darling, but you really must change that outfit first!  Come back to me once you've found a new look."
		else
			intro = intro.."<page> I can sense you're a trendsetter in the making, darling!  Allow me just a moment..."
			isCommenting = true
		end

	-- If already acquainted
	else
		intro = ""

		if  not SaveData.coatlyn.roomieMet[npc.id]  then
			intro = intro.."  There's someone I'd like you to meet!"
		end

		if  playerCostumed
			intro = intro.."  It's always a pleasure to hear from you Come back to me once you've found a new look."
		else
			intro = intro.."<page> I can sense you're a trendsetter in the making, darling!  Allow me just a moment..."
			isCommenting = true
		end
	end

	-- Introduce herself
	local bubble = message.showMessageBox {target=npc, x=npc.x,y=npc.y, text=intro, closeWith="prompt", voice="coatlyn", voiceclip=vcs}
	message.waitMessageEnd()


	if  isCommenting  then
		if  not npc.data.roomieOut  then
			
		else
			
		end
	end

end


message.presetSequences.steve = function(args)
	local npc = args.npc
	local price = 10;
	
	local intro = "Hello there young mortal.<page>I am a ssssssseller of thingsssss. A merchant of ssssortssss.<page>My name issss Sssssteve.<page>I will happily take sssssome food off your handsssss, and in return grant you sssssome treasssssure.<page>Jusssst "..price.." will sssssuffice. Ssssso, will you accept thisssss arrangement?";
	if(SaveData.spokenToSteve) then
		local introlist =
		{
			[CHARACTER_DEMO] = {"Your breed of ssssiblingsssss isssss hardly asssss important asssss oursssss.", "Demo? Ahh what a lovely name. I ssssensssse great sssstrength."},
			[CHARACTER_IRIS] = {"Your breed of ssssiblingsssss isssss hardly asssss important asssss oursssss.", "Irisssss? You're doing thissss to mock me, aren't you?"},
			[CHARACTER_RAOCOW] = {"I ssssensssse you come from ssssome disssstant landssss...", "You sssseeem ssssomewhat confussssed.", "Hmm. Raocow? What an unusssual name..."},
			[CHARACTER_KOOD] = {"Ahh, you ssssseem to be sssssomeone of hidden depthssss.", "Kood? I sssssenssse you may be ssssomeone important ssssomeday."},
			[CHARACTER_SHEATH] = {"Ahh, there you are.", "Sssssheath. A difficult name for a difficult perssssson."},
		}
		intro = rng.irandomEntry(table.append(introlist[player.character], {"Ahhhhh, my favourite cusssstomer."}));
		
		intro = intro.."<page>Can I interesssst you in my waressss? Jussst "..price.." food."
	end
	SaveData.spokenToSteve = true;

	local vcs = {};
	for i = 1,5 do
		table.insert(vcs, "../sound/voice/steve/0"..i..".ogg")
	end
	
	local bubble = message.showMessageBox {target=npc, x=npc.x,y=npc.y, text=intro, closeWith="prompt", voice="steve", voiceclip=vcs}
	message.waitMessageDone()
	
	scene.displayFoodHud(true);
	message.showPrompt()
	message.waitPrompt()
	
	while (not bubble.deleteMe) do
		eventu.waitFrames(0)
	end
	
	local shouldBuy = false;
	
	if  message.promptChoice == 1  then
		if(GLOBAL_LIVES >= price) then
			GLOBAL_LIVES = GLOBAL_LIVES - price;
			bubble = message.showMessageBox {target=npc, x=npc.x,y=npc.y, text="Thankssss for your patronage.", voice="steve", voiceclip=vcs}
			shouldBuy = true;
		else
			bubble = message.showMessageBox {target=npc, x=npc.x,y=npc.y, text="Ah it sssseemssss you don't have enough food.<page>Come back when you have acquired sssssome more.", voice="steve", voiceclip=vcs}
		end
	else
		bubble = message.showMessageBox {target=npc, x=npc.x,y=npc.y, text="Well then. Don't hessssitate if you change your mind.", voice="steve", voiceclip=vcs}
	end
	eventu.waitFrames(64)
	scene.displayFoodHud(false);
	
	while (not bubble.deleteMe) do
		eventu.waitFrames(0)
	end
	
	if(shouldBuy) then
			local npc = NPC.spawn(rng.irandomEntry{9, 9, 14, 14, 34, 34, 264, 264, 90, 188, 169, 170, 10, 35, 191, 293}, npc.x + npc.width*0.5 + npc.direction * 16, npc.y, player.section);
			npc.x = npc.x - npc.width*0.5;
			spawnSmoke(npc.x+npc.width*0.5, npc.y + npc.height*0.5)
			npc.speedY = -2;			
			if(npc.id == 10) then
				npc.ai1 = 1;
			elseif(npc.id == 34) then
				npc.speedY = 0;
			end
			npc.dontMove = true;
	end
	scene.endScene()
	message.endMessage();
end

message.presetSequences.shopItem = function(args)
	local npc = args.npc;
	local shopkeep = npc.data.shopkeep;
	
	local x,y = shopkeep.x+shopkeep.width*0.5, shopkeep.y;
	--[[
	local cam = cman.playerCam[1];
	local wid,hei = 128,96;
	x = math.max(math.min(x, cam.left+cam.zoomedWidth-wid),cam.left+wid);
	y = math.max(math.min(y, cam.top+cam.zoomedHeight-hei),cam.top+hei);]]
	
	local bubble;
	local dialog = a2xt_shops.dialogue[shopkeep.type];
	if(shopkeep.type ~= "stable" or player.character == CHARACTER_MARIO  or  player.character == CHARACTER_LUIGI)  then
		if(player:mem(0x108, FIELD_WORD) > 0) then
			bubble = message.showMessageBox {target = shopkeep, text=dialog.alreadyriding[player:mem(0x108, FIELD_WORD)], keepOnscreen = true}
		else
			local ispowerupshop = shopkeep.type == "powerup";
			local confirmVal = ispowerupshop and npc.data.generator;
			if(confirmVal) then
				confirmVal = 2;
			else
				confirmVal = 1;
			end
			
			local itemid = npc.id;
			if(ispowerupshop and npc.data.random) then
				itemid = 287;
			end
			
			local itemname;
			if(shopkeep.type == "costume") then
				itemname = costumes.data[npc.data.costume].name;
			else
				itemname = dialog.items[itemid];
			end
			
			local confirmtxt;
			if(shopkeep.type == "costume") then
				if(SaveData.costumes[npc.data.costume]) then
					confirmtxt = dialog.confirm[2];
				else
					confirmtxt = dialog.confirm[1];
				end
			else
				confirmtxt = dialog.confirm[confirmVal];
			end
			
			local confirmMessage = a2xt_shops.parse(confirmtxt, itemname, npc.data.price)
			
			
			if(shopkeep.type == "costume" and SaveData.costumes[npc.data.costume]) then
				bubble = message.showMessageBox {target = shopkeep, text=confirmMessage, keepOnscreen = true}
			else
				scene.displayRaocoinHud(true);
				bubble = message.showMessageBox {target = shopkeep, text=confirmMessage, closeWith="prompt", keepOnscreen = true}
				message.waitMessageDone ()
				message.showPrompt ()
				message.waitPrompt ()
				
				if(message.promptChoice == 1)  then
					if(raocoins.buy(npc.data.price)) then
						local buyindex = nil;
						if(shopkeep.type == "costume" and playerIsMale()) then
							buyindex = 2;
						end
						bubble = message.showMessageBox {target = shopkeep, text=getText(dialog.buy, buyindex), keepOnscreen = true}
						message.waitMessageEnd ()
						if(shopkeep.type == "stable") then
							player:mem(0x108,FIELD_WORD,3);
							player:mem(0x10A,FIELD_WORD,stable_npc_to_mount[npc.id])
							changePlayerState();
						elseif(shopkeep.type == "powerup") then
							if(npc.data.generator) then
								spawnSmoke(npc.x+npc.width*0.5,npc.y+npc.height*0.5)
								buygenerator(npc);
							else
								local id = npc.id;
								if(npc.data.random) then
									local val = rng.randomInt(0,powerup_shop_lucky_total_prob);
									for k,v in pairs(powerup_shop_lucky_chances) do
										val = val - v;
										if(val <= 0) then
											id = k;
											break;
										end
									end
								end
								NPC.spawn(id, player.x, player.y, player.section);
							end
						elseif(shopkeep.type == "costume") then
							spawnSmoke(npc.x+npc.width*0.5,npc.y+npc.height*0.5);
							rewards.give{type="costume", quantity=npc.data.costume, wait=true};
						end
					else
						raocoins.set(100); --debug to give me free raocoins
						bubble = message.showMessageBox {target = shopkeep, text=dialog.notenough, keepOnscreen = true}
					end
				else
					bubble = message.showMessageBox {target = shopkeep, text=getText(dialog.nodeal), keepOnscreen = true}
				end
			end
			message.waitMessageEnd ()
			scene.displayRaocoinHud(false);
		end
	else
		bubble = message.showMessageBox {target = shopkeep, type="bubble", text=dialog.notallowed[player.character], keepOnscreen = true}
	end
	while (bubble and not bubble.deleteMe) do
		eventu.waitFrames(0)
	end
	
	scene.endScene()
	message.endMessage();
end


--***************************
--** Coroutines            **
--***************************



--***************************
--** Events                **
--***************************
local shopItems = {};

function a2xt_shops.onInitAPI()
	registerEvent(a2xt_shops, "onStart");
	registerEvent(a2xt_shops, "onTick");
	registerEvent(a2xt_shops, "onTickEnd");
	registerEvent(a2xt_shops, "onDraw");
end

function a2xt_shops.onStart()
	for _,v in ipairs(NPC.get()) do
		v = pnpc.getExistingWrapper(v);
		if(v and v.data.event and a2xt_shops.settings[v.data.event]) then
			for _,w in ipairs(NPC.get(a2xt_shops.settings[v.data.event].ids, v:mem(0x146, FIELD_WORD))) do
				local isagenerator = w:mem(0x64,FIELD_BOOL);
				w:mem(0x64,FIELD_BOOL,false);
				w = pnpc.wrap(w);
				if(isagenerator) then
					w.data.generator = true;
					v.data.hasGenerator = true;
				end
				w.data.event = "shopItem";
				w.data.talkIcon = 4;
				if(v.data.event == "costume") then
					w.data.price = a2xt_shops.settings[v.data.event].prices[w.data.costume];
				else
					w.data.price = a2xt_shops.settings[v.data.event].prices[w.id].buy;
				end
				w.data.shopkeep = {x = v.x, y = v.y, width = v.width, height = v.height, type=v.data.event};
				w.data.spawnPos = {x = w.x, y = w.y}
				if(v.data.event == "stable") then
					w.animationTimer = rng.randomInt(0,90);
					w.data.iconOffset = 32;
				elseif(v.data.event == "powerup") then
					powerup_shop_section = v:mem(0x146, FIELD_WORD);
					w.dontMove = true;
					w.data.height = w.height;
					w.height = 64;
					if(w.id == 287) then
						w.data.random = true;
						w.data.ticker = 0;
						w.data.visibleid = 9;
						w.friendly = true;
					end
					if(w.data.generator) then
						table.insert(powerup_shop_generator_markers, {x = w.x, y = w.y});
						if(SaveData.powerupshop and SaveData.powerupshop.generators and SaveData.powerupshop.generators[tostring(w.id)]) then
							buygenerator(w);
						else
							w.data.price = w.data.price * 3;
						end
					end
				elseif(v.data.event == "costume") then
					w.dontMove = true;
					w.data.height = w.height;
					w.height = w.height+32;
					w.data.y = w.y;
				end
				table.insert(shopItems, w);
			end
		end
	end
end

function a2xt_shops.onTick()
	for _,v in ipairs(shopItems) do
		if(v.isValid) then
			v.speedX = 0;
			v.speedY = 0;
			v.x = v.data.spawnPos.x;
			v.y = v.data.spawnPos.y;
			if(v.data.random) then
				v.id = 273;
			end
		end
	end
end

function a2xt_shops.onTickEnd()
	if(player.section == powerup_shop_section and SaveData.powerupshop and SaveData.powerupshop.generators) then
		local py = player.y + player.height;
		 for k,_ in pairs(SaveData.powerupshop.generators) do
			for _,v in ipairs(NPC.get(tonumber(k),powerup_shop_section)) do
				local w = pnpc.getExistingWrapper(v);
				if((w == nil or w.data.shopkeep == nil) and not v:mem(0x64,FIELD_BOOL)) then
					v.x = v:mem(0xA8, FIELD_DFLOAT);
					v.y = v:mem(0xB0, FIELD_DFLOAT);
					v.speedX = 0;
					v.speedY = 0;
					if(v:mem(0x138, FIELD_WORD) > 0) then --freshly spawned
						spawnSmoke(v.x+v.width*0.5, v.y + v.height*0.5);
					end
					v.friendly = py > (v.y + v.height + 16);
				end
			end
		 end
	end
end

local function pickNewRandom(current,list)
	local t = {};
	for _,v in ipairs(list) do
		if(v ~= current) then
			table.insert(t, v);
		end
	end
	return rng.irandomEntry(t);
end

function a2xt_shops.onDraw()
	for _,v in ipairs(shopItems) do
		if(v.isValid and player.section == v:mem(0x146, FIELD_WORD)) then
			if(v.data.shopkeep.type == "powerup") then
				v.animationFrame = -1;
				v.height = 64;
				local id = v.id;
				if(v.data.random) then
					if(v.data.ticker == 0) then
						v.data.visibleid = pickNewRandom(v.data.visibleid, powerup_shop_lucky_ids);
						v.data.ticker = 8;
					else
						v.data.ticker = v.data.ticker - 1;
					end
					id = v.data.visibleid or 9;
				end
				Graphics.drawImageToSceneWP(Graphics.sprites.npc[id].img, v.x, v.y, 0, 0, v.width, v.data.height, -45);
			elseif(v.data.shopkeep.type == "costume") then
				v.height = v.data.height+32;
				v.y = v.data.y;
			end
		end
	end
	
	for _,v in ipairs(powerup_shop_generator_markers) do
		Graphics.drawImageToSceneWP(img_powerup_generator, v.x, v.y+32, -45);
	end
end

return a2xt_shops