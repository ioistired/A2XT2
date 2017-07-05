function onLoop()
	if (Player(1).section==1) then
		local lavaSplashes = Animation.get(13)
		for k,v in pairs(lavaSplashes) do
			v.x = 0
			v.y = 0
		end
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
	_G["ManualTitle"] = nil
	_G["ManualArtist"] = nil

end
funtion onLoadSection3()
	_G["ManualTitle"] = nil
	_G["ManualArtist"] = nil

end