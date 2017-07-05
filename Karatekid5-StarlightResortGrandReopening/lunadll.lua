--cinematX = loadSharedAPI("cinematX")

--cinematX.configExt ({hudBox=false, overrideNpcText=true, imageUi=false, textbloxSub=true})

--function scene_1 ()
--   local belActor1 = cinematX.getActorFromKey ("bellossom1")
--   Text.print("The routine is running",12,12)
--   cinematX.startDialogExt ("Hello there! Welcome to the Starlight Resort!", {actor=belActor1, name="Bellossom"})
--   cinematX.waitForDialog()
--end

--{key=bellossom1, name=Bellossom, routine=scene_1}

function onLoop()
  allNPCs = findnpcs(30,player.section)
  for k,v in pairs(allNPCs) do
   if(v.speedY < -2) then
      v.speedY = -3
   end
  end   
end 

function onEvent(eventName)
   if (eventName =="First Detonator") then
		playSFX("katamari.ogg");
                Audio.MusicVolume(12)
	end
   if (eventName =="Second Detonator") then
		playSFX("katamari.ogg");
                Audio.MusicVolume(12)
	end
  if (eventName =="SwitchFailed") then
                Audio.MusicVolume(51)
	end
end
