#version 120
uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iGlobalTime;           // shader playback time (in seconds)
uniform float     gSpeedMult;      
uniform sampler2D iChannel0;    
uniform vec2	  gBossPos;  

uniform vec3	  gColBase;
uniform vec3	  gColAdd;
   
const float gSpeed = 1;     
const int StarQuality = 5;
const int DustQuality = 35;

vec2 WarpUV(vec2 buv, vec2 uv, float f)
{
    return uv; // Comment this line for black hole effect, its not soo good
    float d = distance(buv / iResolution.xy, vec2(0.5, 0.5));
    uv *= 1.0 - pow(0.007, d);
    return uv;
}

mat2 GetRotation()
{
    // Reverse the rotation effect
    float time = iGlobalTime*65;
    time *= -0.005;
    return mat2(cos(time), sin(time), -sin(time), cos(time));
}

vec2 GetUV(vec2 BaseUV)
{
    float time = iGlobalTime*65;
    vec2 uv = (BaseUV.xy / iResolution.xy) * 2.0 - 1.0;
    uv.x = (uv.x * iResolution.x / iResolution.y) + sin(time*0.005) * 0.5;
    uv *= GetRotation();
    uv = WarpUV(BaseUV, uv, 1.5);
    return uv;
}

vec3 GenStarfield(vec2 BaseUV)
{
    vec3 r = vec3(GetUV(BaseUV), 1.0);
    
    float opac = sin(gSpeed);
    float mspeed = gSpeed * gSpeedMult;
    
    float d = 0.5 * iGlobalTime;
    float s2 = mspeed;
    float s = s2 + 0.1; // add a small offset
    
    d += d*gSpeed*gSpeedMult*0.96;
    
    vec3 accum = vec3(0,0,0);
    vec3 spp = r/max(abs(r.x),abs(r.y));
    vec3 p = 2.0 * spp + 0.5;
    
    for (int i = 0; i < StarQuality; i++)
    {
        float z = texture2D( iChannel0, mod((p.xy+0.5)/256.0,1.0), -100 ).x;
		z = fract(z-d);
		float d2 = 50.0*z-p.z;
		float w = pow(max(0.0,1.0-8.0*length(fract(p.xy)-.5)),2.0);
		vec3 c = max(vec3(0),vec3(1.0-abs(d2+s2*.5)/s,1.0-abs(d2)/s,1.0-abs(d2-s2*.5)/s));
		accum += 1.5*(1.0-z)*c*w;
		p += spp;
    }
    
    return pow(accum, vec3(1.0/2.2))*opac;
}

vec3 GenDust(vec2 BaseUV)
{
    float time = iGlobalTime*65;
    
    float s = 0.0;
    float v = 0.0;
    vec2 uv = GetUV(BaseUV);
    vec3 accum = vec3(0);
    vec3 init = vec3 (0.25 + sin(time * 0.001) * 0.4, 0.25, floor(time) * 0.0008);
    
    float intensity = mix(1.0, 10.0, 1.0 - (float(DustQuality)*0.01));
	for (int r = 0; r < DustQuality; r++) 
	{
		vec3 p = init + s * vec3(uv, 0.143);
		p.z = mod(p.z, 2.0);
		for (int i=0; i < 10; i++)
		{			
			p = abs(p * 2.04) / dot(p, p) - 0.75;
		}		
		v += length(p * p) * smoothstep(0.0, 0.5, 0.9 - s) * .002;
		accum +=  vec3(gColBase.r - s * gColAdd.r, gColBase.g + v * gColAdd.g,  gColBase.b + v * gColAdd.b) * v * 0.013;
		s += .01;
	}
    
    return accum*intensity*2;
}

void main( )
{
    vec3 dust = GenDust(gl_FragCoord.xy) * 0.5;
	vec3 stars = GenStarfield(gl_FragCoord.xy) * 0.25;
	
    vec2 pos = ((gl_FragCoord.xy + 1.0) * 0.5 * iResolution.xy);
    
	float a = clamp(gl_Color.a,0,1);
	a *= a;
	float d = distance(gl_FragCoord.xy, vec2(400,300));
	a -= mix((d/500),0,a*a);
	gl_FragColor = vec4(a*(stars + dust)*clamp(distance(gBossPos,gl_FragCoord.xy)*0.00125,0,1), a);
}