local bg = {}

local flipclock = API.load("CORE/flipclock");
local rng = API.load("rng");
local audioMaster = API.load("audioMaster");

local lights = Graphics.loadImage("CORE/bg_lights.png");
local glow = Graphics.loadImage("CORE/bg_lights_glow.png");
local tron = Graphics.loadImage("CORE/bg_tron.png");
local centre = Graphics.loadImage("CORE/core_centre.png");
local glass = Graphics.loadImage("CORE/core_centre_glass.png");
local glassglow = Graphics.loadImage("CORE/core_centre_glass_glow.png");
local cbg = Graphics.loadImage("CORE/core_bg.png");

local console = { [0] = Graphics.loadImage("CORE/console_off.png"),  [1] = Graphics.loadImage("CORE/console_regular.png"),  [-1] = Graphics.loadImage("CORE/console_error.png") };

local flipsound = audioMaster.Create{sound="CORE/flipclock_shuffle.ogg", x = 0, y = 0, type = audioMaster.SOURCE_POINT, falloffRadius = 800, volume = 1, play = false, tags = {"COREBG"}};

local shader_pulse;
local shader_neb;

local flipclocks = {};

for i = -1.5,1.5 do
	for j = 0,1 do
		table.insert(flipclocks, flipclock.Create(400+(i*64)-16+(j*28), 120, 0));
	end
end

function bg.initFlipclocks(value)
	for k,v in ipairs(flipclocks) do
		local l = 8-k;
		v.number = math.floor(math.max(value, 0)/math.pow(10,l))%10;
		v.lastnumber = v.number;
	end
	bg.flipnumber = value;
end

bg.flipnumber = 0;
bg.fliprandomise = false;
bg.flipsilent = false;

bg.colour = Color.black;
bg.pulsetimer = 0;
bg.pulsebrightness = 1;
bg.nebulaspeed = 1;

bg.consolestate = 1;

local neb = 0;

function bg.onInitAPI()
	registerEvent(bg, "onStart");
end

function bg.onStart()
	shader_pulse = Shader();
	shader_pulse:compileFromFile(nil, "CORE/luminance_pulse.frag")
	shader_neb = Shader();
	shader_neb:compileFromFile(nil, "CORE/nebula.frag")
end

local function vertcols(c,m)
	m = m or 1;
	return {c.r*m,c.g*m,c.b*m,0,c.r*m,c.g*m,c.b*m,0,c.r*m,c.g*m,c.b*m,0,c.r*m,c.g*m,c.b*m,0};
end

function bg.Draw(p)
	neb = neb+bg.nebulaspeed*2;
	Graphics.drawBox{width=800, height=200, x=0, y=200, priority=p, shader=shader_neb, uniforms = {iTime = lunatime.toSeconds(neb/3), iResolution={800,600,0}}};
	Graphics.drawScreen{texture=cbg, priority=p};
	local s = math.sin(lunatime.time()*1.5);
	local c = math.lerp(bg.colour, Color.white, 1-math.lerp(0.25,0.1,(s*s)));
	c.a = 1;
	Graphics.drawScreen{texture=lights, priority=p, color=c};
	c = bg.colour*math.lerp(0.25,1,s*s);
	Graphics.drawScreen{texture=glow, vertexColors=vertcols(c), priority=p};
	Graphics.drawScreen{texture=tron, priority=p, shader = shader_pulse, color = bg.colour, uniforms = {time = bg.pulsetimer, brightness = bg.pulsebrightness}};
	
	Graphics.drawScreen{texture=centre, priority=p};
	Graphics.drawScreen{texture=glass, priority=p};
	c = bg.colour*1;
	c.a=0.3;
	Graphics.drawScreen{texture=glass, priority=p, color = c};
	Graphics.drawScreen{texture=glassglow, priority=p, vertexColors=vertcols(bg.colour)};
	
	for k,v in ipairs(flipclocks) do
		if(bg.fliprandomise) then
			v.silent = true;
			if(not flipsound.playing and not bg.flipsilent) then
				flipsound.x = Camera.get()[1].x + 400;
				flipsound.y = Camera.get()[1].y + 300;
				flipsound:Play();
			end
			if(v.numtimer == 0) then
				v.number = rng.randomInt(0,9);
			end
		else
			flipsound:Stop();
			local l = 8-k;
			v.silent = bg.flipsilent;
			v.number = math.floor(math.max(bg.flipnumber, 0)/math.pow(10,l))%10;
		end
		v:Draw(p);
	end
	
	p = p+5;
	
	if(bg.consolestate >= 1) then
		Graphics.drawImageWP(console[1], 400-32, 600-32-64, p);
	elseif(bg.consolestate <= -1) then
		Graphics.drawImageWP(console[-1], 400-32, 600-32-64, p);
	elseif(bg.consolestate == 0) then
		Graphics.drawImageWP(console[0], 400-32, 600-32-64, p);
	else
		Graphics.drawImageWP(console[0], 400-32, 600-32-64, p);
		if(bg.consolestate < 0) then
			Graphics.drawImageWP(console[-1], 400-32, 600-32-64, -bg.consolestate, p);
		else
			Graphics.drawImageWP(console[1], 400-32, 600-32-64, bg.consolestate, p);
		end
	end
end

return bg;