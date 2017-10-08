local flipclock = {};

local imagic = API.load("imagic");
local audioMaster = API.load("audioMaster");

local flip_base = Graphics.loadImage("CORE/flipclock_base.png");
local flips = {Graphics.loadImage("CORE/flipclock_flip_top.png"), Graphics.loadImage("CORE/flipclock_flip.png")}
local flip_n = Graphics.loadImage("CORE/flipclock_numbers.png");

local tick = "CORE/flipclock_tick.ogg";

local function tophalf_reg(t,x,y,n)
	table.insert(t.v, x-16); table.insert(t.v, y-16);
	table.insert(t.v, x+16); table.insert(t.v, y-16);
	table.insert(t.v, x-16); table.insert(t.v, y);
	table.insert(t.v, x+16); table.insert(t.v, y-16);
	table.insert(t.v, x-16); table.insert(t.v, y);
	table.insert(t.v, x+16); table.insert(t.v, y);
	
	local ty = n*0.1;
	local dt = 1/160;
	table.insert(t.t, 0); table.insert(t.t, ty);
	table.insert(t.t, 1); table.insert(t.t, ty);
	table.insert(t.t, 0); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 1); table.insert(t.t, ty);
	table.insert(t.t, 0); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+8*dt);
end

local function tophalf_on_flip(t,x,y,n)
	table.insert(t.v, x-16); table.insert(t.v, y-8);
	table.insert(t.v, x+16); table.insert(t.v, y-8);
	table.insert(t.v, x-16); table.insert(t.v, y);
	table.insert(t.v, x+16); table.insert(t.v, y-8);
	table.insert(t.v, x-16); table.insert(t.v, y);
	table.insert(t.v, x+16); table.insert(t.v, y);
	
	local ty = n*0.1;
	local dt = 1/160;
	table.insert(t.t, 0); table.insert(t.t, ty);
	table.insert(t.t, 1); table.insert(t.t, ty);
	table.insert(t.t, 0); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 1); table.insert(t.t, ty);
	table.insert(t.t, 0); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+8*dt);
end

local function tophalf_behind_flip(t,x,y,n)
	table.insert(t.v, x-16); table.insert(t.v, y-16);
	table.insert(t.v, x+16); table.insert(t.v, y-16);
	table.insert(t.v, x-16); table.insert(t.v, y-10);
	table.insert(t.v, x+16); table.insert(t.v, y-16);
	table.insert(t.v, x-16); table.insert(t.v, y-10);
	table.insert(t.v, x+16); table.insert(t.v, y-10);
	
	local ty = n*0.1;
	local dt = 1/160;
	table.insert(t.t, 0); table.insert(t.t, ty);
	table.insert(t.t, 1); table.insert(t.t, ty);
	table.insert(t.t, 0); table.insert(t.t, ty+3*dt);
	table.insert(t.t, 1); table.insert(t.t, ty);
	table.insert(t.t, 0); table.insert(t.t, ty+3*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+3*dt);
end

local function bottomhalf_reg(t,x,y,n)
	table.insert(t.v, x-16); table.insert(t.v, y);
	table.insert(t.v, x+16); table.insert(t.v, y);
	table.insert(t.v, x-16); table.insert(t.v, y+16);
	table.insert(t.v, x+16); table.insert(t.v, y);
	table.insert(t.v, x-16); table.insert(t.v, y+16);
	table.insert(t.v, x+16); table.insert(t.v, y+16);
	
	local ty = n*0.1;
	local dt = 1/160;
	table.insert(t.t, 0); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 0); table.insert(t.t, ty+16*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 0); table.insert(t.t, ty+16*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+16*dt);
end

local function bottomhalf_on_flip(t,x,y,n)
	table.insert(t.v, x-16); table.insert(t.v, y);
	table.insert(t.v, x+16); table.insert(t.v, y);
	table.insert(t.v, x-16); table.insert(t.v, y+8);
	table.insert(t.v, x+16); table.insert(t.v, y);
	table.insert(t.v, x-16); table.insert(t.v, y+8);
	table.insert(t.v, x+16); table.insert(t.v, y+8);
	
	local ty = n*0.1;
	local dt = 1/160;
	table.insert(t.t, 0); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 0); table.insert(t.t, ty+16*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+8*dt);
	table.insert(t.t, 0); table.insert(t.t, ty+16*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+16*dt);
end

local function bottomhalf_behind_flip(t,x,y,n)
	table.insert(t.v, x-16); table.insert(t.v, y+12);
	table.insert(t.v, x+16); table.insert(t.v, y+12);
	table.insert(t.v, x-16); table.insert(t.v, y+16);
	table.insert(t.v, x+16); table.insert(t.v, y+12);
	table.insert(t.v, x-16); table.insert(t.v, y+16);
	table.insert(t.v, x+16); table.insert(t.v, y+12);
	
	local ty = n*0.1;
	local dt = 1/160;
	table.insert(t.t, 0); table.insert(t.t, ty+12*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+12*dt);
	table.insert(t.t, 0); table.insert(t.t, ty+16*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+12*dt);
	table.insert(t.t, 0); table.insert(t.t, ty+16*dt);
	table.insert(t.t, 1); table.insert(t.t, ty+16*dt);
end

local fliptime = 6;

local function drawFlipNumber(obj, p)
	obj.baseimg.x = obj.x;
	obj.baseimg.y = obj.y;
	obj.baseimg:Draw(p);
	if(obj.lastnumber ~= obj.number) then
		if(obj.numtimer == 0) then
			obj.numtimer = fliptime;
			
			if(not obj.silent) then
				audioMaster.PlaySound{sound = tick, loops = 1, volume = 1, tags = {"COREBG"}}
			end
			
		else
			obj.numtimer = obj.numtimer - 1;
			if(obj.numtimer == 0) then
				obj.lastnumber = obj.number;
			end
		end
		local f = math.ceil((1-(obj.numtimer/fliptime))+0.5);
		local t = {v={}, t={}}
		if(f == 1) then
			tophalf_behind_flip(t,obj.x,obj.y,obj.number);
			tophalf_on_flip(t,obj.x,obj.y,obj.lastnumber);
			bottomhalf_reg(t,obj.x,obj.y,obj.lastnumber);
		else
			bottomhalf_behind_flip(t,obj.x,obj.y,obj.lastnumber);
			bottomhalf_on_flip(t,obj.x,obj.y,obj.number);
			tophalf_reg(t,obj.x,obj.y,obj.number);
		end
		imagic.Draw{x = obj.x, y = obj.y, priority = p, align = imagic.ALIGN_CENTRE, texture = flips[f], width = 32, height = 32}
		Graphics.glDraw{vertexCoords=t.v, textureCoords=t.t, priority=p, texture = flip_n}
	else
		imagic.Draw{x = obj.x, y = obj.y, priority = p, align = imagic.ALIGN_CENTRE, texture = flip_n, width = 32, height = 32, sourceX = 0, sourceY = obj.lastnumber*16, sourceWidth=16, sourceHeight=16}
	end
end

function flipclock.Create(x, y, n)
	return { x = x, y = y, baseimg = imagic.Create{x=0, y=0, align = imagic.ALIGN_CENTRE, primitive = imagic.TYPE_BOX, width=32, height=32, texture = flip_base}, number = n, lastnumber = n, numtimer = 0, draw = drawFlipNumber, Draw = drawFlipNumber }
end

return flipclock;