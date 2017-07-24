local npcManager = API.load("npcManager")
local textblox = API.load("textblox")
local animatx = API.load("animatx")
local cman = API.load("cameraman")
local eventu = API.load("eventu")
local imagic = API.load("imagic")
local pnpc = API.load("pnpc")
local rng = API.load("rng")

local scene = API.load("a2xt_scene")
local message = API.load("a2xt_message")

local a2xt_shops = {}

--***************************
--** Variables             **
--***************************
a2xt_shops.settings = {
                       stable    = {   
                                    buyprices  = {2,4,4,4,8,6,6,6},
                                    sellprices = {1,2,2,2,4,3,3,3},
                                    selection  = {1,2,3},
                                   }
                      }
a2xt_shops.dialogue = {
                       stable    = {
                                    options = {
                                               {"I'd like to rent out a catllama.", "What do you do here?", "I've got places to be."},
                                               {"I'm ready to return her.", "Can I hear the sales pitch again?", "I need more time with this majestic creature."},
                                               {"You interested in buying?", "...What's your angle?", "NO YOU CAN'T HAVE HER"}
                                              },
                                    items = {"Common Verdegris","Azure Skyhowler","Whiffing Honeyjackal","Norwegian Pyrelynx","Flaminguanaco","Grizzlpaca","Sandy Meatcamel","Siberian Frostchucker"},
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
                                    options = {""},
                                    items = {"Red Radish","Spinach Leaf"},
                                    welcome = "",
                                    about = "",
                                    peruse = "",
                                    buy = "",
                                    notenough = "",
                                    goodbye = "" 
                                   },

                       costume   = {
                                    options = {""},
                                    welcome = "",
                                    about = "",
                                    peruse = "",
                                    buy = "",
                                    notenough = "",
                                    goodbye = ""  
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
	local newStr = string.gsub(str, "%[price%]", tostring(amount).."rc")
	return newStr;
end
local function addItem (str, item)
	local newStr = string.gsub(str, "%[item%]", item)
	return newStr;
end
function a2xt_shops.getItemPromptList (ids, names, prices)
	local options = {}
	for  i=1,#ids  do
		local id = ids[i]
		options[i] = names[id].." ("..tostring(prices[id]).."rc)"
	end
	return options
end

--***************************
--** Sequences             **
--***************************
message.presetSequences.catnipStable = function(args)
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
				local options = a2xt_shops.getItemPromptList(settings.selection, dialog.items, settings.buyprices)
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
							local catllamaPicked = settings.selection[message.promptChoice]
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




--***************************
--** Coroutines            **
--***************************



--***************************
--** Events                **
--***************************


return a2xt_shops