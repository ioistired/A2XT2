local leveldata = API.load("a2xt_leveldata")
local hud = API.load("a2xt_hud")
local archives  = {}


--**********************
--**  CHARACTER BIOS  **
--**********************
if  SaveData.biosRead == nil  then
	SaveData.biosRead = {
		characters={},
		species={},
		locations={},
		events={}
	}
end

local bios = {
	characters={
		ORDER={"demo","iris","kood","raocow","sheath","pal","artist","tam","feed","steve",
		       "noctel","garish","brisket","alabasta","mishi","science","pily","broadsword",
		       "pandamona","calleoca","atsbestos","nevada","denmark","rewind","pumpernickel",
		       "serac","tom"},
		PROPS={aliases=1,species=1,likes=1,dislikes=1,info=1},
		demo={
			name="Demo Roseclair",
			bios={
				[0]={
					aliases  = "The Lone Wanderer",
					species  = "ABCD (cloned)",
					likes    = "vegetables, classical music, dancing, calm scenery, cats and dogs, bar mitzvahs",
					dislikes = "complication, exposition",
					info     = "The culmination of the Artist's efforts to create the ultimate ABCD minions, a distinction shared by her twin sister Iris. Escaped the Artist's brainwashing and came to work for a Space Master of Space, later freeing their siblings from the Artist's control.<page>Subject was hosting a picnic with immediate family and traveling associates prior to the timestream's collapse.  Seems to have partially absorbed the memories of the Demo from Sheath's universe upon Sheath's arrival."
				},
				[2]={
					info     = "So THAT'S where our notes on ABCD biology went!  Who's the moron who put them in the Glaciation Epoch, and right in the path of the subject and company too?  You don't give people spoilers about their future, that's like, Time Travel 101!  Was it Tom from Accounting?  I bet it was Tom.  That jerk.",
				},
				[3]={
					likes    = "her Uncle Broadsword",
				},
			},
		},
		iris={
			name="Iris Roseclair",
			bios={
				[0]={
					aliases  = "Too many aliases to list here",
					species  = "ABCD (cloned)",
					likes    = "vegetables, knives, catllamas",
					dislikes = "exposition, Kood",
					info     = "The culmination of the Artist's efforts to create the ultimate ABCD minions, a distinction shared by her twin sister Demo. Escaped the Artist's brainwashing and came to work for a Space Master of Space, later freeing their siblings from the Artist's control.<page>Subject was hosting a picnic with immediate family and tolerated associates prior to the timestream's collapse.  Seems to have partially absorbed the memories of the Iris from Sheath's universe upon Sheath's arrival."
				},
				[2]={
					info     = "Oh, come on Tom, this one too?  Stop telling the subjects their futures, it just makes more work for everyone down at Memory Management!",
				},
			},
		},
		kood={
			name='Koodington "Kood" Shellmeyer',
			bios={
				[0]={
					aliases  = "Agen K, Jimmy the Jackal, Mr. Mutton Chops, Debbie, Not Kood",
					species  = "Koopa",
					likes    = "conspiracies, drama, mystery, validation, Demo, Pily",
					dislikes = "Iris, skipping the plot",
					info     = "Claims to be an intergalactic freedom fighter.  Former cohort of notorious intergalactic crime lord Luigi Mario, started stalking Demo and Iris until they accepted him as a lackey/meat shield.  Eventually entered a romantic relationship with their sister Pily.<page>Subject was at a picnic hosted by Demo and Iris prior to the timestream's collapse.  Seems to have partially absorbed the memories of the Kood from Sheath's universe upon Sheath's arrival."
				},
				[4]={
					likes    = "Uncle @sbestos"
				},
				[9]={
					info     = "All personnel are to immediately report any suspicious activity by the subject or other observations potentially linking him to the Artist."
				}

			},
		},
		raocow={
			name="Raocow",
			bios={
				[0]={
					aliases  = "Tamuel Sanguay, Post-Production Raocow (PPR)",
					species  = "Human (Canadian)",
					likes    = "most animals (especially cats, ducks, sheep and cows), video games, goofing off, naming gimmicks, memes, anime, the Soviet anthem",
					dislikes = "mentally-deficient equines, strong winds, building bridges, savestate abuse, bones",
					info     = "A human from a sister universe that was pulled into this one through a freak computer accident.  Bizarrely, this universe seems to be a fictional work of the subject's own conception in the universe he came from.  We left the existential quandaries this fact raises for Tom to puzzle over, should keep him out of our figurative hair for a few days.<page>Subject was at a picnic hosted by blah blah blah look I don't want to type up this same stuff again so just take what we wrote for the last three entries and apply it to this one, okay?"
				},
				[9]={
					info     = "All personnel are to immediately report any suspicious activity by the subject or other observations potentially linking him to the Artist."
				}
			},
		},
		sheath={
			name="Sheath",
			bios={
				[0]={
					aliases  = "someone who's read through ATXS completely fill this in please kthx",
					species  = "Human",
					likes    = "same as aliases",
					dislikes = "ditto",
					info     = "A hyperactive sixteen-year-old girl with several anomalous abilities -- uses her hair as a whip, capable of retroactively being there too (whatever that means) and harbors a mystifying ability to nullify even fatal damage by forgetting it.  Latter power currently seems to be lying dormant;  Tom from Accounting believes it is a subconscious choice of hers to suppress the power, but that's why he's in Accounting and not Research.<page>Subject originated from a separate universe and carried an unknown turtle dove-shaped artifact seemingly capable of bridging and synchronizing realities. Given that the only known use of said artifact seemingly resulted in the destruction of this universe, it should be confiscated at the earliest convenience."
				},
				[3]={
					info     = "After careful analysis, the turtle dove appears to be linked to an aborted timeline.  We can only speculate as to what purpose it would have served, but Tom insists it would likely have been used in a convoluted cyclical plot to ferry time duplicates outside of reality using a ship constructed from the remains of dead gods. I strongly advise management to reduce Tom's alloted time in the Anime Room."
				},
				[9]={
					info     = "All personnel are to immediately report any suspicious activity by the subject or other observations potentially linking her to the Artist."
				}

			}
		},
		pal={
			name="Pal",
			bios={
				[0]={
					aliases  = "Why would a dog have aliases?",
					species  = "Canis lupus familiaris (Laundromutt)",
					likes    = "Demo, bones, digging",
					dislikes = "Iris, catllamas, penguins",
					info     = "Demo's pet dog.  Subject is perfectly adorable and as such no further investigation about his origins or identity is necessary."
				}
			}
		},
		artist={
			name="The Artist",
			bios={
				[0]={
					aliases  = "???",
					species  = "???",
					likes    = "???",
					dislikes = "???",
					info     = "The mysterious creator of Demo, Iris and their siblings.  Subject used brainwashing to keep his creations under his control and after Demo and Iris broke free of it, he sent the siblings out to retrieve them.  Subject's identity is unknown;  even the siblings could not recall his voice or appearance when questioned, despite having taken orders directly from him while under his control (perhaps by design to prevent them from revealing him in the event the mind control failed?)<page>Subject's ultimate goals are also uncertain, but has been acknowledged as \"pretty evil\" by his creations while brainwashed.  As such, he is considered a Person of Interest and any new information about his whereabouts or true identity should be brought to upper management's attention ASAP."
				},
				[9]={
					info     = "Following up on a recent potential lead, all personnel are to investigate any and all associates of Demo and Iris."
				}
			}
		},
		tam={
			name="Tam",
			bios={
				[0]={
					aliases  = "none",
					species  = "Chronoton",
					likes    = "puns",
					dislikes = "tough crowds",
					info     = "Head of the P.O.R.T.S. PR department and an esteemed colleague of this researcher.  Subject's distinctive wind-up gear makes for a good icebreaker at parties.  Absolutely no relation whatsoever to Tom (thankfully)."
				}
			}
		},
		feed={
			name="Feed",
			bios={
				[0]={
					aliases  = "Stephen",
					species  = "Human",
					likes    = "",
					dislikes = "",
					info     = "An intelligent young girl who seems to be capable of teleportation.  Subject never goes anywhere without her pet, Orbit, and seems determined to feed Sheath's meat to him so he may obtain her regenerative powers."
				}
			}
		},
		steve={
			name="Steve",
			bios={
				[0]={
					aliases  = "Steven, Stevie, Stefan",
					species  = "???",
					likes    = "food",
					dislikes = "???",
					info     = "A mysterious merchant who trades random items for food.  Subject creeps this researcher out, pretty sure he kidnaps puppies or something.  Do business with him at your own risk."
				}
			}
		},
		noctel={
			name='"Grand High Ingoopitor" Noctel',
			bios={
				[0]={
					aliases  = "Darth Goopa, Slime Shady, Batflan, Edgy McEdgepants",
					species  = "Goopa",
					likes    = "bombs, sunglasses, himself",
					dislikes = "croquet, croquettes, crowbars, croaking, crock pots, crocs",
					info     = "The head of a secret criminal organization involved in furba poaching and illegal goonetic experimentation... but otherwise just another goopa guy.  Subject was driven out his headquarters and will probably never be seen again ever."
				},
				[3]={
					info     = "You'd think we'd know better than to tempt fate by now!  Subject reappeared under the influence of a much more significant villain and helped said villain manifest a physical form.  Current location unknown, may still be floating around in the shadowspace somewhere."
				}
			},
		},
		garish={
			name=[[Garish "Johnson" McCain]],
			bios={
				[3]={
					aliases  = "none",
					species  = "ABCD (Cloned)",
					likes    = "Himself, Ayn Rand, french fries, power, war",
					dislikes = "Communism",
					info     = ""
				}
			}
		},
		brisket={
			name="Brisket",
			bios={
				[3]={
					aliases  = "none",
					species  = "Goopa?",
					likes    = "Garish, chivalry, fashion, swashbucklers",
					dislikes = "Poor hygeine, catllamas",
					info     = ""
				}
			}
		},
		alabasta={
			name="Alabasta",
			bios={
				[3]={
					aliases  = "none",
					species  = "Goopa?",
					likes    = "Garish, chivalry, fashion, swashbucklers",
					dislikes = "Poor hygeine, catllamas",
					info     = ""
				}
			}
		},
		mishi={
			name=[[Mishi Verahcen-Duchamp]],
			bios={
				[3]={
					aliases  = "none",
					species  = "ABCD (Cloned)",
					likes    = "Nihilism, John Lennon, furniture, being alone",
					dislikes = "Family, Calleoca's fanfics, the world",
					info     = ""
				}
			}
		},
		science={
			name=[[Science Fiction]],
			bios={
				[3]={
					aliases  = "none",
					species  = "ABCD (Cloned)",
					likes    = "Authority, respect, knowledge, intellect, technology, savestates",
					dislikes = "Insubordination, interruptions, inanity",
					info     = ""
				},
				[4]={
					info     = ""
				}
			}
		},
		pily={
			name=[[Pily Wataharu]],
			bios={
				[3]={
					aliases  = "none",
					species  = "ABCD (Cloned)",
					likes    = "Kood, exposition, fire, lava, heat",
					dislikes = "That dastardly government",
					info     = ""
				}
			}
		},
		broadsword={
			name=[[Augustus Leopold Broadsword III Esq.]],
			bios={
				[3]={
					aliases  = "Uncle Broadsword",
					species  = "ABCD (OG)",
					likes    = "Adventure, swords, Demo",
					dislikes = "Poor sportsmanship, stick-in-the-muds, worrywarts",
					info     = ""
				},
				[6]={
					likes    = "Iris"
				}
			},

		},
		pandamona={
			name=[[Pandamona Tyson]],
			bios={
				[8]={
				aliases  = "none",
				species  = "ABCD (Cloned)",
				likes    = "Boxes, conquest, destruction",
				dislikes = "The Artist, mind control, the Universe Thing",
				info     = ""
				}
			}
		},
		calleoca={
			name=[[Calleoca Akibake]],
			bios={
				[8]={
				aliases  = "Rumia",
				species  = "ABCD (Cloned)",
				likes    = "Japan, anime, manga, sushi, pocky, ninjas, cosplay, imports, AMVs, MADs, Touhou, kanji, yaoi, mahou, senpai, desu, penguins",
				dislikes = "Baka gaijin, live action TV, funko pops",
				info     = ""
				}
			}
		},
		atsbestos={
			name=[[Eugene Horatio @sbestos]],
			bios={
				[8]={
					aliases  = "Uncle @sbestos, The Harmless One",
					species  = "ABCD (OG)",
					likes    = "Paperwork, good deals, being acknowledged",
					dislikes = "People who chew gum with their mouths open",
					info     = ""
				}
			}
		},
		nevada={
			name=[[Nevada Artenisia]],
			bios={
				[8]={
					aliases  = "none",
					species  = "ABCD (Cloned)",
					likes    = "Plants, meat, the Flesh Lord",
					dislikes = "Vegetarians",
					info     = ""
				}
			},
		},
		denmark={
			name=[[Robert "Bobby" Denmark]],
			bios={
				[8]={
					aliases  = "Uncle Denmark",
					species  = "ABCD (OG)",
					likes    = "Money, swimming, parties, competition, himself, boring stuff",
					dislikes = "Poor sportsmanship, stingy people, stick-in-the-muds, worrywarts, @sbestos",
					info     = ""
				}
			},
		},
		rewind={
			name="Regulus Rolex Rewind",
			bios={
				[8]={
					aliases  = "Uncle Rewind",
					species  = "ABCD (OG)",
					likes    = "Leeks, ABCDs",
					dislikes = "Cloned ABCDs, @sbestos",
					info     = ""
				}
			},
		},
		pumpernickel={
			name="Maximillion Pumpernickel",
			bios={
				[8]={
					aliases  = "Uncle Pumpernickel",
					species  = "AQCD",
					likes    = "Chaos",
					dislikes = "Order, rationality, @sbestos",
					info     = ""
				}
			},
		},
		serac={
			name="Serac",
			bios={
				[10]={
					aliases  = "???",
					species  = "???",
					likes    = "death",
					dislikes = "Demo...?",
					info     = "<garbage 20>"
				}
			},
		},
		tom={
			name="Tom",
			bios={
				[0]={
					aliases  = "none",
					species  = "Chronoton",
					likes    = "making everyone's lives more difficult",
					dislikes = "probably kittens",
					info     = "A big dumb jerk. Don't ever lend him money.<page>DISREGARD THAT LAST ENTRY TOM IS REALLY REALLY AWESOME AND YOU CAN TOTALLY TRUST HIM WITH YOUR FINANCES"
				}
			},
		},
	},

	species={
		ORDER={"abcd","aqcd","chronoton","human","koopa","charlie","catllama","furba","goopa","paragoopa","bananasnake","shamansnake","catfish","wizard","paralars","fawriel","rose","rabbit","submarine","dogbone"},
		PROPS={family=1,intellect=1,diet=1,squishable=1,info=1},
		abcd={
			name="Armless Bipedal Cycloptic Demon (ABCD)",
			bios={
				[0]={
					family     = "Space Demon",
					intellect  = "Sentient",
					diet       = "Varies, typically vegetarian by preference",
					squishable = "Varies",
					info       = "Beyond the titular characteristics, individuals may differ drastically in appearance and biology but commonly exhibit the following traits: susceptibility to mind control, food-based empowerment and near-limitless regeneration from death."
				},
				[2]={
					info       = "While external appearance varies greatly, nearly all -- finish based on the stuff said in This Level is Canon"
				},
				[3]={
					info       = "All ABCDs alive today are artificial;  natural ABCDs were driven to extinction after being enslaved by the Space Masters of Space."
				},
				[4]={
					info       = "Disregard the previous entry, "
				}
			}
		},
		aqcd={
			name="Armless Quadrupedal Cycloptic Demon (AQCD)",
			bios={
				[8]={
					family     = "Space Demon",
					intellect  = "Sentient",
					diet       = "unknown",
					squishable = "Yes and no",
					info       = "Only one known individual throughout time and said individual was an actively malicious threat to reality."
				}
			}
		},
		chronoton={
			name="Chronoton",
			bios={
				[0]={
					family     = "Automotae",
					intellect  = "Absolute",
					diet       = "Aether",
					squishable = "No",
					info       = "Undeniable perfection."
				}
			},
		},
		human={
			name="Human",
			bios={
				[0]={
					family     = "Hominidae",
					intellect  = "Seemingly sentient",
					diet       = "Varies",
					squishable = "Yes",
					info       = "Weird, fleshy beings resembling Chronotons with smooshed faces and no gears.  Commonly lack solidarity among themselves and are prone to superstition and self-destructive tendencies despite their advanced mortality, but can demonstrate surprising resolve on occasion.  Nevertheless, they are mostly harmless."
				}
			}
		},
		koopa={
			name="Koopa",
			bios={
				[0]={
					family     = "Testudinae",
					intellect  = "Sentient",
					diet       = "Bugs?",
					squishable = "Not easily",
					info       = "."
				}
			}
		},
		charlie={
			name="Charlie",
			bios={
				[0]={
					family     = "Jockinidae",
					intellect  = "Sentient",
					diet       = "Vegetables, protein bars and energy drinks",
					squishable = "Nope",
					info       = "Musclehead humanoids obssessed with sports.  "
				}
			}
		},
		catllama={
			name="Catllama",
			bios={
				[0]={
					family     = "Equiline",
					intellect  = "High",
					diet       = "Omnivorous",
					squishable = "No",
					info       = "A mammal widely domesticated and bred for livestock, transport, and labor.  Though flighty when injured, catllamas can be formidable foes as they are capable of grabbing objects with their long tongues and swallowing them whole."
				}
			}
		},
		furba={
			name="Furba",
			bios={
				[0]={
					family     = "Maneomorph",
					sentient   = "Probably not",
					diet       = "Vegetarian",
					squishable = "Highly",
					info       = "Hairy creatures commonly kept as pets.  Curious, but have a short attention span and terrible object permanence.  Wild furbas secrete a weak toxin from the fur on their face, feet, and sides as a defense mechanism, but tragically never evolved to protect their scalps."
				}
			}
		},
		goopa={
			name="Goopa",
			bios={
				[0]={
					family     = "Gelatinoid",
					sentient   = "Varies",
					diet       = "Omnivorous",
					squishable = "Extremely",
					info       = "Sluglike animals that can develop intellect comparable to humans.  In addition to their corrosive gunk most goopas wear their own eggshells (which coincidentally resemble koopa shells) or other objects such as buckets and hats for additional protection, but some mutate due to unusual diets and develop alternative defense mechanisms.  Their residue slime loses its caustic quality and as such is a common ingredient in household items including dyes, condiments, adhesives, and cleaning solutions."
				}
			}
		},
		paragoopa={
			name="Paragoopa",
			bios={
				[0]={
					family     = "Gelatinoid",
					sentient   = "Yes",
					diet       = "Omnivorous",
					squishable = "Extremely",
					info       = "The typical adult stage of the goopa.  These goopas gain the ability to sprout wings, granting them increased jump height or even, in some cases, flight.  The wings are fragile, but can reform over time."
				}
			}
		},
		bananasnake={
			name="Bananasnake",
			bios={
				[0]={
					family     = "Gelatinoid (Serpentine)",
					sentient   = "Yes",
					diet       = "Omnivorous",
					squishable = "Extremely",
					info       = [[A variant adult stage of the goopa that develops from a potassium-rich diet.  Their bodies solidify into scaly flesh and gain the ability to produce potassium naturally, allowing them to produce and regurgitate projectiles resembling common bananas as a defense mechanism.  The presence of one or more bananasnakes can be discerned by the distinctive "WAK" sounds they make when bored, confused, or excited.]]
				}
			}
		},
		shamansnake={
			name="Shaman Snake",
			bios={
				[0]={
					family     = "Gelatinoid (Armored)",
					sentient   = "Yes",
					diet       = "Omnivorous",
					squishable = "Extremely",
					info       = [[A variant adult stage of the goopa that develops from a calcium-rich diet.  Despite their names, these creatures do not become actual flesh snakes like bananasnakes but instead eject the calcium deposits from their bodies to form a defensive exoskeleton.  Some may throw pieces of this armor as an attack.  Because of both their shells and their resilience and ability to reform, shaman snakes are often mistaken for undead.]]
				}
			}
		},
		catfish={
			name="Catfish",
			bios={
				[0]={
					info       = ""
				}
			}
		},
		wizard={
			name="Wizard",
			bios={
				[0]={
					info       = ""
				}
			}
		},
		paralars={
			name="Paralars",
			bios={
				[0]={
					info       = ""
				}
			}
		},
		fawriel={
			name="Fawriel",
			bios={
				[0]={
					info       = ""
				}
			}
		},
		rose={
			name="Drillrose",
			bios={
				[0]={
					info       = ""
				}
			}
		},
		rabbit={
			name="Rabbit",
			bios={
				[0]={
					info       = ""
				}
			}
		},
		submarine={
			name="Submarine",
			bios={
				[0]={
					info       = ""
				}
			}
		},
		dogbone={
			name="Dogbone",
			bios={
				[0]={
					info       = ""
				}
			}
		},
	},

	locations={
		ORDER={"ports","mushroomkingdom","spaceship","castleofno","erebus"},
		PROPS={info=1},

		ports={
			name="P.O.R.T.(S.)",
			bios={
				[0]={
					info = "This spaceport city exists outside of time and serves as the primary hub of chronoton operations, being the location of the R.E.T.C.O.N.  Bringing up the full name of this place (which is totally the Partition Of Radical TimeStuffs) is strongly discouraged.<page>okay but it's actually the Position of Operations for Repairs To Spacetime"
				},
				[1]={
					info = "You're both wrong, it's the Provisional Office of the Regulatory TechnicianS.<page>I thought we agreed on Place of Resting Time :c<page>Palace Obfuscating Restorative Technology<page>Parliament Obviously Relegating Tautologies<page>Prime Opportunities Relating To Salmon<page>[This thread has been locked.  Contact a system administrator for edit permissions.]"
				}
			}
		},
		mushroomkingdom={
			name="Mushroom Kingdom",
			bios={
				[0]={
					info = "A nation formerly home to a fungus-based monarchy, now the front line of a perpetual war between Yoshi tribe and and Charlie army."
				}
			}
		},
		spaceship={
			name="The Twins' Master's Spaceship",
			bios={
				[0]={
					info = "The primary base of operations of Demo, Iris, and their Master.  Formally recognized as a neutral micro-nation and protected by space law."
				}
			}
		},
		castleofno={
			name="Castle of Absolutely No Significance Whatsoever",
			bios={
				[0]={
					info = "The Castle of No Significance for short.  A large castle on planet Easy Peasy.  Despite its title, the castle is notable for being a frequent target of invasions and robberies.  The Key Boss taking up residence and subsequently getting usurped is a fixed event between different timelines and universes."
				}
			}
		},
		erebus={
			name=[[The Erebus/Shadowspace]],
			bios={
				[3]={
					info = "An ancient prison for powerful beings said to keep its inhabitants captive with supernatural darkness.  In reality this labyrinth serves as a gateway to a side dimension we're tentatively calling shadowspace, which seems to exist somewhere between the universe and the Post-Production Void."
				}
			}
		},
	},

	epochs={
		
	},

	events={
	},

	terms={
	}
}


