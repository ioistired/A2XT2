local pman = API.load("playerManager")
costumes = {}


--*****************************
--** Costume info            **
--*****************************

local charids = {mario=CHARACTER_MARIO, luigi=CHARACTER_LUIGI, peach=CHARACTER_PEACH, toad=CHARACTER_TOAD, link=CHARACTER_LINK, unclebroadsword=CHARACTER_UNCLEBROADSWORD}

-- Total number of costumes between all characters
costumes.totalNum = 0

-- The costume IDs specific to each character
costumes.charLists = {}

-- Properties for each costume
costumes.info = {}
for  _,v1 in pairs(Misc.listFiles("graphics/costumes"))  do
	for  _,v2 in pairs(Misc.listFiles("graphics/costumes/"..v1))  do
		costumes.totalNum = costumes.totalNum+1
		local cid = charids[v1]

		if  costumes.charLists[cid] == nil  then
			costumes.charLists[cid] = {}
		end
		local charList = costumes.charLists[cid]
		charList[#charList+1] = costumes.totalNum

		local info = {
			path = "graphics/costumes/"..v1.."/"..v2,
			name = v2,
			character = cid
			-- any other properties defined in a text document maybe?
		}
		costumes.info[costumes.totalNum] = info

	end
end


--*****************************
--** Save data management    **
--*****************************

if  SaveData.costumes == nil  then
	SaveData.costumes = {}
end


function costumes.getUnlocked (character)
	local unlocked = {0}
	for  _,v in pairs (costumes.charLists[character])  do
		if  SaveData.costumes[v]  then
			unlocked[#unlocked+1] = v
		end
	end

	return unlocked
end


function costumes.unlock (id)
	SaveData.costumes[id] = true
end


function costumes.wear (id)
	local info = costumes.info[id]
	pman.setCostume(info.character, info.name)
end


return costumes