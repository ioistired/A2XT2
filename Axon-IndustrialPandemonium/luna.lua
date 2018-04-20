function onTick()
	if (player.section == 1) then
		for k,v in ipairs(Animation.get(13)) do
			v.x = 0
			v.y = 0
		end
	end
end

function onLoadSection0()
	_G["ManualTitle"] = "Subway"
	_G["ManualArtist"] = "Wohlstand"
end
function onLoadSection1()
	_G["ManualTitle"] = nil
	_G["ManualArtist"] = nil

end
function onLoadSection2()
	_G["ManualTitle"] = nil
	_G["ManualArtist"] = nil

end
function onLoadSection3()
	_G["ManualTitle"] = nil
	_G["ManualArtist"] = nil

end