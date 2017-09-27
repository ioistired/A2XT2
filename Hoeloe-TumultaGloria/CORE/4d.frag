#version 120
uniform sampler2D iChannel0;

float computeEnd(float x, float po, float mi, float ma)
{
	return clamp(pow(abs(2*((x-0.5))),po),mi,1)*ma;
}

vec4 calculateBorders(float mi, float ma, float po)
{
	return vec4(computeEnd(gl_TexCoord[0].x, po, mi, ma)+computeEnd(gl_TexCoord[0].y, po, mi, ma));
}

void main()
{
	
	gl_FragColor = (gl_Color*calculateBorders(0.2,0.4,3)) + calculateBorders(0,0.25,4);
	gl_FragColor.a = 0;
}