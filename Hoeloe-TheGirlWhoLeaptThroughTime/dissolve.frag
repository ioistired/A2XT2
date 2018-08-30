//Read from the main texture using the regular texutre coordinates, and blend it with the tint colour.
//This is regular glDraw behaviour and is the same as using no shader.

#version 120
uniform sampler2D iChannel0;
uniform float alpha = 0;
uniform sampler2D noise;

//Do your per-pixel shader logic here.
void main()
{
	vec4 c = texture2D(iChannel0, gl_TexCoord[0].xy);
	float n = texture2D(noise, mod(gl_TexCoord[0].xy + vec2(0,alpha), 1)).r;
	
	n = clamp(2*(2*alpha - gl_TexCoord[0].y)-n,0,1);
	
	c.a *= 1-n;
	
	gl_FragColor = c * gl_Color;
}