costumes = {}

--*****************************
--** Costume info            **
--*****************************

local charids = {mario=CHARACTER_DEMO, luigi=CHARACTER_IRIS, peach=CHARACTER_KOOD, toad=CHARACTER_RAOCOW, link=CHARACTER_SHEATH, unclebroadsword=CHARACTER_UNCLEBROADSWORD}

-- The costume IDs specific to each character
costumes.charLists = {}

--Fill this in
costumes.data = 
{
	DEMO_TEMPLATE = {path = "Demo-Centered", name = "Default"},
	IRIS_TEMPLATE = {path = "Iris-Centered", name = "Default"},
	KOOD_TEMPLATE = {path = "Kood-Centered", name = "Default"},
	RAOCOW_TEMPLATE = {path = "Raocow-Centered", name = "Default"},
	SHEATH_TEMPLATE = {path = "Sheath-Centered", name = "Default"},

	DEMO_BOBBLE = {path = "Demo-BobbleHat", name = "Bobble Hat Demo"};
	DEMO_SAFETYBEE = {path = "Demo-SafetyBee", name = "D the Safety Bee"};
}

costumes.defaults =
{	
	[CHARACTER_DEMO] = "DEMO_TEMPLATE";
	[CHARACTER_IRIS] = "IRIS_TEMPLATE";
	[CHARACTER_KOOD] = "KOOD_TEMPLATE";
	[CHARACTER_RAOCOW] = "RAOCOW_TEMPLATE";
	[CHARACTER_SHEATH] = "SHEATH_TEMPLATE";
}

local reference = {}

for k,v in pairs(costumes.data) do
	reference[v.path] = k;
end

-- Properties for each costume
costumes.info = {}
for  _,v1 in ipairs(Misc.listDirectories(Misc.episodePath().."costumes"))  do
	for  _,v2 in ipairs(Misc.listDirectories(Misc.episodePath().."/costumes/"..v1))  do
		local costume_id = reference[v2];
		
		if(costume_id) then
			local cid = charids[v1]

			if  costumes.charLists[cid] == nil  then
				costumes.charLists[cid] = {}
			end
			local charList = costumes.charLists[cid]
			
			table.insert(charList, costume_id);

			local info = {
				path = "costumes/"..v1.."/"..v2,
				id = costume_id,
				costume = v2,
				name = costumes.data[costume_id].name,
				character = cid,
				characterName = v1
				-- any other properties defined in a text document maybe?
			}
			info.animatx = Graphics.loadImage(info.path.."/"..v1.."_anmx.png")

			costumes.info[costume_id] = info
		end

	end
end


--*****************************
--** Save data management    **
--*****************************

if  SaveData.costumes == nil  then
	SaveData.costumes = {}
end


function costumes.getUnlocked (character)
	local unlocked = {}
	if(costumes.charLists[character])then
		for  _,v in ipairs (costumes.charLists[character])  do
			if  SaveData.costumes[v]  then
				table.insert(unlocked, v)
			end
		end
	end

	return unlocked
end

function costumes.getCurrent(character)
	local current = Player.getCostume(character);
	if(current) then
		current = current:upper();
	else
		return nil;
	end
	for  _,v in ipairs (costumes.charLists[character])  do
		if(costumes.data[v] and costumes.data[v].path:upper() == current) then
			return v;
		end
	end
	return nil;
end

function costumes.isDefault (character)
	return  (costumes.getCurrent(character) == costumes.defaults[character])
end

function costumes.unlock (id)
	if(not id:match("_TEMPLATE$")) then
		SaveData.costumes[id] = true
	end
end


function costumes.wear (id)
	local info = costumes.info[id]
	Player.setCostume(info.character, info.costume)
end

registerEvent(costumes,"onStart","onStart",false);

function costumes.onStart()
	for i=1,5 do
		if(Player.getCostume(i) == nil) then
			costumes.wear(costumes.defaults[i]);
		end
	end
end


return costumes