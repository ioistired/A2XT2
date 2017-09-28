#version 120
uniform sampler2D iChannel0;
uniform float time;
uniform float brightness;

void main()
{
	vec4 col = texture2D( iChannel0, gl_TexCoord[0].xy);
	
	float d1 = (mod(time/2,1)*2.2) - 0.6;
	float d2 = d1+0.5;
	float d3 = d2+0.1;
	
	float a = (clamp(distance(gl_FragCoord.xy,vec2(400,300))/500, 0, 1) / (d2-d1)) - d1;
	
	a *= 1-clamp((a - d2)/(d3-d2),0,1);
	
	a = clamp(a,0,1);
	
	vec4 c = gl_Color;
	c.a = 0;
	gl_FragColor = col*mix(c*0.4,c+vec4(1,1,1,0)*0.5*brightness,a);
}