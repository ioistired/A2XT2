uniform float shadowSoftness = 0.95;
uniform float shadowResolution = 0.5;

vec3 shadow(vec3 col, vec2 lightpos, vec2 pixpos)
{
	vec2 stp = -(lightpos-pixpos);
	float stepnum = floor(length(stp)*shadowResolution);
	stepnum = max(1,stepnum);
	int stepCount = int(stepnum);
	stp = normalize(stp)/shadowResolution;
	vec2 newpos = lightpos;
	vec3 adder = col/stepCount;
	vec3 agg = vec3(0);
	for (int i = 0; i < stepCount; i++)
    {
		newpos += stp;
		
		/* //Better filter,but requires another texture object
		vec2 screenPos = newpos-cameraPos;
		float m = texture2D( mask, screenPos/vec2(800,600)).r;
		
		agg += adder*m;
		agg *= 0.4*(1-m);
		*/
		
		
		if(newpos.y < -200128 && !(newpos.x > -199680 && newpos.x < -199616 && newpos.y > -200224)) //TODO: Better shadow cast condition (texture sample? Could also avoid branch)
		{
			agg += adder;
		}
		else
		{
			agg *= shadowSoftness;
		}
	}
	return agg;
}