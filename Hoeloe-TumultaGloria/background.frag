#version 120
uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iGlobalTime;           // shader playback time (in seconds)
uniform float     gSpeedMult;      
uniform sampler2D iChannel0;    
uniform sampler2D noise;      
uniform vec2	  gBossPos;  

uniform vec3	  gColBase;
uniform vec3	  gColAdd;
   
#define gSpeed 1
#define StarQuality 15
#define DustQuality 0.3125

mat2 GetRotation()
{
    // Reverse the rotation effect
    float cs = cos(-iGlobalTime*0.325);
    float sn = sin(-iGlobalTime*0.325);
    return mat2(cs, sn, -sn, cs);
}

mat2 GetRevRotation()
{ 
	// Reverse the rotation effect
    float cs = cos(iGlobalTime*0.325);
    float sn = sin(iGlobalTime*0.325);
    return mat2(cs, sn, -sn, cs);
}

vec2 GetUV(vec2 BaseUV)
{
    float time = iGlobalTime*65;
    vec2 uv = (BaseUV.xy / iResolution.xy) * 2.0 - 1.0;
    uv.x = (uv.x * iResolution.x / iResolution.y) + sin(time*0.005) * 0.5;
    uv *= GetRotation();
    return uv;
}

vec2 GetRevUV(vec2 BaseUV)
{
    float time = iGlobalTime*65;
	vec2 uv = BaseUV*GetRevRotation();
	uv.x = (uv.x - (sin(time*0.005) * 0.5)) * iResolution.y / iResolution.x;
	uv = (uv + 1.0) * 0.5 * iResolution.xy;
    return uv;
}

vec3 GenStarfield(vec2 uv)
{
    vec3 r = vec3(uv, 1.0);
    float mspeed = gSpeed * gSpeedMult;
    
    float d = 0.5 * iGlobalTime;
    float s = mspeed + 0.1; // add a small offset
    
    d += d*mspeed*0.96;
    
    vec3 accum = vec3(0,0,0);
    vec3 spp = r/max(abs(r.x),abs(r.y));
    vec3 p = 2.0 * spp + 0.5;
    
    for (int i = 0; i < StarQuality; i++)
    {
        float z = texture2D(iChannel0, mod((p.xy+0.5)/256.0,1.0), 0).x;
		z = fract(z-d);
		float d2 = 50.0*z-p.z;
		float w = pow(max(0.0,1.0-8.0*length(fract(p.xy)-.5)),2.0);
		vec3 c = max(vec3(0), vec3(1.0 - abs(d2 + mspeed * .5)/s, 1.0 - abs(d2)/s, 1.0 - abs(d2 - mspeed * .5)/s));
		accum += 1.5*(1.0-z)*c*w;
		p += spp;
    }
    
    return pow(accum, vec3(0.454545)) * /*sin(gSpeed)*/0.85; 
}

vec3 lowfilter(vec3 c, float p)
{
	return max(c-p,0.0) * (1.0/(1.0-p));
}

vec3 GenDust(vec2 uv, vec2 off)
{
    /*
	float time = iGlobalTime*65;
    
    float v = 0.0;
    vec3 accum = vec3(0);
    vec3 init = vec3 (0.25 + sin(time * 0.001) * 0.4, 0.25, floor(time) * 0.0008);
    
    float intensity = mix(1.0, 10.0, 1.0 - DustQuality);
	for (float s = 0; s < DustQuality; s += .0125) 
	{
		vec3 p = init + s * vec3(uv, 0.143);
		p.z = mod(p.z, 2.0);
		for (int i=0; i < 10; i++)
		{	
			p = abs(p * 2.04) / dot(p, p) - 0.75;
		}
		
		v += dot(p,p) * 1.25 * smoothstep(0.0, 0.5, 0.9 - s) * .002;
		accum +=  vec3(gColBase.r - s * gColAdd.r, gColBase.g + v * gColAdd.g,  gColBase.b + v * gColAdd.b) * v * 0.013;
	}
    
    return accum*intensity*2;
	*/
	
	float rInv = 0.2/length(uv-off);
    vec2 uv1 = mod(uv * rInv - vec2(rInv-0.5*iGlobalTime*gSpeed*gSpeedMult,0.0),1.);
    vec2 uv2 = mod(uv * rInv - vec2(rInv+0.173+0.371*iGlobalTime*gSpeed*gSpeedMult,0.0),1.);
	uv2.x = 1-uv2.x;
	vec3 col1 = lowfilter(gColAdd.rgb * texture2D(noise, uv1).rgb, 0.02);
	vec3 col2 = lowfilter(gColAdd.rgb * texture2D(noise, uv2).rgb, 0.05);
	
	float st = sin(iGlobalTime*0.75);
	float st2 = sin(iGlobalTime*0.416);
	float ct = cos(iGlobalTime*0.667);
	vec3 tint = gColBase.rgb + vec3(gColAdd.r * st, gColAdd.g * ct, gColAdd.b * -st2);
	return  clamp((col1*col1*(1-(rInv*135))*12)+col2*col2*col2*(1-(rInv*200))*18,0.0,10.0)*tint;
}

vec3 bloom(vec3 c)
{
	vec3 plus = max(c-1.0,0.0);
	float p = (plus.r+plus.g+plus.b)*0.5;
	return c+p*p;//min(vec3(1.0+p), c);
	
}

void main( )
{
	vec2 uv = GetUV(gl_FragCoord.xy);
    vec3 dust = bloom(GenDust(gl_FragCoord.xy, GetRevUV(vec2(0.0)))) * 0.5;
	vec3 stars = bloom(GenStarfield(uv)) * 0.25;
	
    vec2 pos = ((gl_FragCoord.xy + 1.0) * 0.5 * iResolution.xy);
    
	float a = clamp(gl_Color.a,0,1);
	a *= a;
	float d = distance(gl_FragCoord.xy, vec2(400,300));
	a -= mix((d/500),0,a*a);
	gl_FragColor = vec4(a*(stars + dust)*clamp(distance(gBossPos,gl_FragCoord.xy)*0.00125,0,1), a);
}