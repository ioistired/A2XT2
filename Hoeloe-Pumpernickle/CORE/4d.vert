#version 120

uniform vec4 offset;
uniform float scale;
uniform float depth;
uniform vec3 rot1;
uniform vec3 rot2;
attribute vec4 position;

void main()
{    
	mat4 rotxw = mat4(
					1,				0,				0,				0,
					0,				cos(rot1.x),	-sin(rot1.x),	0,
					0,				sin(rot1.x),	cos(rot1.x),		0,
					0,				0,				0,					1);
	mat4 rotyw = mat4(
					cos(rot1.y),	0,				-sin(rot1.y),	0,
					0,				1,				0,				0,
					sin(rot1.y),	0,				cos(rot1.y),	0,
					0,				0,				0,				1);
					
	mat4 rotzw = mat4(
					cos(rot1.z),	-sin(rot1.z),	0,				0,
					sin(rot1.z),	cos(rot1.z),	0,				0,
					0,				0,				1,				0,
					0,				0,				0,				1);
					
	mat4 rotxy = mat4(
					1,				0,				0,				0,
					0,				1,				0,				0,
					0,				0,				cos(rot2.z),	-sin(rot2.z),
					0,				0,				sin(rot2.z),	cos(rot2.z));
					
	mat4 rotxz = mat4(
					1,				0,				0,				0,
					0,				cos(rot2.y),	0,				-sin(rot2.y),
					0,				0,				1,				0,
					0,				sin(rot2.y),	0,				cos(rot2.y));
					
	mat4 rotyz = mat4(
					cos(rot2.x),	0,				0,				-sin(rot2.x),
					0,				1,				0,				0,
					0,				0,				1,				0,
					sin(rot2.x),	0,				0,				cos(rot2.x));
	
	vec4 pos = position*rotyz*rotxz*rotxy*rotzw*rotyw*rotxw;
	pos.xyzw *= scale;
	pos.xyz *= depth/(depth-pos.w);
	pos += offset;
	
	pos.z = 0;
	pos.w = 1;

    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    gl_Position = gl_ModelViewProjectionMatrix * pos;
	gl_FrontColor = gl_Color;
}