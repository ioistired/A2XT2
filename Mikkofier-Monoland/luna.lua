local shader = Shader();
shader:compileFromFile(nil, "monoShader.frag");

function onDraw()
	player:render{x = x, y = y, shader = shader, drawmounts = true}
end

