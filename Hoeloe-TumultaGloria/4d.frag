#version 120
uniform sampler2D iChannel0;

float computeEnd(float x)
{
	return clamp(pow(abs(2*((x-0.5))),3),0.1,1)*0.4;
}

void main()
{

	gl_FragColor = gl_Color*vec4(computeEnd(gl_TexCoord[0].x)+computeEnd(gl_TexCoord[0].y));
	gl_FragColor.a = 0;
}