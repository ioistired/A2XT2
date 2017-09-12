#version 120
uniform sampler2D iChannel0;
uniform float time;
uniform float yOffset;
uniform float intensity = 0.05;
uniform float frequency = 0.5;
uniform float speed = 0.07;

void main()
{
	vec2 uv = vec2(clamp(gl_TexCoord[0].x + intensity*sin((gl_FragCoord.y+yOffset)*frequency + time * speed),0,1), gl_TexCoord[0].y);
	vec4 c = texture2D( iChannel0, uv);
	gl_FragColor = c * gl_Color;
}