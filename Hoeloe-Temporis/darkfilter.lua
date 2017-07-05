local dark = {};

function dark.initAPI()
	--registerEvent(dark,"onDraw","onDraw");
end

dark.FALLOFF_IMG = Graphics.loadImage(Misc.resolveFile("falloff_default.png"));

local shadow = {};

dark.FALLOFF_CON = 1;
dark.FALLOFF_LIN = 2;
dark.FALLOFF_SQR = 3;
dark.FALLOFF_LOG = 4;
dark.FALLOFF_INV = 5;

function dark.Light(data)
	return {x=data.x,y=data.y,radius=data.radius,col=(data.colour or data.color) or 0xFFFFFF,falloff=data.falloff or dark.FALLOFF_INV, sourceradius=data.sourceRadius or 0,res_b=data.borderRes or 8, res_i = data.innerRes or 4};
end

function dark.Section(data)
	local x1 = data.x1;
	local x2 = data.x2;
	local y1 = data.y1;
	local y2 = data.y2;
	if(x2 < x1) then
		local t = x2;
		x2 = x1;
		x1 = t;
	end
	if(y2 < y1) then
		local t = y2;
		y2 = y1;
		y1 = t;
	end
	return {x1=x1,y1=y1,x2=x2,y2=y2,falloff=data.falloff or dark.FALLOFF_IMG,edge=data.edge or 32,alpha=data.alpha or 0.5};
end

function shadow:AddLight(data)
	local light = dark.Light(data);
	table.insert(self.lights,light);
	return light;
end

function shadow:AddSection(data)
	local s = dark.Section(data)
	table.insert(self.sections,s);
	return s;
end

local function falloff(i,flf)
	if(i == 0) then return 1; end;
	if(flf == dark.FALLOFF_CON) then
		return 1;
	elseif(flf == dark.FALLOFF_LIN) then
		return 1-i;
	elseif(flf == dark.FALLOFF_SQR) then
		return 1-(i*i)
	elseif(flf == dark.FALLOFF_LOG) then
		return math.min(-0.25*math.log(i),1);
	elseif(flf == dark.FALLOFF_INV) then
		return 2/(i*i + 1) - 1
	end
end

local function circleToPoly(x,y,radius,sourcerad,falloffType,falloffRes,resolution,colour)
		local x1 = x;
		local y1 = y;
		local pts = {};
		local txs = {};
		local cols = {};
		colour = colour or 0xFFFFFF
		local col = {(math.floor(colour/(256*256)))/255,(math.floor(colour/256)%256)/255,(colour%256)/255,1};
		local m = resolution;
		local s = (math.pi/2)/m;
		if(falloffType == dark.FALLOFF_CON or falloffType == dark.FALLOFF_LIN) then
			falloffRes = 2;
		end
		local fo_n = radius/(radius-sourcerad);
		for o=falloffRes,1,-1 do
			local xmult = 1;
			local ymult = -1;
			
			local fo = ((o-1)/(falloffRes-1))/fo_n + (sourcerad/radius);
			local foi = ((o-2)/(falloffRes-1))/fo_n + (sourcerad/radius);
			if(o == 1) then
				foi = 0;
			end
			local frad = radius*fo;
			local fradi = radius*foi;
			for n=1,4 do
				local m1 = 0;
				local m2 = m;
				if(xmult*ymult==-1) then m1 = m; m2 = 0; end
				for i=m1,m2,(xmult*ymult) do
					local xs = math.cos((math.pi/2)-s*i);
					local ys = math.sin((math.pi/2)-s*i);
					
					table.insert(pts,x1+xmult*frad*xs);
					table.insert(pts,y1+ymult*frad*ys);
					table.insert(pts,x1+xmult*fradi*xs);
					table.insert(pts,y1+ymult*fradi*ys);

					table.insert(txs,(((xmult*fo*xs + 1.0)*radius) + (x1-radius))/800)
					table.insert(txs,(((ymult*fo*ys + 1.0)*radius) + (y1-radius))/600)
					table.insert(txs,(((xmult*foi*xs + 1.0)*radius) + (x1-radius))/800)
					table.insert(txs,(((ymult*foi*ys + 1.0)*radius) + (y1-radius))/600)
				
					
										
					--[[ --FOR DEBUG
					table.insert(cols,(o-1)/(falloffRes-1));
					table.insert(cols,0);
					table.insert(cols,0);
					table.insert(cols,1);
					table.insert(cols,(o-1)/(falloffRes-1));
					table.insert(cols,0);
					table.insert(cols,0);
					table.insert(cols,1);]]
					
					--FOR ALPHA LIGHTS
					local foa,fob;
					if(frad < sourcerad) then
						foa = 1;
					else
						foa = math.min(falloff(fo_n*(fo-1)+1,falloffType),1);
					end
					if(fradi < sourcerad) then
						fob = 1;
					else
						fob = math.min(falloff(fo_n*(foi-1)+1,falloffType),1);
					end
					
					for c=1,4 do
						table.insert(cols,foa*col[c]);
					end		
					for c=1,4 do
						table.insert(cols,fob*col[c]);
					end
					
					--[[ --FOR ADDITIVE LIGHTS
					for c=1,3 do
						table.insert(cols,falloff(fo,falloffType)*col[c]);
					end		
					table.insert(cols,0);
					for c=1,3 do
						table.insert(cols,falloff(foi,falloffType)*col[c]);
					end		
					table.insert(cols,0);]]
				end
				if xmult == 1 then
					if ymult == -1 then
						ymult = 1;
					elseif ymult == 1 then
						xmult = -1;
					end
				elseif xmult == -1 then
					if ymult == -1 then
						xmult = 1;
					elseif ymult == 1 then
						ymult = -1;
					end
				end
			end
		end
		return pts,cols,txs;
