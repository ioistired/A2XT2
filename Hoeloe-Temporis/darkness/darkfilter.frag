#version 120
uniform sampler2D iChannel0;
uniform vec2 cameraPos;
uniform vec3[_MAXLIGHTS] lightPos;
uniform vec4[_MAXLIGHTS] lightCol;
uniform sampler2D mask;
uniform vec4 ambient;
uniform int lightNum;

uniform vec4 bounds;
uniform float useBounds = 0;
uniform float boundBlend = 64;

#include FALLOFF
#include SHADOWS

void main()
{
	vec4 c = texture2D( iChannel0, gl_TexCoord[0].xy);
	vec3 light = vec3(0);
	vec2 pos = gl_FragCoord.xy + cameraPos;
	
	light.rgb = vec3(mix(0, smoothstep(bounds.x+boundBlend, bounds.x, pos.x) + smoothstep(bounds.z-boundBlend, bounds.z, pos.x) + smoothstep(bounds.y+boundBlend, bounds.y, pos.y) + smoothstep(bounds.w-boundBlend, bounds.w, pos.y), useBounds));
	
	for (int i = 0; i < lightNum; i++)
	{
		float d = abs(length(pos - lightPos[i].xy));
		if(d < lightPos[i].z)
		{
			vec3 agg = shadow(falloff(lightCol[i], d, lightPos[i].z), lightPos[i].xy, pos);
			light.rgb += agg;
		}
	}
		
	light.rgb = clamp(light.rgb,0,1);
	gl_FragColor = c*clamp(vec4(light,1)+ambient,0,1)*gl_Color;
}