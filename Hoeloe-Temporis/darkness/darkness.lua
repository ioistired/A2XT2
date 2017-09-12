local darkness = {}
local vectr = API.load("vectr");


darkness.Falloff = {};
darkness.Falloff.INV_SQR = Misc.resolveFile("darkness/falloff_sqr.shader");
darkness.Falloff.LINEAR = Misc.resolveFile("darkness/falloff_lin.shader");
darkness.Falloff.HARD = Misc.resolveFile("darkness/falloff_hard.shader");
darkness.Falloff.STEP = Misc.resolveFile("darkness/falloff_step.shader");
darkness.Falloff.SQR_STEP = Misc.resolveFile("darkness/falloff_sqrstep.shader");

darkness.Falloff.DEFAULT = darkness.Falloff.INV_SQR;

darkness.Shadow = {};
darkness.Shadow.NONE = Misc.resolveFile("darkness/shadow_none.shader")
darkness.Shadow.RAYMARCH = Misc.resolveFile("darkness/shadow_raymarch.shader")
darkness.Shadow.HARD_RAYMARCH = Misc.resolveFile("darkness/shadow_raymarch_hard.shader")
darkness.Shadow.DEFAULT = darkness.Shadow.NONE;

darkness.Priority = {};
darkness.Priority.DISTANCE = 0;
darkness.Priority.SIZE = 1;
darkness.Priority.BRIGHTNESS = 2;


local function readAll(file)
    local f = io.open(file, "r");
    local content = f:read("*all");
    f:close();
    return content;
end

local fragShader = Misc.resolveFile("darkness/darkfilter.frag");

local capture1 = Graphics.CaptureBuffer(800,600);


local function RGBFromHex(h)
	return {math.floor(h/(256*256))/255,(math.floor(h/256)%256)/255,(h%256)/255};
end


local Light = {};
function darkness.Light(x,y,radius,brightness,colour)
	colour = colour or 0xFFFFFF;
	brightness = brightness or 1;
	local l = {x=x,y=y,radius=radius,brightness=brightness,colour=RGBFromHex(colour)};
	l.SetColor = Light.SetColour;
	l.SetColour = Light.SetColour;
	
	return l;
end

function Light:SetColour(colour)
	self.colour = RGBFromHex(colour);
end

local nullLight = darkness.Light(0,0,0,0,0);

local function getShaderHeader(field, falloff, shadow)
	local s = "const int _MAXLIGHTS="..field.maxLights..";\n";
	s = s..readAll(falloff).."\n\n";
	s = s..readAll(shadow).."\n";
	return s;
end

local function readLightShader(field, fragment, lightfunc, shadowfunc)

	local f = io.open(fragment, "r");
	local s = "";
	
	for v in f:lines() do
		s = s..v.."\n";
		if(v:match("%s*#version%s+.+")) then
			s = s..getShaderHeader(field, lightfunc,shadowfunc).."\n";
		end
	end
	
	f:close();
		
	return s;
end


local Field = {};
Field.__index = Field;
function darkness.Field(args)
	args = args or {};
	local f = {
		lights = {}, 
		falloff = args.falloff,
		shadows = args.shadows,
		maxLights = args.maxLights or 20, 
		uniforms = args.uniforms or {},
		priorityType = args.priorityType or darkness.Priority.DISTANCE,
		bounds = args.bounds,
		boundBlendLength = args.boundBlendLength,
		shader = Shader(),
		ambient = args.ambient or 0x191932;
		}
	setmetatable(f,Field);
		
	f.ambient = RGBFromHex(f.ambient);
		
	f:RebuildShader();
	
	return f;
end

function Field:AddLight(light)
	table.insert(self.lights, light);
end

function Field:RemoveLight(light)
	if(light.__removeList == nil) then
		light.__removeList = {[self] = true};
	else
		light.__removeList[self] = true;
	end
end