end

function shadow:Draw(priority)
	local cx,cy = Camera.get()[1].x,Camera.get()[1].y;
	
	local img = self.buffer:captureAt(priority);
	
	for _,v in ipairs(self.sections) do
		local x1 = v.x1-cx;
		local y1 = v.y1-cy;
		local x2 = v.x2-cx;
		local y2 = v.y2-cy;
		local e = v.edge;
		
		local txs = {};
		local cols = {};
		local coords = {};
		
		local i = 1;
		
		--TL corner
		coords[i] = x1; coords[i+1] = y1+e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y1;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--TOP
		coords[i] = x1+e; coords[i+1] = y1;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--TR corner
		coords[i] = x2-e; coords[i+1] = y1;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2; coords[i+1] = y1+e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--RIGHT
		coords[i] = x2; coords[i+1] = y1+e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2; coords[i+1] = y2-e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2; coords[i+1] = y2-e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--BR corner
		coords[i] = x2; coords[i+1] = y2-e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y2;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--BOTTOM
		coords[i] = x2-e; coords[i+1] = y2;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--BL corner
		coords[i] = x1+e; coords[i+1] = y2;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1; coords[i+1] = y2-e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--LEFT
		coords[i] = x1; coords[i+1] = y2-e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1; coords[i+1] = y1+e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1; coords[i+1] = y1+e;
		txs[i] = 1; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		--CENTRE
		coords[i] = x1+e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x1+e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y1+e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		coords[i] = x2-e; coords[i+1] = y2-e;
		txs[i] = 0; txs[i+1] = 0;
		i = i+2;
		
		Graphics.glDraw{vertexCoords=coords,textureCoords=txs,color={0,0,0,v.alpha},primitive=Graphics.GL_TRIANGLE,texture=v.falloff,priority=priority}
	end
	
	local lists = {}
	for _,v in ipairs(self.lights) do
		local vtx,cols,txs = circleToPoly(v.x-cx,v.y-cy,v.radius,v.sourceradius,v.falloff,v.res_i,v.res_b,v.col);
		
		--[[ --FOR ADDITIVE LIGHTS
		local vs = {}
		for k,v in ipairs(cols) do
			if(k%4 == 0) then
				vs[k] = v;
			else
				vs[k] = 0;
			end
		end
		Graphics.glDraw{vertexCoords=vtx,primitive=Graphics.GL_TRIANGLE_STRIP,priority=priority-1,vertexColors=vs}
		]]
		Graphics.glDraw{vertexCoords=vtx,primitive=Graphics.GL_TRIANGLE_STRIP,vertexColors=cols,textureCoords=txs,texture=self.buffer,priority=priority}
	end
	
	
end

function dark.Shadow(sections,lights)
	local s = {sections = sections or {}, lights = lights or {}}
	s.buffer = Graphics.CaptureBuffer(800,600)
	s.Draw = shadow.Draw;
	s.AddSection = shadow.AddSection;
	s.AddLight = shadow.AddLight;
	return s;
end

return dark;