#version 130
uniform sampler2D iChannel0;
uniform float time;
uniform float yOffset;
uniform float intensity = 0.05;
uniform float frequency = 0.5;
uniform float speed = 0.07;

void main()
{	
	//Clamp x coordinate between 0 and 0.78 - coordinates are to Po2 texture
	vec2 uv = vec2(clamp(gl_TexCoord[0].x + intensity*sin((gl_FragCoord.y+yOffset)*frequency + time * speed),0,0.78), gl_TexCoord[0].y);
	vec4 c = texture( iChannel0, uv);
	gl_FragColor = c * gl_Color;
}