function Field:Draw()
	if(self.shader) then
		--[[
		capture1:captureAt(-71);
		
		Graphics.glDraw{
			vertexCoords = {0, 0, 800, 0, 800, 600, 0, 600 },
			primitive = Graphics.GL_TRIANGLE_FAN, 
			vertexColors = {0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1},
			priority = -71
			}
		
		capture2:captureAt(0);
		
		Graphics.glDraw{
			vertexCoords = {0, 0, 800, 0, 800, 600, 0, 600 },
			textureCoords = { 0,0,1,0,1,1,0,1},
			primitive = Graphics.GL_TRIANGLE_FAN, 
			texture = capture1,
			priority = -71
		};
		]]
		
		capture1:captureAt(-0.01);
		
		local cam = Camera.get()[1];
		
		local lights,colours,lightCount = self:ChooseLights();
		
		local b = nil;
		local useBounds = 1;
		if(self.bounds) then
			if(self.bounds.x and self.bounds.y and self.bounds.width and self.bounds.height) then
				b = {self.bounds.x,self.bounds.y,self.bounds.x+self.bounds.width,self.bounds.y+self.bounds.width};
			elseif(self.bounds.left and self.bounds.top and self.bounds.right and self.bounds.bottom) then
				b = {self.bounds.left, self.bounds.top, self.bounds.right, self.bounds.bottom}
			elseif(self.bounds[1] and self.bounds[2] and self.bounds[3] and self.bounds[4]) then
				b = self.bounds;
			else
				useBounds = 0;
			end
		else
			useBounds = 0;
		end
		
		local uniforms = {
				cameraPos = {cam.x, cam.y},
				lightPos = lights,
				lightCol = colours,
				--mask = maskTest,
				ambient = self.ambient,
				lightNum = lightCount,
				bounds = b,
				useBounds = useBounds,
				boundBlend = self.boundBlendLength
			};
			
		for k,v in pairs(self.uniforms) do
			uniforms[k] = v;
		end
		
		Graphics.glDraw{
			vertexCoords = {0, 0, 800, 0, 800, 600, 0, 600 },
			textureCoords = { 0,0,1,0,1,1,0,1},
			primitive = Graphics.GL_TRIANGLE_FAN, 
			texture = capture1,
			shader = self.shader,
			uniforms = uniforms,
			priority = -0.01
			};
	end
end

local function lightSort(a, b)
	return a[2] < b[2];
end

function Field:RebuildShader()
	self.shader:compileFromSource(nil, readLightShader(self, fragShader, self.falloff or darkness.Falloff.DEFAULT, self.shadows or darkness.Shadow.DEFAULT));
end

local function GetPriority(ptype, light, centre)
	if(ptype == darkness.Priority.DISTANCE) then
		return (vectr.v2(light.x, light.y)-centre).sqrlength;
	elseif(ptype == darkness.Priority.SIZE) then
		return -light.radius;
	elseif(ptype == darkness.Priority.BRIGHTNESS) then
		return -light.brightness;
	else
		return 0;
	end
end

function Field:ChooseLights()
	local list = {};
	local colList = {};
	local distList = {};
	local cnt = 0;
	local cam = Camera.get()[1];
	local centre = vectr.v2(cam.x + 400, cam.y + 300); --Screen centre
	
	--List the lights and their distances from the centrepoint.
	--Also remove any lights that we've queued for removal.
	local k = 1;
	while k <= #self.lights do
		local v = self.lights[k];
		if(v.__removeList and v.__removeList[self]) then
			v.__removeList[self] = nil;
			table.remove(self.lights, k);
		else
			table.insert(distList, {k, GetPriority(self.priorityType, v,centre)});
			k = k + 1;
		end
	end
	
	table.sort(distList, lightSort);
	
	local count = 0;
	
	for i=1,self.maxLights,1 do
		local val = nullLight
		if(i <= #distList) then
			val = self.lights[distList[i][1]];
			--Don't add lights if the light is entirely offscreen
			if(val.x+val.radius < cam.x or val.x-val.radius > cam.x+800 or val.y+val.radius < cam.y or val.y-val.radius > cam.y+600) then
				val = nullLight;
			else
				count = count + 1;
			end
		end
		table.insert(list, val.x);
		table.insert(list, val.y);
		table.insert(list, val.radius);
		
		table.insert(colList, val.colour[1]);
		table.insert(colList, val.colour[2]);
		table.insert(colList, val.colour[3]);
		table.insert(colList, val.brightness);
	end
	
	return list,colList, count;
end

return darkness;