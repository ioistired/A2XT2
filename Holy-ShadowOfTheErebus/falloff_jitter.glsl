uniform sampler2D noise;
uniform float time;

vec3 falloff(vec4 light, float d, float rad)
{	
	d = d/rad;
	return clamp(step(0.5,(1-d))*light.rgb*light.a - texture2D(noise, mod(gl_FragCoord.xy/vec2(800,600) + time*0.1, 1)).r*d*d*d*d*d*d*80,0,1);
}