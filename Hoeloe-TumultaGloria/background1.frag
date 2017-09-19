#version 120
uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iGlobalTime;           // shader playback time (in seconds)

float map(vec3 point)
{
    vec3 q = fract(point) * 2.0 - 1.0;
    return length(q) - .25;
}

float trace(vec3 orgn, vec3 ray)
{
    float t = 0.0;
    for (int ndx = 0; ndx < 32; ndx++) {
        vec3 point = orgn + ray * t;
        float d = map(point);
        t += d * .5;
    }
    return t;
}

void main()
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    float theta = iGlobalTime * .25;
    
    
    vec3 ray = normalize(vec3(uv, 1.0));
    ray.xz *= mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
    ray *= mat3(.5 + abs(sin(theta)), 0.0, 0.0, 0.0, .5 + abs(cos(theta)), 0.0, 0.0, 0.0, abs(sin(theta)));
    
    
    vec3 orgn = vec3(0.0, 0.0, iGlobalTime);
    float trc = trace(orgn, ray);
    
    float fog = 1.0 / (1.0 + trc * trc * .1);
    
    vec3 fg = vec3(fog * 2.5 * abs(cos(iGlobalTime / 5.0)), fog, fog * 2.5 * abs(sin(iGlobalTime / 5.0)));
	gl_FragColor = vec4(fg,1.0);
}