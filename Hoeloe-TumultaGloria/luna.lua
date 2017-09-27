local boss = API.load("boss_retcon");
boss.section = 0;

local rng = API.load("rng")
local vectr = API.load("vectr")
local tesseract = API.load("tesseract");

local tess = tesseract.Create(400,300,32);

tess.rotation.x = rng.random(0,2*math.pi);
tess.rotation.y = rng.random(0,2*math.pi);
tess.rotation.z = rng.random(0,2*math.pi);
tess.rotation.w = rng.random(0,2*math.pi);

local rotspd = vectr.v4(0.011, 0.023, 0.047, 0.028);
local spdmult = 1;

function onTick()
	tess.rotation = tess.rotation + rotspd*spdmult;

	if(lunatime.time() > 3) then
		boss.Begin();
	end
	
end

function onDraw()
	tess:Draw(-99,false,math.lerp(Color.white,Color.red,0.8));
end