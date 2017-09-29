local leveldata = API.load("a2xt_leveldata")
local archives  = {}


--**********************
--**  CHARACTER BIOS  **
--**********************
local bios = {
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
                         },
                   },
              raocow={
                      name="Raocow",
                      bios={
                            [0]={
                                 aliases  = "Tamuel Sanguay, Post-Production Raocow (PPR)",
                                 species  = "Human",
                                 likes    = "most animals (especially cats, ducks, sheep and cows), video games, goofing off, naming gimmicks, memes, anime, the Soviet anthem",
                                 dislikes = "mentally-deficient equines, strong winds, building bridges, savestate abuse, bones",
                                 info     = "A human from a sister universe that was pulled into this one through a freak computer accident.  Bizarrely, this universe seems to be a fictional work of the subject's own conception in the universe he came from.  We left the existential quandaries this fact raises for Tom to puzzle over, should keep him out of our figurative hair for a few days.<page>Subject was at a picnic hosted by blah blah blah look I don't want to type up this same stuff again so just take what we wrote for the last three entries and apply it to this one, okay?"
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
                                }
                           }
                     },
              pal={
                   name="Pal",
                   bios={
                         [0]={
                              aliases  = "Why would a dog have aliases?",
                              species  = "Canis lupus familiaris (breed = laundromutt)",
                              likes    = "Demo, bones, digging",
                              dislikes = "Iris, catllamas, penguins",
                              info     = "Demo's pet dog.  Subject is perfectly adorable and as such no further investigation about his origins or identity is necessary."
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
                                 info     = "Since the previous entry was written, subject reappeared under the influence of a much more significant villain and helped said villain manifest a physical form.  Is probably still floating around in the shadowspace somewhere."
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
             }



--****************************
--**  API MEMBER FUNCTIONS  **
--****************************

function archives.IsCharUnlocked(key)
	local data = bios[key].bios
	local i=0
	local endResult = false

	for i = 0,10 do
		if  data[i] ~= nil  and  SaveData["world"..i].superleek  then
			endResult = true;
			break;
		end
	end

	return endResult
end

function archives.GetBioString(key)
	local strings = {}
	local isUnlocked = false

	local data = bios[key].bios
	for  i=0,10  do

		-- Only append the strings if any exist and the corresponding world has been cleared
		if  data[i] ~= nil  and  SaveData["world"..i].superleek  then

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

		finalString = bios[key].name .. "<br>ALIASES: " .. strings.aliases .. "<br>SPECIES: " .. strings.species .. "<br>INTERESTS: " .. strings.likes .. "<br>DISLIKES: " .. strings.dislikes .. "<page>" .. strings.info
	end
	return finalString;
end

function archives.GetUnlockedBios()
	local nameArray   = {}
	local stringArray = {}

	for  _,v in ipairs {"demo","iris","kood","raocow","sheath","pal","tam","feed","steve","noctel","tom"}  do
		if  archives.IsCharUnlocked(v)  then
			nameArray[#nameArray+1]     = bios[v].name
			stringArray[#stringArray+1] = archives.GetBioString(v)
		end
	end

	return nameArray,stringArray
end

return archives;