--****************************
--**  API MEMBER FUNCTIONS  **
--****************************
local bioDebugWorld

function archives.SetBioDebugWorld(value)
	bioDebugWorld = value
end

function archives.GetBioLastWorld(group, key)
	if  bioDebugWorld ~= nil  then
		return bioDebugWorld-1

	else
		local data = bios[group][key].bios
		local top = 0

		for i = 0,10 do
			if  data[i] ~= nil  then
				top = i
			end
		end

		return top
	end
end

function archives.GetBioCurrentWorld(group, key)
	if  bioDebugWorld ~= nil  then
		return bioDebugWorld

	else
		local data = bios[group][key].bios
		local top = 0

		for i = 0,10 do
			if  data[i] ~= nil  and  SaveData["world"..i].superleek  then
				top = i
			end
		end

		return top
	end
end

function archives.BioHasNewInfo(group, key)
	if  SaveData.biosRead[group][key] == nil  then
		return true;
	elseif  archives.GetBioCurrentWorld(key) > SaveData.biosRead[group][key]  then
		return true;
	end
	return false;
end

function archives.UpdateBioReadExtent(group, key)
	SaveData.biosRead[group][key] = archives.GetBioCurrentWorld(group,key)
end

function archives.IsCharUnlocked(group, key)
	local data = bios[group][key].bios
	local endResult = false
	local debugWorld = bioDebugWorld  or  0

	for i = 0,10 do
		if  data[i] ~= nil  and  (SaveData["world"..i].superleek  or  debugWorld > i)  then
			endResult = true;
			break;
		end
	end

	return endResult
