//Read from the main texture using the regular texutre coordinates, and blend it with the tint colour.
//This is regular glDraw behaviour and is the same as using no shader.

#version 120
uniform sampler2D iChannel0;
uniform float cycle = 100;

//Do your per-pixel shader logic here.
void main()
{
	vec4 c = texture2D(iChannel0, gl_TexCoord[0].xy);
	
	vec2 offset = gl_TexCoord[0].xy-vec2(0.5);
	
	float d = 1-2*(length(offset)+0.1);
	
	float v = d;
	
	float angle = atan(offset.y,offset.x);
	
	vec4 glow = (d+0.2)*vec4(0.5,0.8,1,1)*2 * (1-d*d);
	
	d -= (0.01*clamp(sin(angle*cycle),0,1)*(1-d)*(1-d));
	
	d = clamp(d,0,1);
	
	c*= sqrt(d);
	
	vec4 c2 = c;
	
	c+=glow;
	
	c = mix(c,c2,v);
	
	gl_FragColor = c * gl_Color;
}