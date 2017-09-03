

function onEvent(eventName)
	-- Train start sound
	if (eventName=="Train_Prepare (snd start)") then
		playSFX("train-start.ogg");
	end
	-- Train ridnig sound
	if (eventName=="Train11 (snd ride)") then
		playSFX("train-ride.ogg");
	end
	-- Train stop sound
	if (eventName=="TrainS1 [do slow speed] (snd stop)") then
		playSFX("train-stop.ogg");
	end
end

funtion onLoadSection0()
	_G["ManualTitle"] = "Subway"
	_G["ManualArtist"] = "Wohlstand"
end
funtion onLoadSection1()
	_G["ManualTitle"] = nil
	_G["ManualArtist"] = nil

end
funtion onLoadSection2()
	_G["ManualTitle"] = "Minstrel's Song (FM Remake)"
	_G["ManualArtist"] = "Wohlstand"
end
funtion onLoadSection3()
	_G["ManualTitle"] = "Subway"
	_G["ManualArtist"] = "Wohlstand"
end
funtion onLoadSection4()
	_G["ManualTitle"] = "Minstrel's Song (FM Remake)"
	_G["ManualArtist"] = "Wohlstand"
end
funtion onLoadSection5()
	_G["ManualTitle"] = "Minstrel's Song (FM Remake)"
	_G["ManualArtist"] = "Wohlstand"
end
funtion onLoadSection6()
	_G["ManualTitle"] = "Minstrel's Song (FM Remake)"
	_G["ManualArtist"] = "Wohlstand"
end