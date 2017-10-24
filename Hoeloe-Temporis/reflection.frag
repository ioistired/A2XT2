#version 120
uniform sampler2D iChannel0;
uniform float time;
uniform vec2 fadeR;
uniform float depthOffset;
uniform float intensity = 0.00007;
uniform float frequency = 0.5;
uniform float speed = 0.07;

void main()
{
	//Clamp x coordinate between 0 and 1
	vec2 uv = vec2(clamp(gl_TexCoord[0].x + intensity*(gl_FragCoord.y - depthOffset) *sin((gl_FragCoord.y - depthOffset)*frequency + time * speed),0,1), gl_TexCoord[0].y);
	vec4 c = texture2D( iChannel0, uv);
	
	c.rgb *= clamp(1 - (gl_FragCoord.x - fadeR.x)/(fadeR.y-fadeR.x),0,1) * clamp(abs(gl_FragCoord.y - depthOffset)*0.1, 0, 1);
	
	gl_FragColor = c * gl_Color;
}