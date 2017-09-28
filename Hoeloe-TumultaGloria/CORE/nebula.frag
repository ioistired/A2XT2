#version 120

uniform float iTime;
uniform vec3 iResolution;

#define formuparam 0.89
 
#define volsteps 4
#define stepsize 0.190
 
#define zoom 	7.0
#define tile   	0.450
 
#define distfading 0.560
#define saturation 0.400


#define transverseSpeed 1.1
#define cloud 0.2
 

float field(in vec3 p) 
{
	
	float strength = 7.0 + 0.03 * log(1.e-6 + fract(sin(iTime) * 4373.11));
	float accum = 0.;
	float prev = 0.;
	float tw = 0.;
	

	for (int i = 0; i < 6; ++i) 
	{
		float mag = dot(p, p);
		p = abs(p) / mag + vec3(-.5, -.8 + 0.1 * sin(iTime * 0.2 + 2.0), -1.1 + 0.3 * cos(iTime * 0.15));
		float w = exp(-float(i) / 7.);
		accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
		tw += w;
		prev = mag;
	}
	return max(0., 5. * accum / tw - .7);
}



void main()
{
	vec2 uv = (2 * gl_FragCoord.xy - iResolution.xy) / max(iResolution.x, iResolution.y);
               
    float speed = 0.005 * cos(iTime*0.02 + 0.785 /*pi/4*/);

	//mouse rotation
	float a_xz = 0.9;
	float a_yz = -.6;
	float a_xy = 0.9 + iTime*0.04;
		
	mat3 rot_xy = mat3(	cos(a_xy),	sin(a_xy),	0,
						-sin(a_xy),	cos(a_xy),	0,
						0,			0,			1);
						
	mat3 rot_1 = mat3(	cos(a_xz),	-sin(a_xz)*sin(a_yz),	sin(a_xz)*cos(a_yz),
						0,			cos(a_yz),				sin(a_yz),
						-sin(a_xz),	-cos(a_xz)*sin(a_yz),	cos(a_xz)*cos(a_yz));
	

	vec3 dir=vec3(uv*zoom,1.);
	vec3 from=vec3(-2.5, -2.5, 0.0);
	vec3 forward = vec3(0.3,0.2,0.);
               
	from.x += transverseSpeed*(1.0)*cos(0.01*iTime) +0.001*iTime;
	from.y += transverseSpeed*(1.0)*sin(0.01*iTime) +0.001*iTime;
	from.z += 0.003*iTime;
	
	dir *= rot_1*rot_xy;
	forward *= rot_1*rot_xy;
	from *= rot_1*(-rot_xy);
	 
	
	//zoom
	float zooom = (iTime-3311.)*speed;
	from += forward* zooom;
	float zoffset = -mod( zooom, stepsize );
	 
	float sampleShift = -zoffset/stepsize; // make from 0 to 1

	//volumetric rendering
	float s3 = 0.24 + stepsize*0.5;
	vec3 v=vec3(0);
	float t3 = 0.0;
	
	
	vec3 backCol2 = vec3(0);
	for (int r=0; r<volsteps; r++) 
	{
		vec3 p3=(from+(s3+zoffset)*dir )* (1.9/zoom);
		
		p3 = abs(vec3(tile)-mod(p3,vec3(tile*2.))); // tiling fold
		
		t3 = field(p3);
		
		float fade = pow(distfading,max(0.,float(r)-sampleShift));
		v+=fade;
		
		// fade out samples as they approach the camera and fade in samples as they approach from the distance
		fade *= mix(1.0 - sampleShift, 1.0, clamp(r,0,1)) * mix(sampleShift, 1.0, 1-clamp(r-(volsteps-2),0,1));
		backCol2 += mix(0.4, 1.0, 1.0) * vec3(0.20 * t3 * t3 * t3, 0.4 * t3 * t3, t3 * 0.7) * fade;

		s3 += stepsize;
	}
		       
	v=mix(vec3(length(v)),v,saturation);
	vec4 forCol2 = vec4(v*.01,1.);
	
	backCol2 *= cloud;
    
	gl_FragColor = forCol2 + vec4(backCol2, 1.0);
}