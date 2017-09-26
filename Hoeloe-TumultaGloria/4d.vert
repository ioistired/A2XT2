#version 120

uniform vec4 cameraPos = vec4(0,0,0,-1);
uniform float screen = 0;
uniform vec4 offset;
uniform float scale;
uniform float depth;
uniform vec4 rot;
attribute vec4 position;

void main()
{    
	mat4 rotx = mat4(
					1,			0,			0,				0,
					0,			cos(rot.x),	-sin(rot.x),	0,
					0,			sin(rot.x),	cos(rot.x),		0,
					0,			0,		0,					1);
	mat4 roty = mat4(
					cos(rot.y),	0,			-sin(rot.y),	0,
					0,			1,			0,				0,
					sin(rot.y),	0,			cos(rot.y),		0,
					0,			0,			0,				1);
					
	mat4 rotz = mat4(
					cos(rot.z),	-sin(rot.z),0,				0,
					sin(rot.z),	cos(rot.z),	0,				0,
					0,			0,			1,				0,
					0,			0,			0,				1);
					
	mat4 rotw = mat4(
					1,			0,			0,				0,
					0,			1,			0,				0,
					0,			0,			cos(rot.w),		-sin(rot.w),
					0,			0,			sin(rot.w),		cos(rot.w));
					
	mat4 rotmat = rotw*rotz*roty*rotx;

	vec4 d = position*rotmat;
	
	d += offset-cameraPos;
	float t = (screen/cameraPos.w)/d.w;
	
	vec4 pos = cameraPos+d*t;
	
	pos = position*rotmat;
	
	float shade = clamp((pos.z)/2,0,1);
	
	pos.xyzw *= scale;
	
	pos.xyz *= depth/(depth-pos.w);
	
	pos += offset;
	pos.z = 0;
	pos.w = 1;

    gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    gl_Position = gl_ModelViewProjectionMatrix * pos;
	vec4 c = gl_Color;
	gl_FrontColor = c;
}