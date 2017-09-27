local tesseract = {}

local vectr = API.load("vectr")

local function maketris(verts,tex,quads)
	table.insert(tex,0);
	table.insert(tex,0);
	table.insert(tex,1);
	table.insert(tex,0);
	table.insert(tex,0);
	table.insert(tex,1);
	table.insert(tex,1);
	table.insert(tex,0);
	table.insert(tex,0);
	table.insert(tex,1);
	table.insert(tex,1);
	table.insert(tex,1);
	
	local t = {1,2,4,2,4,3};
	
	for _,v in ipairs(t) do
		for _,w in ipairs(quads[v]) do
			table.insert(verts, w);
		end
	end
end

local shader = "4d"

local function draw(obj, priority, sceneCoords, color)
	if(type(shader) == "string") then
		local s = shader;
		shader = Shader();
		shader:compileFromFile(s..".vert",s..".frag");
	end
	
	local r = {obj.rotation.x, obj.rotation.y, obj.rotation.z, obj.rotation.w};
	
	Graphics.glDraw{vertexCoords = obj.__tverts, textureCoords = obj.__tex, shader = shader,
		sceneCoords = sceneCoords,
		attributes = { position = obj.__verts }, 
		priority = priority,
		uniforms = { 
			scale = obj.size,
			offset = {obj.x,obj.y,0,128}, 
			depth = 128,
			rot = r,
			},

			color = color or Color.white};
end

function tesseract.Create(x,y,size)

	local verts,tex = {},{};

	--Cube 1
		--sides
		maketris(verts, tex, {{-1,-1,-1,-1}, 	{1,-1,-1,-1}, 	{1,1,-1,-1}, 	{-1,1,-1,-1}});
		maketris(verts, tex, {{-1,-1,1,-1}, 	{1,-1,1,-1}, 	{1,1,1,-1}, 	{-1,1,1,-1}});
		maketris(verts, tex, {{-1,-1,-1,-1}, 	{-1,-1,1,-1}, 	{-1,1,1,-1}, 	{-1,1,-1,-1}});
		maketris(verts, tex, {{1,-1,-1,-1}, 	{1,-1,1,-1}, 	{1,1,1,-1}, 	{1,1,-1,-1}});
		--top/bottom
		maketris(verts, tex, {{-1,-1,-1,-1},	{1,-1,-1,-1},	{1,-1,1,-1},	{-1,-1,1,-1}});
		maketris(verts, tex, {{-1,1,-1,-1},		{1,1,-1,-1},	{1,1,1,-1},		{-1,1,1,-1}});
	
	--Cube 2
		--sides
		maketris(verts, tex, {{-1,-1,-1,1}, 	{1,-1,-1,1}, 	{1,1,-1,1}, 	{-1,1,-1,1}});
		maketris(verts, tex, {{-1,-1,1,1}, 		{1,-1,1,1}, 	{1,1,1,1}, 		{-1,1,1,1}});
		maketris(verts, tex, {{-1,-1,-1,1}, 	{-1,-1,1,1}, 	{-1,1,1,1}, 	{-1,1,-1,1}});
		maketris(verts, tex, {{1,-1,-1,1}, 		{1,-1,1,1}, 	{1,1,1,1}, 		{1,1,-1,1}});
		--top/bottom
		maketris(verts, tex, {{-1,-1,-1,1},		{1,-1,-1,1},	{1,-1,1,1},		{-1,-1,1,1}});
		maketris(verts, tex, {{-1,1,-1,1},		{1,1,-1,1},		{1,1,1,1},		{-1,1,1,1}});
		
	--Connecting Quads
		--top
		maketris(verts, tex, {{-1,-1,-1,-1}, 	{-1,-1,-1,1}, 	{1,-1,-1,1}, 	{1,-1,-1,-1}});
		maketris(verts, tex, {{-1,-1,1,-1}, 	{-1,-1,1,1}, 	{-1,-1,-1,1}, 	{-1,-1,-1,-1}});
		maketris(verts, tex, {{1,-1,1,-1}, 		{1,-1,1,1}, 	{-1,-1,1,1}, 	{-1,-1,1,-1}});
		maketris(verts, tex, {{1,-1,-1,-1}, 	{1,-1,-1,1}, 	{1,-1,1,1}, 	{1,-1,1,-1}});
	
		--bottom
		maketris(verts, tex, {{-1,1,-1,-1}, 	{-1,1,-1,1}, 	{1,1,-1,1}, 	{1,1,-1,-1}});
		maketris(verts, tex, {{-1,1,1,-1}, 		{-1,1,1,1}, 	{-1,1,-1,1}, 	{-1,1,-1,-1}});
		maketris(verts, tex, {{1,1,1,-1}, 		{1,1,1,1}, 		{-1,1,1,1}, 	{-1,1,1,-1}});
		maketris(verts, tex, {{1,1,-1,-1}, 		{1,1,-1,1}, 	{1,1,1,1}, 		{1,1,1,-1}});
	
		--sides
		maketris(verts, tex, {{-1,-1,-1,-1}, 	{-1,-1,-1,1}, 	{-1,1,-1,1}, 	{-1,1,-1,-1}});
		maketris(verts, tex, {{-1,-1,1,-1}, 	{-1,-1,1,1}, 	{-1,1,1,1}, 	{-1,1,1,-1}});
		maketris(verts, tex, {{1,-1,1,-1}, 		{1,-1,1,1}, 	{1,1,1,1}, 		{1,1,1,-1}});
		maketris(verts, tex, {{1,-1,-1,-1}, 	{1,-1,-1,1}, 	{1,1,-1,1}, 	{1,1,-1,-1}});
	
	
	local tverts = {};

	for i = 1,#verts,2 do
		table.insert(tverts, 0);
	end
	
	local t = {__verts = verts, __tex = tex, __tverts = tverts, x = x, y = y, rotation = vectr.v4(0,0,0,0), size = size}
	
	t.draw = draw;
	t.Draw = draw;
	
	return t;
end

return tesseract;