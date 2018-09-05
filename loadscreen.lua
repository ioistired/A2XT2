package.path = package.path .. ";./scripts/?.lua"
local rng = require("rng")
rng.seed = 1276

local imgs = {"panda.png", "moonwalk.png", "luckySheath.png", "catplanet.png"}
local imgs2 = {nil, nil, "lucky.png"}
local frames = 
{
	{1,2,1,2,1,2,3,4,5,6,7,8,9,10,11},
	{1,2,3},
	{1,2,3,4,5,6},
	{1,2,3,4,5,6,7,8,9,10,11,12}
}

local times = { 4, 6, 6, 4 }
local speed = { 4, 2, 2, 2 }

local intervals = 
{
	nil,
	nil,
	{3,3,6,3,3,6,6,3,3,6,6,3,12,6,6,3,3,18,3,3,3,3,6,3,3,9,6,6}
}

--Misc.setLoadScreenTimeout(10)

math.random();
math.random();
math.random();
local index = math.random(1,#imgs)

local img = Graphics.loadImage("graphics/loading/"..imgs[index]);
local seq = frames[index]

local x = -64;
local frame = 1;
local frametimer = times[index];
local s = speed[index];

local img2;
local state = 0;

if(imgs2[index]) then
	img2 = Graphics.loadImage("graphics/loading/"..imgs2[index]);
end

function onDraw()
	if(index == 3) then
		if(state == 0) then
			x = 400-34;
			Graphics.drawImage(img, x, 500, math.floor((frame-1)/5)*68, ((frame-1)%5)*68, 68, 68);
			frametimer = frametimer - 1;
			if(frametimer <= 0) then
				frame = frame+1;
				frametimer = intervals[index][frame];
				if(frame > 28) then
					frame = 1;
					state = 1;
					frametimer = times[index]
					x = x + 16
				end
			end
		elseif(state == 1) then
			if(frame == 2 or frame == 3) then
				x = x + s;
			end
			Graphics.drawImage(img2, x, 500, 0, (seq[frame]-1)*64, 64, 64);
			frametimer = frametimer - 1;
			if(frametimer <= 0) then
				frame = frame+1;
				frametimer = times[index];
				if(frame > #seq) then
					frame = 1;
				end
			end
			if(x > 800) then
				x = -64;
			end
		end
	else
		x = x + s;
		Graphics.drawImage(img, x, 500, 0, (seq[frame]-1)*64, 64, 64);
		frametimer = frametimer - 1;
		if(frametimer <= 0) then
			frametimer = times[index];
			frame = frame+1;
			if(frame > #seq) then
				frame = 1;
			end
		end
		
		if(x > 800) then
			x = -64;
		end
	end
end