end

function archives.GetBioString(group, key)
	local strings = {}
	local isUnlocked = false
	local debugWorld = bioDebugWorld  or  0

	local data = bios[group][key].bios
	for  i=0,10  do

		-- Only append the strings if any exist and the corresponding world has been cleared
		if  data[i] ~= nil  and  (SaveData["world"..i].superleek  or  debugWorld > i)  then

			isUnlocked = true

			-- Go through and append all strings
			for  k,v in pairs (data[i])  do

				-- Copy over new strings
				if  strings[k] == nil  then
					strings[k] = v

				-- Append to existing strings
				else

					-- Append new info as additional pages
					if  k == "info"  then
						strings[k] = strings[k] .. "<page>" .. v

					-- Append other data as part of the same list
					else
						strings[k] = strings[k] .. ", " .. v
					end
				end
			end
		end
	end

	local finalString = nil
	if  isUnlocked  then
		strings.aliases  = strings.aliases   or  "NO ALIASES DEFINED"
		strings.species  = strings.species   or  "NO SPECIES DEFINED"
		strings.likes    = strings.likes     or  "NO LIKES DEFINED"
		strings.dislikes = strings.dislikes  or  "NO DISLIKES DEFINED"
		strings.info     = strings.info      or  "NO INFO DEFINED"

		finalString = "<color yellow>" .. bios[group][key].name .. "<color yellow><br 2>ALIASES: <color default>" .. strings.aliases .. "<color yellow><br>SPECIES: <color default>" .. strings.species .. "<color yellow><br>INTERESTS: <color default>" .. strings.likes .. "<color yellow><br>DISLIKES: <color default>" .. strings.dislikes .. "<page>" .. strings.info
	end
	return finalString;
end

function archives.GetBioProperty(group, key, propName)
	return bios[group][key][propName]
end

function archives.GetUnlockedBios(group)
	local keyArray = {}
	local nameArray   = {}
	local stringArray = {}

	for  _,v in ipairs (bios[group].ORDER)  do
		if  archives.IsCharUnlocked(group,v)  then
			local nameStr = bios[group][v].name
			if  archives.BioHasNewInfo(group,v)  then
				nameStr = CHAR_NEW.." <color blue>"..nameStr.."<color default>"
			end
			keyArray[#keyArray+1]       = v
			nameArray[#nameArray+1]     = nameStr
			stringArray[#stringArray+1] = archives.GetBioString(group,v)
		end
	end

	return keyArray,nameArray,stringArray
end

return archives;